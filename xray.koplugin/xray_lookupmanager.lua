-- LookupManager - Core logic for text selection lookups
local logger = require("logger")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")

local LookupManager = {}

function LookupManager:new(plugin)
    local o = {
        plugin = plugin
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Clean and normalize text for comparison
function LookupManager:normalize(text)
    if not text then return "" end
    -- Remove non-alphanumeric characters from start/end and lowercase
    local clean = text:gsub("^[^%w]+", ""):gsub("[^%w]+$", ""):lower()
    return clean
end

-- Perform a robust lookup against all categories
function LookupManager:lookup(text)
    if not text or text == "" then return nil end
    local query = self:normalize(text)
    if #query < 2 then return nil end

    -- Categories to search
    local categories = {
        { list = self.plugin.characters, type = "character" },
        { list = self.plugin.historical_figures, type = "historical" },
        { list = self.plugin.locations, type = "location" }
    }

    -- Pass 1: Exact Match (Highest Priority)
    for _, cat in ipairs(categories) do
        if cat.list then
            for _, item in ipairs(cat.list) do
                if item.name and self:normalize(item.name) == query then
                    return item, cat.type
                end
            end
        end
    end

    -- Pass 2: Selection contains a full character name (e.g. "He saw Annabeth" contains "Annabeth")
    -- We only match names that are at least 3 characters long to avoid false positives with "He", "At", etc.
    for _, cat in ipairs(categories) do
        if cat.list then
            for _, item in ipairs(cat.list) do
                if item.name then
                    local name = self:normalize(item.name)
                    if #name >= 3 and query:find(name, 1, true) then
                        return item, cat.type
                    end
                end
            end
        end
    end

    -- Pass 3: Character name contains the selection (e.g. "Annabeth" matches "Annabeth Chase")
    for _, cat in ipairs(categories) do
        if cat.list then
            for _, item in ipairs(cat.list) do
                if item.name then
                    local name = self:normalize(item.name)
                    if name:find(query, 1, true) then
                        return item, cat.type
                    end
                end
            end
        end
    end

    -- Pass 4: Keyword matching (Split selection into words and check if any word matches a name)
    local words = {}
    for word in query:gmatch("[%w%z\128-\255]+") do -- Support UTF-8 characters
        if #word >= 3 then
            table.insert(words, word)
        end
    end

    if #words > 0 then
        for _, cat in ipairs(categories) do
            if cat.list then
                for _, item in ipairs(cat.list) do
                    if item.name then
                        local name = self:normalize(item.name)
                        for _, w in ipairs(words) do
                            -- Check if this keyword is a significant part of the name
                            if name == w or name:find("^" .. w .. " ") or name:find(" " .. w .. "$") or name:find(" " .. w .. " ") then
                                return item, cat.type
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- Handle the UI part of the lookup
function LookupManager:handleLookup(text)
    if not text or text == "" then return end
    
    local match, match_type = self:lookup(text)
    
    if match then
        if match_type == "character" then
            self.plugin:showCharacterDetails(match)
        elseif match_type == "historical" then
            local name = match.name or "???"
            local bio = match.biography or "No biography available."
            UIManager:show(InfoMessage:new{ text = name .. "\n\n" .. bio, timeout = 15 })
        elseif match_type == "location" then
            local name = match.name or "???"
            local desc = match.description or ""
            UIManager:show(InfoMessage:new{ text = name .. "\n\n" .. desc, timeout = 10 })
        end
    else
        -- Check if cache is completely empty
        local has_data = (self.plugin.characters and #self.plugin.characters > 0) or
                         (self.plugin.historical_figures and #self.plugin.historical_figures > 0) or
                         (self.plugin.locations and #self.plugin.locations > 0)
        
        if not has_data then
            local ConfirmBox = require("ui/widget/confirmbox")
            local no_data_dialog
            no_data_dialog = ConfirmBox:new{
                text = self.plugin.loc:t("no_data_prompt"),
                ok_text = self.plugin.loc:t("fetch_button") or "Fetch",
                cancel_text = self.plugin.loc:t("close") or "Close",
                ok_callback = function()
                    self.plugin:fetchFromAI()
                end,
                cancel_callback = function()
                    UIManager:close(no_data_dialog)
                end
            }
            UIManager:show(no_data_dialog)
        else
            UIManager:show(InfoMessage:new{ 
                text = string.format("No X-Ray data found for '%s'", text:sub(1, 30)), 
                timeout = 3 
            })
        end
    end
end

return LookupManager
