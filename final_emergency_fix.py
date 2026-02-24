import re
path = "index.html"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix the template literal error at line 267
content = re.sub(r'const onClick = isPast \? \'\' : onclick="openRegistrationForDate\(\'\$\{dateStr\}\'\)";', 
                 'const onClick = isPast ? "" : onclick="openRegistrationForDate(\'\')";', content)

# Fix common extra braces
content = content.replace('}\n}\n}', '}\n}')

with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(content)
print("? Root index.html grammar corrected.")
