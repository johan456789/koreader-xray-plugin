import re
import os

def get_msgids(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    return set(re.findall(r'^msgid\s+"(.*?)"', content, re.MULTILINE))

def check_sync(base_file, target_file):
    base_ids = get_msgids(base_file)
    target_ids = get_msgids(target_file)
    
    # Remove empty msgid "" (the header)
    base_ids.discard("")
    target_ids.discard("")
    
    missing = base_ids - target_ids
    extra = target_ids - base_ids
    
    return missing, extra

base_po = r'c:\Users\jpautz\Documents\ko\koreader-xray-plugin\xray.koplugin\languages\en.po'
langs = ['de', 'fr', 'ru', 'zh_CN']

for lang in langs:
    target_po = rf'c:\Users\jpautz\Documents\ko\koreader-xray-plugin\xray.koplugin\languages\{lang}.po'
    if os.path.exists(target_po):
        missing, extra = check_sync(base_po, target_po)
        print(f"Language: {lang}")
        if not missing and not extra:
            print("  [OK] In sync")
        else:
            if missing:
                print(f"  [MISSING]: {len(missing)} keys")
                for m in sorted(list(missing))[:10]: # show first 10
                    print(f"    - {m}")
            if extra:
                print(f"  [EXTRA]: {len(extra)} keys")
                for e in sorted(list(extra))[:10]:
                    print(f"    - {e}")
    else:
        print(f"Language: {lang} - File not found")
