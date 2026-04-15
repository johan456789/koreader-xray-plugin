return {
    -- System instruction
    system_instruction = "You are an expert literary researcher. Your response must be ONLY in valid JSON format. Ensure data is highly accurate and pertains strictly to the provided context.",
    
    -- Main prompt (Full book analysis)
    main = [[Book: "%s" - Author: %s
Create exhaustive X-Ray data for this book. Fill the JSON format COMPLETELY.

CORE RULES:
1. TARGET BOOK: Only include data from THIS book. Use title, author, and context to avoid series-wide spoilers if possible.
2. CHARACTERS: List at least 20-30 characters. Include protagonists, every named supporting character, and notable minor figures.
3. LOCATIONS: List at least 15-20 significant locations.
4. HISTORICAL FIGURES: Identify 5-10 real-world or legendary/in-world historical figures mentioned.
5. DETAILS: Provide rich, factual descriptions (3-4 sentences each).

REQUIRED JSON FORMAT:
{
  "book_title": "Full Book Title",
  "author": "Author Name",
  "author_bio": "Detailed biography.",
  "summary": "Full book summary (overview).",
  "characters": [
    {
      "name": "Full Name",
      "role": "Protagonist / Supporting / Antagonist",
      "gender": "Gender",
      "occupation": "Job/Status",
      "description": "Comprehensive 3-4 sentence analysis including personality, major arcs, and significance."
    }
  ],
  "historical_figures": [
    {
      "name": "Name",
      "role": "Role",
      "biography": "Bio",
      "importance_in_book": "Why they matter here",
      "context_in_book": "Scene/context"
    }
  ],
  "locations": [
    {"name": "Place", "description": "Atmospheric description", "importance": "Narrative significance"}
  ],
  "themes": ["Theme 1", "Theme 2", "Theme 3", "Theme 4", "Theme 5"],
  "timeline": [
    {"event": "Key Plot Point", "chapter": "Chapter", "importance": "Significance"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Book: "%s" - Author: %s
CRITICAL: The reader has only read %d%% of this book. 

DATA SOURCES (USE THESE ONLY):
I have provided 'BOOK TEXT CONTEXT' (up to 100,000 characters) and 'USER HIGHLIGHTS & NOTES'. 
You MUST prioritize this information above your general knowledge of the book.

STRICT SPOILER-FREE RULES (ZERO TOLERANCE):
1. NO EXTERNAL KNOWLEDGE: If a character reveal or plot twist occurs at 50%% and the reader is at %d%%, you MUST NOT mention it, even if you know it from your training data.
2. TEXT-DRIVEN: Use the provided text to describe characters and locations. If the text says a character is a "loyal knight", do not call them a "traitor" because you know how the book ends.
3. ITEM LIMITS: Only include characters introduced BEFORE the %d%% mark (or present in the provided text).
4. DESCRIPTIONS: Must reflect ONLY what is known at %d%%. Do NOT hint at future reveals or use phrases like "later he will..." or "destined to become...".
5. LOCATIONS: Only include locations visited or mentioned in the provided text.
6. PLOT/SUMMARY: The summary and timeline must stop EXACTLY at the %d%% mark.

ITEM COUNT REQUIREMENTS:
1. CHARACTERS: List 15-25 characters encountered in the provided text.
2. LOCATIONS: List 10-15 locations visited/mentioned in the text.
3. TIMELINE: List 10-15 major events that have already occurred in the provided text.

REQUIRED JSON FORMAT:
{
  "book_title": "Book Title",
  "author": "Author Name",
  "author_bio": "Biography",
  "summary": "Summary of ONLY the portion read so far (%d%%). Use the provided context.",
  "characters": [
    {
      "name": "Name",
      "role": "Perceived role at %d%%",
      "gender": "Gender",
      "occupation": "Current occupation",
      "description": "Character status EXACTLY at the %d%% mark based on provided text. ABSOLUTELY NO SPOILERS from later in the book."
    }
  ],
  "historical_figures": [
    {
      "name": "Name",
      "role": "Role",
      "biography": "Bio",
      "importance_in_book": "Significance up to %d%%",
      "context_in_book": "Context of mention"
    }
  ],
  "locations": [
    {"name": "Name", "description": "Description based ONLY on text read so far (%d%%). No spoilers.", "importance": "Significance so far"}
  ],
  "themes": ["Themes apparent up to %d%%"],
  "timeline": [
    {"event": "Event that ALREADY happened in the provided text", "chapter": "Chapter", "importance": "Significance"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Unknown Book",
        unknown_author = "Unknown Author",
        unnamed_character = "Unnamed Character",
        not_specified = "Not Specified",
        no_description = "No Description",
        unnamed_person = "Unnamed Person",
        no_biography = "No Biography Available"
    }
}
