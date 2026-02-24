import re
import os

def fix_html_errors(filename):
    if not os.path.exists(filename):
        print(f"Error: {filename} not found!")
        return

    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix 1: Template literal syntax error near line 267
    # Fixes the broken 'onclick' string concatenation
    pattern1 = r'const onClick = isPast \? \'\' : `onclick="openRegistrationForDate\(\'\$\{dateStr\}\'\)"`;\s+days \+= \'<div \' \+ onClick \+ \' style="\''
    replacement1 = 'const onClick = isPast ? "" : `onclick="openRegistrationForDate(\'${dateStr}\')"` ;\n      days += `<div ${onClick} style="`'
    content = re.sub(pattern1, replacement1, content)

    # Fix 2: Extra closing brace near line 1086
    content = content.replace('input.click();\n}\n}', 'input.click();\n}')

    # Fix 3: Remove duplicated mobile menu blocks at the end (Line 11216)
    mobile_block = r'\(function\(\) \{[\s\S]+?\}\)\(\);'
    found_blocks = re.findall(mobile_block, content)
    if len(found_blocks) > 1:
        content = content.replace(found_blocks[0], "KEEP_THIS_BLOCK")
        content = re.sub(mobile_block, "", content)
        content = content.replace("KEEP_THIS_BLOCK", found_blocks[0])

    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ index.html has been fixed and saved!")

if __name__ == "__main__":
    fix_html_errors("index.html")