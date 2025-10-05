#PARAMETER Request Represents the HTTP request input (includes query parameters and body).
#PARAMETER TriggerMetadata Contains metadata about the Azure Function trigger (e.g., name, timestamp).
param($Request, $TriggerMetadata)

# ---------------------------
# READ / VALIDATE INPUT
# ---------------------------
Write-Output "Reading input parameters..."

# Retrieve 'apiType' (crypto, weather, or stock) from query parameters
$apiType = $Request.Params.apiType 
Write-Output "Request API Type: $apiType"

# Validate 'apiType' parameter
$allowedTypes = @("crypto","weather","stock")
if ($allowedTypes -notcontains $apiType.ToLower())  {
    Write-Output "ERROR: Missing or Invalid 'apiType' parameter in request"

      # Respond with 400 Bad Request if 'apiType' is missing
    Push-OutputBinding -Name Response -Value @{
        StatusCode = 400
        Headers    = @{ "Content-Type" = "application/json" }
        Body       = ( @{ error = "Missing or Invalid 'apiType' parameter, apiType must be one of these (crypto|weather|stock)" } | ConvertTo-Json )
    }
    return
}
Write-Output "Request API Type: $apiType"

# ---------------------------
# BUILD API REQUEST BASED ON API Type
# ---------------------------

switch ($apiType.ToLower()) {
    "crypto" {
         Write-Output "Selected API Type: CRYPTO"

        # Retrieve coin name from query string
        $coinName = $Request.Query.coinName
        
         # Validate coin name
        if (-not $coinName) {
            Write-Output "ERROR: Missing coinName for crypto request"

            # Respond with 400 Bad Request if 'coin name' is missing
            Push-OutputBinding -Name Response -Value @{
                StatusCode = 400
                Headers    = @{ "Content-Type" = "application/json" }
                Body       = ( @{ error = "Missing 'coinName' for crypto" } | ConvertTo-Json )
            }
            return
        }
        Write-Output "Selected Crypto Coin: $coinName"
           
        # Build CoinGecko API URL (no API key required)
        $uri = "https://api.coingecko.com/api/v3/simple/price?ids=$coinName&vs_currencies=usd"
        Write-Output "Crypto API endpoint: $uri"
    }

    "weather" {
        Write-Output "Selected API type: WEATHER"

          # Retrieve city name
        $cityName = $Request.Query.cityName
        
            # Validate city name
        if (-not $cityName) {
            Write-Output "ERROR: Missing cityName for weather request"

            # Respond with 400 Bad Request if 'city name' is missing
            Push-OutputBinding -Name Response -Value @{
                StatusCode = 400
                Headers    = @{ "Content-Type" = "application/json" }
                Body       = ( @{ error = "Missing 'cityName' (city) for weather" } | ConvertTo-Json )
            }
            return
        }

        # Retrieve API key from environment variable
        $apiKey = $env:OPENWEATHER_API_KEY
        if (-not $apiKey) {
            Write-Output "ERROR: OPENWEATHER_API_KEY not found in environment variables"

            # Respond with 500 service error if 'API key' is missing
            Push-OutputBinding -Name Response -Value @{
                StatusCode = 500
                Headers    = @{ "Content-Type" = "application/json" }
                Body       = ( @{ error = "OPENWEATHER_API_KEY not set in environment" } | ConvertTo-Json )
            }
            return
        }
        Write-Output "Selected City Name: $cityName"

        # Build OpenWeather API URL
        $uri = "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric"
        Write-Output "WEATHER API endpoint: $uri"
    }

    "stock" {
        Write-Output "Selected API type: STOCK"
        
        # Retrieve stock symbol from query string
        $stockName = $Request.Query.stockName
        Write-Output "Selected Stock Name: $stockName"

         # Validate stock name
        if (-not $stockName) {
            Write-Output "ERROR: Missing stockName for stock request"

            # Respond with 400 Bad Request if 'stock name' is missing
            Push-OutputBinding -Name Response -Value @{
                StatusCode = 400
                Headers    = @{ "Content-Type" = "application/json" }
                Body       = ( @{ error = "Missing 'stockName' for stock" } | ConvertTo-Json )
            }
            return
        }

        # Retrieve Alpha Vantage API key
        $apiKey = $env:ALPHAVANTAGE_API_KEY
        if (-not $apiKey) {
            Write-Output "ERROR: ALPHAVANTAGE_API_KEY not found in environment variables"

            # Respond with 500 service error if 'API key' is missing
            Push-OutputBinding -Name Response -Value @{
                StatusCode = 500
                Headers    = @{ "Content-Type" = "application/json" }
                Body       = ( @{ error = "ALPHAVANTAGE_API_KEY not set in environment" } | ConvertTo-Json )
            }
            return
        }
 
        # Build AlphaVantage API URL
        $uri = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$stockName&apikey=$apiKey"
        Write-Output "Crypto API endpoint: $uri"
    }
}

# ---------------------------
# CALL THE PUBLIC API
# ---------------------------
try {

     # Invoke REST API request and capture response
    $apiResp = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
    Write-Output "API call successful. Preparing response for client..."

    # Prepare output JSON structure
    $bodyOut = ( @{ success = $true; data = $apiResp })

    # Send HTTP 200 success response to the client
    Push-OutputBinding -Name Response -Value @{
        StatusCode = 200
        Headers    = @{ "Content-Type" = "application/json" }
        Body       = $bodyOut
    }
    Write-Output "Response successfully returned to client."
}
catch {
      # Handle exceptions gracefully and return failure response
    Write-Output "API call failed: $($_.Exception.Message)"

     # Send HTTP 503 Service Unavailable response to the client 
    Push-OutputBinding -Name Response -Value @{
        StatusCode = 503
        Headers    = @{ "Content-Type" = "application/json" }
        Body       = ( @{
            success = $false
            error   = "API call failed"
            details = $_.Exception.Message
        } | ConvertTo-Json )
    }
}
