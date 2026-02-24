import re

def master_repair(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Fix the Line 267 Syntax Error (Template Literal)
    # Target: onclick="openRegistrationForDate('')"
    content = re.sub(r'onclick="openRegistrationForDate\(\\\'\\\$\{dateStr\}\'\\\)"', 
                     'onclick="openRegistrationForDate(\'\')"', content)
    content = re.sub(r'onclick="openRegistrationForDate\(\'\\\$\{dateStr\}\'\)"', 
                     'onclick="openRegistrationForDate(\'\')"', content)

    # 2. Fix Line 1085 (Extra closing brace)
    # Search for common double-closing braces in the file management area
    content = content.replace('input.click();\n}\n}', 'input.click();\n}')
    
    # 3. Fix Fragmentation (Remove all existing closing tags and add ONE clean set)
    content = content.replace('</body>', '').replace('</html>', '')
    content = content.strip() + "\n  </script>\n</body>\n</html>"

    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write(content)

master_repair('index.html')
master_repair('public/index.html')
print('? Master Repair Complete. Line 267 and 1085 errors addressed.')
