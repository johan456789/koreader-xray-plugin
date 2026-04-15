-- ChapterAnalyzer - Analyze which characters appear in current chapter/page
local logger = require("logger")

local ChapterAnalyzer = {}

function ChapterAnalyzer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Get current chapter/section text
function ChapterAnalyzer:getCurrentChapterText(ui)
    if not ui or not ui.document then
        logger.warn("ChapterAnalyzer: No document available")
        return nil
    end
    
    -- Check if it's a reflowable document (EPUB, etc.) or page-based (PDF, etc.)
    local is_reflowable = ui.rolling ~= nil
    local is_paged = ui.paging ~= nil
    
    logger.info("ChapterAnalyzer: Reflowable:", is_reflowable, "Paged:", is_paged)
    
    if is_reflowable then
        return self:getReflowableText(ui)
    elseif is_paged then
        return self:getPageBasedText(ui)
    else
        logger.warn("ChapterAnalyzer: Unknown document type")
        return self:getFallbackText(ui)
    end
end

-- Get text from reflowable documents (EPUB, HTML, FB2)
function ChapterAnalyzer:getReflowableText(ui)
    -- Get current position - different methods for different versions
    local current_pos = nil
    
    -- Try different methods to get current position
    if ui.rolling.current_page then
        current_pos = ui.rolling.current_page
    elseif ui.rolling.getCurrentPos then
        current_pos = ui.rolling:getCurrentPos()
    elseif ui.document.getCurrentPos then
        current_pos = ui.document:getCurrentPos()
    elseif ui.view and ui.view.state and ui.view.state.page then
        current_pos = ui.view.state.page
    else
        -- Last resort: use page 1
        current_pos = 1
    end
    
    logger.info("ChapterAnalyzer: Current position:", current_pos)
    
    -- Try to get chapter from TOC
    local toc = ui.document:getToc()
    local default_chapter_title = ui.loc and ui.loc:t("this_chapter") or "This Chapter"
    if not toc or #toc == 0 then
        logger.info("ChapterAnalyzer: No TOC, using visible text")
        return self:getVisibleTextReflowable(ui), default_chapter_title
    end
    
    -- Find current chapter
    local current_chapter = nil
    local chapter_title = default_chapter_title
    
    for i, chapter in ipairs(toc) do
        if chapter.page <= current_pos then
            current_chapter = chapter
            chapter_title = chapter.title or default_chapter_title
        else
            break
        end
    end
    
    if not current_chapter then
        logger.warn("ChapterAnalyzer: No current chapter found")
        return self:getVisibleTextReflowable(ui), default_chapter_title
    end
    
    logger.info("ChapterAnalyzer: Current chapter:", chapter_title)
    
    -- For EPUB, we'll try to get text from the document
    -- Method 1: Try getTextFromPositions if available
    local text = ""
    local text_length = 50000  -- ~50k characters
    
    if ui.document.getTextFromPositions then
        local success, result = pcall(function()
            return ui.document:getTextFromPositions(current_pos, current_pos + text_length)
        end)
        
        if success and result and #result > 100 then
            text = result
            logger.info("ChapterAnalyzer: Got", #text, "characters from positions")
            return text, chapter_title
        end
    end
    
    -- Method 2: Try to extract text from current chapter xpointer
    if ui.document.getTextFromXPointer and current_chapter.xpointer then
        local success, result = pcall(function()
            return ui.document:getTextFromXPointer(current_chapter.xpointer)
        end)
        
        if success and result and #result > 100 then
            text = result
            logger.info("ChapterAnalyzer: Got", #text, "characters from xpointer")
            return text, chapter_title
        end
    end
    
    -- Method 3: Get visible text (fallback)
    text = self:getVisibleTextReflowable(ui)
    logger.info("ChapterAnalyzer: Using visible text fallback")
    
    return text, chapter_title
end

-- Get currently visible text (reflowable)
function ChapterAnalyzer:getVisibleTextReflowable(ui)
    -- Try multiple methods to get text
    local text = ""
    
    -- Method 1: Try getting text from view
    if ui.view and ui.view.document and ui.view.document.extractText then
        local success, result = pcall(function()
            return ui.view.document:extractText()
        end)
        if success and result and #result > 100 then
            logger.info("ChapterAnalyzer: Got text from view.document.extractText")
            return result
        end
    end
    
    -- Method 2: Try document getFullText
    if ui.document.getFullText then
        local success, result = pcall(function()
            return ui.document:getFullText()
        end)
        if success and result and #result > 100 then
            logger.info("ChapterAnalyzer: Got text from getFullText")
            -- Limit size
            if #result > 100000 then
                result = string.sub(result, 1, 100000)
            end
            return result
        end
    end
    
    -- Method 3: Try to read from pages (if document has pages)
    if ui.document.getPageCount and ui.document.getPageText then
        local page_count = ui.document:getPageCount()
        local max_pages = math.min(page_count, 50)
        
        for i = 1, max_pages do
            local success, page_text = pcall(function()
                return ui.document:getPageText(i)
            end)
            if success and page_text then
                text = text .. " " .. page_text
            end
        end
        
        if #text > 100 then
            logger.info("ChapterAnalyzer: Got text from pages")
            return text
        end
    end
    
    -- If nothing worked, return empty
    logger.warn("ChapterAnalyzer: Could not extract any text")
    return ""
end

-- Get text from page-based documents (PDF, DJVU)
function ChapterAnalyzer:getPageBasedText(ui)
    -- Try to get chapter from TOC
    local toc = ui.document:getToc()
    if not toc or #toc == 0 then
        logger.info("ChapterAnalyzer: No TOC, using current page only")
        return self:getCurrentPageTextPDF(ui)
    end
    
    -- Find current chapter based on page
    local current_page = ui.paging:getCurrentPage()
    local current_chapter = nil
    local next_chapter = nil
    
    for i, chapter in ipairs(toc) do
        if chapter.page <= current_page then
            current_chapter = chapter
            if i < #toc then
                next_chapter = toc[i + 1]
            end
        else
            break
        end
    end
    
    if not current_chapter then
        logger.warn("ChapterAnalyzer: No current chapter found")
        return self:getCurrentPageTextPDF(ui)
    end
    
    logger.info("ChapterAnalyzer: Current chapter:", current_chapter.title)
    
    -- Get text from current chapter start to next chapter start (or end)
    local start_page = current_chapter.page
    local end_page = next_chapter and next_chapter.page - 1 or ui.document:getPageCount()
    
    -- Limit to reasonable range (max 50 pages for performance)
    if end_page - start_page > 50 then
        end_page = start_page + 50
        logger.info("ChapterAnalyzer: Limited to 50 pages for performance")
    end
    
    logger.info("ChapterAnalyzer: Analyzing pages", start_page, "to", end_page)
    
    -- Collect text from pages
    local chapter_text = ""
    for page = start_page, end_page do
        local page_text = ui.document:getPageText(page)
        if page_text then
            chapter_text = chapter_text .. " " .. page_text
        end
    end
    
    return chapter_text, current_chapter.title
end

-- Get current page text (PDF/page-based) - fallback
function ChapterAnalyzer:getCurrentPageTextPDF(ui)
    local current_page = ui.paging:getCurrentPage()
    
    -- Try to get text from current page and next few pages
    local text = ""
    for i = 0, 4 do  -- Current + 4 pages
        local page = current_page + i
        if page <= ui.document:getPageCount() then
            local page_text = ui.document:getPageText(page)
            if page_text then
                text = text .. " " .. page_text
            end
        end
    end
    
    local default_page_title = ui.loc and ui.loc:t("this_page") or "This Page"
    return text, default_page_title
end

-- Fallback for unknown document types
function ChapterAnalyzer:getFallbackText(ui)
    logger.warn("ChapterAnalyzer: Using fallback text extraction")
    
    -- Try different methods
    local text = ""
    
    -- Method 1: Try to get selection text or visible text
    if ui.highlight and ui.highlight.selected_text then
        text = ui.highlight.selected_text.text or ""
    end
    
    -- Method 2: Try document getTextFromPositions if available
    if #text < 100 and ui.document.getTextFromPositions then
        local success, result = pcall(function()
            return ui.document:getTextFromPositions(0, 10000)
        end)
        if success and result then
            text = result
        end
    end
    
    -- Method 3: Just show a message
    if #text < 100 then
        logger.warn("ChapterAnalyzer: Could not extract text")
        return nil, nil
    end
    
    local default_page_title = ui.loc and ui.loc:t("this_page") or "This Page"
    return text, default_page_title
end

-- Find characters mentioned in text
function ChapterAnalyzer:findCharactersInText(text, characters)
    if not text or not characters then
        return {}
    end
    
    local found_characters = {}
    local text_lower = string.lower(text)
    
    for _, char in ipairs(characters) do
        local name = char.name
        if name and #name > 2 then
            -- Check full name
            local name_lower = string.lower(name)
            if string.find(text_lower, name_lower, 1, true) then
                table.insert(found_characters, {
                    character = char,
                    count = self:countMentions(text_lower, name_lower)
                })
            else
                -- Check first name only
                local first_name = string.match(name, "^(%S+)")
                if first_name and #first_name > 2 then
                    local first_name_lower = string.lower(first_name)
                    if string.find(text_lower, first_name_lower, 1, true) then
                        table.insert(found_characters, {
                            character = char,
                            count = self:countMentions(text_lower, first_name_lower)
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by mention count
    table.sort(found_characters, function(a, b)
        return a.count > b.count
    end)
    
    logger.info("ChapterAnalyzer: Found", #found_characters, "characters in text")
    
    return found_characters
end

-- Count how many times a name appears
-- Get text for analysis (from beginning to current position)
function ChapterAnalyzer:getTextForAnalysis(ui, max_len)
    if not ui or not ui.document then
        return nil
    end
    
    max_len = max_len or 100000 -- Match assistant.koplugin's 100k default
    local book_text = ""
    
    -- Check if it's a reflowable document (EPUB, etc.)
    local is_reflowable = ui.rolling ~= nil
    
    if is_reflowable then
        local current_xp = ui.document:getXPointer()
        if not current_xp then return nil end
        
        -- Start from beginning
        ui.document:gotoPos(0)
        local start_xp = ui.document:getXPointer()
        
        -- Go back to current position
        ui.document:gotoXPointer(current_xp)
        
        -- Extract text
        local success, result = pcall(function()
            return ui.document:getTextFromXPointers(start_xp, current_xp)
        end)
        
        if success and result then
            book_text = result
        end
    else
        -- For page-based documents, get text from start to current page
        local current_page = ui.view.state.page
        local total_pages = ui.document:getPageCount()
        
        -- assistant.koplugin uses 250 pages max for PDFs
        local max_pages = 250
        local start_page = math.max(1, current_page - max_pages)
        
        for page = start_page, current_page do
            local page_text = ui.document:getPageText(page) or ""
            if type(page_text) == "table" then
                -- Handle structured text if returned
                local texts = {}
                for _, block in ipairs(page_text) do
                    if type(block) == "table" then
                        for i = 1, #block do
                            local span = block[i]
                            if type(span) == "table" and span.word then
                                table.insert(texts, span.word)
                            end
                        end
                    end
                end
                page_text = table.concat(texts, " ")
            end
            book_text = book_text .. page_text .. "\n"
        end
    end
    
    -- Limit text length
    if #book_text > max_len then
        -- For spoiler-free context, the part LEADING UP to the current position is most important.
        -- We take the LAST max_len characters of what we've extracted (which ends at current position).
        book_text = book_text:sub(-max_len)
    end
    
    return book_text
end

-- Get highlights and notes for analysis
function ChapterAnalyzer:getAnnotationsForAnalysis(ui)
    local annotations_text = ""
    
    -- Try to get annotations from the document/UI
    -- In KOReader, annotations are typically in ui.annotation.annotations
    if ui.annotation and ui.annotation.annotations then
        for _, annot in ipairs(ui.annotation.annotations) do
            if annot.text and #annot.text > 0 then
                annotations_text = annotations_text .. "Highlight: " .. annot.text .. "\n"
            end
            if annot.note and #annot.note > 0 then
                annotations_text = annotations_text .. "Note: " .. annot.note .. "\n"
            end
        end
    end
    
    return #annotations_text > 0 and annotations_text or nil
end

function ChapterAnalyzer:countMentions(text, name)
    local count = 0
    local pos = 1
    
    while true do
        local start_pos = string.find(text, name, pos, true)
        if not start_pos then break end
        count = count + 1
        pos = start_pos + 1
    end
    
    return count
end

return ChapterAnalyzer
