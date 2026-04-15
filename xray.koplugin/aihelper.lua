-- AIHelper - Google Gemini & ChatGPT for X-Ray
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")
local logger = require("logger")

local AIHelper = {}

-- AI Provider settings (default values)
AIHelper.providers = {
    gemini = {
        name = "Google Gemini",
        enabled = true,
        api_key = nil,
        model = "gemini-2.5-flash", -- Default model
    },
    chatgpt = {
        name = "ChatGPT",
        enabled = true,
        api_key = nil,
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-4o-mini", -- Default model (cost/performance)
    }
}

AIHelper.model_override = nil

-- Set Gemini model
function AIHelper:setGeminiModel(model_name)
    if not model_name or #model_name == 0 then return false end
    self.providers.gemini.model = model_name
    self:saveModelToConfig(model_name)
    return true
end

-- Set ChatGPT model
function AIHelper:setChatGPTModel(model_name)
    if not model_name or #model_name == 0 then return false end
    self.providers.chatgpt.model = model_name
    self:saveModelToConfig(model_name, "chatgpt")
    return true
end

-- Set default provider 
function AIHelper:setDefaultProvider(provider_name)
    if not provider_name or (provider_name ~= "gemini" and provider_name ~= "chatgpt") then 
        return false 
    end
    self.default_provider = provider_name
    self:saveProviderToConfig(provider_name)
    logger.info("AIHelper: Default provider changed to:", provider_name)
    return true
end

-- Save model preference to config file
function AIHelper:saveModelToConfig(model_name, provider)
    provider = provider or "gemini"
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    local lfs = require("libs/libkoreader-lfs")
    lfs.mkdir(xray_dir)
    
    local model_file = xray_dir .. "/" .. provider .. "_model.txt"
    local file = io.open(model_file, "w")
    if file then
        file:write(model_name)
        file:close()
        return true
    end
    return false
end

-- Save provider preference to config file 
function AIHelper:saveProviderToConfig(provider_name)
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    local lfs = require("libs/libkoreader-lfs")
    lfs.mkdir(xray_dir)
    
    local provider_file = xray_dir .. "/default_provider.txt"
    local file = io.open(provider_file, "w")
    if file then
        file:write(provider_name)
        file:close()
        logger.info("AIHelper: Saved default provider:", provider_name)
        return true
    end
    logger.warn("AIHelper: Failed to save provider preference")
    return false
end

-- Initialize AIHelper
function AIHelper:init(path)
    self.path = path or "plugins/xray.koplugin"
    self:loadConfig()
    self:loadModelFromFile()
    self:loadLanguage()
    logger.info("AIHelper: Initialized with Gemini model:", self.providers.gemini.model)
    logger.info("AIHelper: ChatGPT model:", self.providers.chatgpt.model)
end

-- Load configuration
function AIHelper:loadConfig()
    local success, config = pcall(require, "config")
    self.config_keys = { gemini = nil, chatgpt = nil }
    -- INITIALIZE DEFAULT SETTINGS TO PREVENT CRASHES
    self.settings = { auto_fetch_on_open = false, max_characters = 20 } 
    
    if success and config then
        if config.gemini_api_key then 
            self.providers.gemini.api_key = config.gemini_api_key 
            self.config_keys.gemini = config.gemini_api_key
        end
        if config.gemini_model then self.providers.gemini.model = config.gemini_model end
        if config.chatgpt_api_key then 
            self.providers.chatgpt.api_key = config.chatgpt_api_key 
            self.config_keys.chatgpt = config.chatgpt_api_key
        end
        if config.chatgpt_model then self.providers.chatgpt.model = config.chatgpt_model end
        if config.default_provider then self.default_provider = config.default_provider end
        if config.settings then self.settings = config.settings end
    end
end

-- Load model preference
function AIHelper:loadModelFromFile()
    local DataStorage = require("datastorage")
    
    -- Gemini model
    local gemini_file = DataStorage:getSettingsDir() .. "/xray/gemini_model.txt"
    local file = io.open(gemini_file, "r")
    if file then
        local model = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if model and #model > 0 then
            self.providers.gemini.model = model
        end
    end
    
    -- ChatGPT model
    local chatgpt_file = DataStorage:getSettingsDir() .. "/xray/chatgpt_model.txt"
    file = io.open(chatgpt_file, "r")
    if file then
        local model = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if model and #model > 0 then
            self.providers.chatgpt.model = model
        end
    end
    
    -- Default provider
    local provider_file = DataStorage:getSettingsDir() .. "/xray/default_provider.txt"
    file = io.open(provider_file, "r")
    if file then
        local provider = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if provider and (provider == "gemini" or provider == "chatgpt") then
            self.default_provider = provider
            logger.info("AIHelper: Loaded default provider from file:", provider)
        end
    end
    
    -- Gemini API Key
    local gemini_key_file = DataStorage:getSettingsDir() .. "/xray/gemini_api_key.txt"
    file = io.open(gemini_key_file, "r")
    if file then
        local raw_key = file:read("*a")
        file:close()
        if raw_key then
            local clean_key = raw_key:gsub("%s+", "")
            if #clean_key > 0 then
                self.providers.gemini.api_key = clean_key
                self.providers.gemini.ui_key_active = true
                logger.info("AIHelper: Loaded Gemini API key from file")
            end
        end
    else
        self.providers.gemini.ui_key_active = false
        if self.config_keys and self.config_keys.gemini then
            self.providers.gemini.api_key = self.config_keys.gemini
        end
    end
    
    -- ChatGPT API Key
    local chatgpt_key_file = DataStorage:getSettingsDir() .. "/xray/chatgpt_api_key.txt"
    file = io.open(chatgpt_key_file, "r")
    if file then
        local raw_key = file:read("*a")
        file:close()
        if raw_key then
            local clean_key = raw_key:gsub("%s+", "")
            if #clean_key > 0 then
                self.providers.chatgpt.api_key = clean_key
                self.providers.chatgpt.ui_key_active = true
                logger.info("AIHelper: Loaded ChatGPT API key from file")
            end
        end
    else
        self.providers.chatgpt.ui_key_active = false
        if self.config_keys and self.config_keys.chatgpt then
            self.providers.chatgpt.api_key = self.config_keys.chatgpt
        end
    end
end

-- Function to clear the UI override key and revert to config
function AIHelper:clearAPIKeyFile(provider)
    local DataStorage = require("datastorage")
    local key_file = DataStorage:getSettingsDir() .. "/xray/" .. provider .. "_api_key.txt"
    os.remove(key_file)
    if self.config_keys and self.config_keys[provider] then
        self.providers[provider].api_key = self.config_keys[provider]
    else
        self.providers[provider].api_key = nil
    end
    self.providers[provider].ui_key_active = false
    logger.info("AIHelper: Cleared UI key for " .. provider .. ", reverted to config.")
end


-- Save API Key preference to file
function AIHelper:saveAPIKeyToFile(provider, api_key)
    local DataStorage = require("datastorage")
    local settings_dir = DataStorage:getSettingsDir()
    local xray_dir = settings_dir .. "/xray"
    local lfs = require("libs/libkoreader-lfs")
    lfs.mkdir(xray_dir)
    
    local key_file = xray_dir .. "/" .. provider .. "_api_key.txt"
    local file = io.open(key_file, "w")
    if file then
        file:write(api_key)
        file:close()
        logger.info("AIHelper: Saved", provider, "API key to file")
        return true
    end
    logger.warn("AIHelper: Failed to save", provider, "API key")
    return false
end

-- Get book data from AI
function AIHelper:getBookData(title, author, provider_name, context)
    self:loadModelFromFile() -- Refresh model
    local provider = provider_name or "gemini"
    local provider_config = self.providers[provider]
    
    if not provider_config or not provider_config.api_key then
        return nil, "error_no_api_key"
    end
    
    -- Create prompts with context.
    local prompt = self:createPrompt(title, author, context)
    
    logger.info("AIHelper: Using provider:", provider, "Model:", provider_config.model)
    if context and context.spoiler_free then
        logger.info("AIHelper: Spoiler-free mode active, reading:", context.reading_percent, "%")
    end
    
    if provider == "gemini" then
        return self:callGemini(prompt, provider_config)
    elseif provider == "chatgpt" then
        return self:callChatGPT(prompt, provider_config)
    end
    return nil, "error_unknown_provider"
end

-- Check network
function AIHelper:checkNetworkConnectivity()
    local socket = require("socket")
    local success, err = pcall(function()
        local tcp = socket.tcp()
        tcp:settimeout(3)
        local result = tcp:connect("8.8.8.8", 53)
        tcp:close()
        return result
    end)
    return success
end

-- Load language
function AIHelper:loadLanguage()
    local DataStorage = require("datastorage")
    local f = io.open(DataStorage:getSettingsDir() .. "/xray/language.txt", "r")
    self.current_language = f and f:read("*a"):match("^%s*(.-)%s*$") or "en"
    if f then f:close() end
    self:loadPrompts()
end

-- Load prompts
function AIHelper:loadPrompts()
    -- Use dofile for absolute paths to avoid package.path issues
    local prompt_file = self.path .. "/prompts/" .. self.current_language .. ".lua"
    local success, prompts = pcall(dofile, prompt_file)
    
    if not success then 
        prompt_file = self.path .. "/prompts/en.lua"
        success, prompts = pcall(dofile, prompt_file) 
    end
    self.prompts = prompts or {}
end

-- Create prompt
function AIHelper:createPrompt(title, author, context)
    if not self.prompts then self:loadLanguage() end
    
    local enhanced_title = title
    local enhanced_author = author or "Unknown"
    local extra_context = ""
    
    if context then
        if context.series then
            local series_info = context.series
            if context.series_index then
                series_info = series_info .. " (Book " .. context.series_index .. ")"
            end
            enhanced_title = enhanced_title .. " | Series: " .. series_info
        end
        
        if context.filename or context.pub_year then
            enhanced_title = string.format("%s (File: %s, Year: %s)", 
                enhanced_title, 
                context.filename or "N/A", 
                context.pub_year or "N/A")
        end
        
        if context.chapter_title then
            enhanced_author = enhanced_author .. " | Current Chapter: " .. context.chapter_title
        end
        
        if context.book_text and #context.book_text > 0 then
            extra_context = extra_context .. "\n\nBOOK TEXT CONTEXT (Crucial for identification and progress tracking):\n" .. 
                            "--- START OF TEXT ---\n" .. 
                            context.book_text .. 
                            "\n--- END OF TEXT ---\n"
        end
        
        if context.annotations and #context.annotations > 0 then
            extra_context = extra_context .. "\n\nUSER HIGHLIGHTS & NOTES (Crucial for character focus):\n" ..
                            "--- START OF ANNOTATIONS ---\n" ..
                            context.annotations ..
                            "\n--- END OF ANNOTATIONS ---\n"
        end
    end
    
    -- Use a custom prompt if context exists and you're in spoiler_free mode.
    local final_prompt = ""
    if context and context.spoiler_free then
        local template = self.prompts.spoiler_free or self.prompts.main
        local p = context.reading_percent
        -- Template expects multiple %d placeholders for strict spoiler rules.
        final_prompt = string.format(template, enhanced_title, enhanced_author, 
            p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p)
        
        -- Add a heavy-handed instruction to use the provided text
        final_prompt = final_prompt .. "\n\nSTRICT INSTRUCTION: Your primary source is the 'BOOK TEXT CONTEXT' and 'USER HIGHLIGHTS' provided above. You MUST NOT reveal any information that is not supported by this text or that obviously happens later in the book. If the text provided does not show a character's secret, DO NOT mention it."
    else
        -- Normal prompt for the full book
        local template = self.prompts.main
        final_prompt = string.format(template, enhanced_title, enhanced_author)
    end
    
    -- Append extra context if available
    if #extra_context > 0 then
        final_prompt = final_prompt .. extra_context
    end
    
    return final_prompt
end

function AIHelper:getFallbackStrings()
    if not self.prompts then self:loadPrompts() end
    return self.prompts.fallback or {}
end

--- Call Google Gemini API (FIXED VERSION)
function AIHelper:callGemini(prompt, config)
    logger.info("AIHelper: Calling Google Gemini API")
    
    if not self:checkNetworkConnectivity() then
        return nil, "error_no_network", "No internet connection."
    end
    
    local model = config.model or "gemini-1.5-flash"
    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. model .. ":generateContent?key=" .. config.api_key
    
    -- Load the system instruction
    local system_instruction = self.prompts and self.prompts.system_instruction or "You are an expert literary critic. Respond ONLY with valid JSON format."

    -- Bulletproof prompt format: prepend system instruction to bypass finicky schema requirements
    local combined_prompt = system_instruction .. "\n\n" .. prompt

    -- Stripped down to the bare minimum required fields to prevent 400 schema validation errors
    local request_body = json.encode({
        contents = {{ parts = {{ text = combined_prompt }} }},
        generationConfig = {
            temperature = 0.4,
            maxOutputTokens = 8192,
            responseMimeType = "application/json"
        }
    })
    
    -- RETRY LOGIC
    local max_retries = 1
    for attempt = 1, max_retries + 1 do
        if attempt > 1 then
             local socket = require("socket")
             socket.sleep(3) 
        end

        local response_body = {}
        local res, code, headers, status = https.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#request_body),
            },
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body),
            timeout = 120
        }
        
        local response_text = table.concat(response_body)
        local code_num = tonumber(code)
        
        logger.info("AIHelper: API Code:", code_num, "Length:", #response_text)

        if code_num == 200 then
            local success, data = pcall(json.decode, response_text)
            if not success then return nil, "error_json_parse", "Failed to parse JSON" end
            
            if data and data.candidates and data.candidates[1] then
                local candidate = data.candidates[1]
                
                if candidate.finishReason == "SAFETY" then
                     return nil, "error_safety", "Blocked by Google Safety Filter."
                end

                if candidate.content and candidate.content.parts and candidate.content.parts[1] then
                    return self:parseAIResponse(candidate.content.parts[1].text)
                else
                    return nil, "error_api", "API returned an empty response."
                end
            else
                return nil, "error_api", "Invalid response format from Google."
            end
        elseif code_num == 503 then
             logger.warn("AIHelper: 503 Service Unavailable")
        else
             -- EXTRACT THE EXACT ERROR MESSAGE FROM GOOGLE SO YOU CAN SEE IT!
             local error_detail = "HTTP " .. tostring(code_num)
             local success, err_data = pcall(json.decode, response_text)
             if success and err_data and err_data.error then
                 error_detail = err_data.error.message or error_detail
             end
             logger.warn("AIHelper: API Error Details: " .. response_text)
             return nil, "error_" .. tostring(code_num), "API Error: " .. error_detail
        end
    end
    
    return nil, "error_timeout", "Connection timed out"
end

-- Call ChatGPT API (COMPLETE IMPLEMENTATION)
function AIHelper:callChatGPT(prompt, config)
    logger.info("AIHelper: Calling ChatGPT API")
    
    if not self:checkNetworkConnectivity() then
        return nil, "error_no_network", "No internet."
    end
    
    local model = config.model or "gpt-4o-mini"
    local url = config.endpoint or "https://api.openai.com/v1/chat/completions"
    
    -- Add system instruction (if exists in prompts)
    local system_instruction = self.prompts and self.prompts.system_instruction or 
        "You are an expert literary critic. Respond ONLY with valid JSON format."
    
    local request_body = json.encode({
        model = model,
        messages = {
            {
                role = "system",
                content = system_instruction
            },
            {
                role = "user",
                content = prompt
            }
        },
        temperature = 0.4,
        max_tokens = 8192,
        top_p = 0.95,
        response_format = { type = "json_object" } -- Enforce JSON mode
    })
    
    logger.info("AIHelper: ChatGPT request size:", #request_body)
    
    -- RETRY LOGIC
    local max_retries = 1
    for attempt = 1, max_retries + 1 do
        if attempt > 1 then
             local socket = require("socket")
             socket.sleep(3) 
             logger.info("AIHelper: Retrying ChatGPT request (attempt " .. attempt .. ")")
        end

        local response_body = {}
        local res, code, headers, status = https.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. config.api_key,
                ["Content-Length"] = tostring(#request_body),
            },
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body),
            timeout = 120
        }
        
        local response_text = table.concat(response_body)
        local code_num = tonumber(code)
        
        logger.info("AIHelper: ChatGPT API Code:", code_num, "Length:", #response_text)

        if code_num == 200 then
            local success, data = pcall(json.decode, response_text)
            if not success then 
                logger.warn("AIHelper: JSON parse error")
                return nil, "error_json_parse" 
            end
            
            -- CRASH PROTECTION: OpenAI response structure
            if data and data.choices and data.choices[1] then
                local choice = data.choices[1]
                
                -- Check finish reason
                if choice.finish_reason == "content_filter" then
                    logger.warn("AIHelper: BLOCKED BY CONTENT FILTER")
                    return nil, "error_safety", "Blocked by OpenAI Content Filter."
                end
                
                if choice.message and choice.message.content then
                    local content = choice.message.content
                    logger.info("AIHelper: ChatGPT response received, parsing...")
                    return self:parseAIResponse(content)
                else
                    logger.warn("AIHelper: No content in ChatGPT response")
                    return nil, "error_api", "API returned empty response."
                end
            else
                -- Log error message if exists
                if data and data.error then
                    logger.warn("AIHelper: ChatGPT API Error:", data.error.message or "Unknown")
                    return nil, "error_api", data.error.message or "API Error"
                end
                return nil, "error_api", "Invalid response format"
            end
        elseif code_num == 429 then
            logger.warn("AIHelper: 429 Rate Limit (Retrying...)")
            -- Wait longer for rate limit
            if attempt <= max_retries then
                local socket = require("socket")
                socket.sleep(5)
            end
        elseif code_num == 503 or code_num == 502 then
            logger.warn("AIHelper: " .. code_num .. " Service Error (Retrying...)")
        elseif code_num == 401 then
            return nil, "error_401", "Invalid API key"
        else
            logger.warn("AIHelper: Unexpected error code:", code_num)
            return nil, "error_" .. tostring(code_num), "Error Code: " .. tostring(code_num)
        end
    end
    
    return nil, "error_timeout", "Timeout"
end

function AIHelper:parseAIResponse(text)
    -- Cleaning
    local json_text = text:gsub("```json", ""):gsub("```", ""):gsub("^%s+", ""):gsub("%s+$", "")
    
    -- Parse
    local success, data = pcall(json.decode, json_text)
    
    -- If failed, try to find text between {}
    if not success then
        local first = json_text:find("{")
        local last_brace = nil
        for i = #json_text, 1, -1 do
            if json_text:sub(i,i) == "}" then last_brace = i; break end
        end
        if first and last_brace then
             json_text = json_text:sub(first, last_brace)
             success, data = pcall(json.decode, json_text)
        end
    end

    if success and data then
        return self:validateAndCleanData(data)
    end
    return nil
end

function AIHelper:validateAndCleanData(data)
    if not data then return nil end
    local strings = self:getFallbackStrings()
    
    local function ensureString(v, d)
        return (type(v) == "string" and #v > 0) and v or d or ""
    end

    -- 1. AUTHOR & BOOK (Smart Match)
    data.book_title = data.book_title or data.title or strings.unknown_book
    data.author = data.author or data.book_author or strings.unknown_author
    data.author_bio = data.author_bio or data.AuthorBio or data.bio or ""
    data.summary = data.summary or data.book_summary or ""

    -- 2. CHARACTERS
    local chars = data.characters or data.Characters or {}
    local valid_chars = {}
    for _, c in ipairs(chars) do
        if type(c) == "table" then
            table.insert(valid_chars, {
                name = ensureString(c.name or c.Name, strings.unnamed_character),
                role = ensureString(c.role or c.Role, strings.not_specified),
                description = ensureString(c.description or c.desc, strings.no_description),
                gender = ensureString(c.gender, ""),
                occupation = ensureString(c.occupation, "")
            })
        end
    end
    data.characters = valid_chars

    -- 3. HISTORICAL FIGURES
    local hists = data.historical_figures or data.historicalFigures or {}
    local valid_hists = {}
    for _, h in ipairs(hists) do
        if type(h) == "table" then
            table.insert(valid_hists, {
                name = ensureString(h.name or h.Name, strings.unnamed_person),
                biography = ensureString(h.biography or h.bio, strings.no_biography),
                role = ensureString(h.role, ""),
                importance_in_book = ensureString(h.importance_in_book or h.importance, "Mentioned in book"),
                context_in_book = ensureString(h.context_in_book or h.context, "Historical reference")
            })
        end
    end
    data.historical_figures = valid_hists

    -- 4. OTHERS
    data.locations = data.locations or {}
    data.themes = data.themes or {}
    data.timeline = data.timeline or {}
    
    return data
end

function AIHelper:setAPIKey(provider, api_key)
    if self.providers[provider] then
        self.providers[provider].api_key = api_key:gsub("%s+", "")
        self:saveAPIKeyToFile(provider, api_key)
        return true
    end
    return false
end

function AIHelper:testAPIKey(provider)
    local provider_config = self.providers[provider]
    
    if not provider_config then
        return false, "Unknown provider"
    end
    
    if not provider_config.api_key or #provider_config.api_key == 0 then
        return false, "AI API Key not set"
    end
    
    if not self:checkNetworkConnectivity() then
        return false, "No internet connection!"
    end
    
    logger.info("AIHelper: Testing", provider, "API key")
    
    local test_prompt = "Test: 'OK'"
    
    if provider == "gemini" then
        local result, error_code, error_msg = self:callGemini(test_prompt, provider_config)
        if result then
            return true, "Success"
        else
            return false, error_msg or ("Error: " .. (error_code or "Unknown"))
        end
        
    elseif provider == "chatgpt" then
        local result, error_code, error_msg = self:callChatGPT(test_prompt, provider_config)
        if result then
            return true, "Success"
        else
            return false, error_msg or ("Error: " .. (error_code or "Unknown"))
        end
    end
    
    return false, "Unsupported provider"
end

return AIHelper
