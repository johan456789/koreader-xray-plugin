import re

content = 'local fetch_text = is_update and self.loc:t("updating_ai", self.ai_provider or "AI") or self.loc:t("fetching_ai", self.ai_provider or "AI")'
regex = r'loc:t\([\"\'](.*?)[\"\']\)(?:\s*or\s*[\"\'](.*?)[\"\'])?'

matches = re.finditer(regex, content)
for m in matches:
    print(f"Match: '{m.group(0)}', Key: '{m.group(1)}', Default: '{m.group(2)}'")
