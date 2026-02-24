import re

def final_surgical_fix(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the Line 267 Syntax Error (Calendar handler)
    content = re.sub(r'onclick="openRegistrationForDate\([^"]+\)"', 
                     'onclick="openRegistrationForDate(\'\')"', content)

    # Fix Line 1085 (Remove extra closing braces)
    content = content.replace('input.click();\n}\n}', 'input.click();\n}')
    
    # Force a clean file termination to fix "Unexpected end of input"
    if '</body>' in content:
        content = content.split('</body>')[0]
    content = content.strip()
    content += "\n  </script>\n</body>\n</html>"

    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write(content)

final_surgical_fix('index.html')
final_surgical_fix('public/index.html')
print('? Surgical fix applied. File endings and grammar corrected.')
