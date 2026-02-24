import re

def rebuild_index(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Extract only the content before the FIRST </body> tag to avoid fragmentation
    new_content = []
    for line in lines:
        if '</body>' in line:
            break
        new_content.append(line)
    
    full_text = "".join(new_content)
    
    # Fix the persistent syntax error at line 267
    full_text = re.sub(r'const onClick = isPast \? \'\' : onclick="openRegistrationForDate\(\'\\\$\{dateStr\}\'\)";', 
                       'const onClick = isPast ? "" : onclick="openRegistrationForDate(\'\')";', full_text)
    
    # Close it properly EXACTLY ONCE
    full_text += "\n</body>\n</html>"
    
    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write(full_text)

rebuild_index('index.html')
rebuild_index('public/index.html')
print('? Rebuilt clean index files in root and public.')
