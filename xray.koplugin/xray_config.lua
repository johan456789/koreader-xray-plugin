-- X-Ray API Configuration
local api_keys = require("xray_apikeys")

return {
    -- Google Gemini API Key
    -- To get an API key: https://makersuite.google.com/app/apikey
    -- Enter your API key here:
    gemini_api_key = api_keys.gemini, 
    
    -- ChatGPT API Key 
    -- To get an API key: https://platform.openai.com/api-keys
    -- Enter your API key here:
    chatgpt_api_key = api_keys.openai,  
}
