## 📘 Overview
- This Azure Function is built using PowerShell and triggered via HTTP requests.
- It retrieves real-time data from public APIs based on the type parameter in the request. 
- Supported types:
  - crypto → Fetches cryptocurrency prices for given crypto name
  - weather → Fetches current weather data for given city name
  - stock → Fetches stock quotes for given stock name

## 🚀 Features
- Fetches cryptocurrency prices from CoinGecko (no API key required)
- Retrieves current weather data from OpenWeather (requires API key)
- Pulls stock quotes from AlphaVantage (requires API key)
- Returns all results in JSON format
- Includes error handling for invalid inputs and missing environment variables

## ⚙️ Prerequisites and Setup
- [Install Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- [Install PowerShell 7+](https://learn.microsoft.com/powershell/)
- CoinGecko API_KEY Not Required
  Create Account and sign-in below website to get free API keys
- [Free OpenWeather API_KEY](https://openweathermap.org/appid#apikey)
- [Free AlphaVantage API_KEY](https://www.alphavantage.co/support/#api-key)

## 🔑 Set Environment Variables

Before running, make sure to set API keys in your Azure Function App Settings or local environment.

| Variable                    | Description                          | Required For |
|-----------------------------|--------------------------------------|--------------|
| OPENWEATHER_API_KEY         | Your OpenWeather API key             | Weather API  |
| ALPHAVANTAGE_API_KEY        | Your AlphaVantage API key            | Stock API    |

Example (local development):

- OPENWEATHER_API_KEY = "<your_openweather_api_key>"
- ALPHAVANTAGE_API_KEY = "<your_alphavantage_api_key>"


## 🧪How to Run Locally
1. Clone/download this project using below commands  
   - git clone https://github.com/Prathyusha-dusa/AzureFunctionApp.git
3. Start the function locally using below command
   - func start
4. Test it in a browser or Postman:
   - weather: http://localhost:7071/api/AzureAPIFunction/weather?cityName=London
   - crypto: http://localhost:7071/api/AzureAPIFunction/crypto?cryptoName=bitcoin
   - stock: http://localhost:7071/api/AzureAPIFunction/stock?stockName=NVDA


## 🔒 Error Handling

| Error                                           | Cause                                 | HTTP Code |
|-------------------------------------------------|---------------------------------------| --------- |
| Invalid or Missing 'apiType' parameter          | Path parameter not supplied           | 400       |
| Missing API key                                 | Required environment variable not set | 500       |
| API failure                                     | External API error                    | 503       |
