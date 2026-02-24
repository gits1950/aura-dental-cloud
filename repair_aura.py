import re

def fix_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Fix the template literal error (Line 267)
    content = re.sub(r'const onClick = isPast \? \'\' : onclick="openRegistrationForDate\(\'\\\$\{dateStr\}\'\)";', 
                     'const onClick = isPast ? "" : onclick="openRegistrationForDate(\'\')";', content)
    
    # 2. Consolidate: Remove extra </body> and </html> tags except the last ones
    content = content.replace('</body>', '').replace('</html>', '')
    content += '\n</body>\n</html>'

    # 3. Fix the "Unexpected token }" by balancing trailing braces
    # This specifically targets the common 'input.click(); } }' error
    content = content.replace('input.click();\n}\n}', 'input.click();\n}')

    with open(file_path, 'w', encoding='utf-8', newline='') as f:
        f.write(content)
    print(f"? Cleaned {file_path}")

fix_file('index.html')
fix_file('public/index.html')
