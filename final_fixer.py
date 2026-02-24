import re
import os

path = "public/index.html"
if not os.path.exists(path):
    path = "index.html" # Fallback if not in public folder

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Fix Line 267: Syntax Error in template literal
pattern1 = r'const onClick = isPast \? \'\' : onclick="openRegistrationForDate\(\'\$\{dateStr\}\'\)";\s+days \+= \'<div \' \+ onClick \+ \' style="\''
replacement1 = 'const onClick = isPast ? "" : onclick="openRegistrationForDate(\'\')" ;\n      days += <div  style="'
content = re.sub(pattern1, replacement1, content)

# 2. Fix Line 1086: Extra closing brace
content = content.replace('input.click();\n}\n}', 'input.click();\n}')

# 3. Fix Line 11216: Duplicate mobile menu blocks
mobile_block = r'\(function\(\) \{[\s\S]+?\}\)\(\);'
found = re.findall(mobile_block, content)
if len(found) > 1:
    content = content.replace(found[0], "KEEP_BLOCK")
    content = re.sub(mobile_block, "", content)
    content = content.replace("KEEP_BLOCK", found[0])

with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(content)

print("? Specific Syntax Errors Fixed.")
