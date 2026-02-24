lines = open('public/index.html', 'r', encoding='utf-8').readlines()
# Find last </script> before </body>
last_script = None
body_line = None
for i, line in enumerate(lines):
    if '</script>' in line:
        last_script = i
    if '</body>' in line:
        body_line = i
        break
print('Orphan JS from line', last_script+2, 'to', body_line)
# Remove orphan JS - keep up to last_script, then jump to body
result = lines[:last_script+1] + lines[body_line:]
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(result)
print('Done! Removed', body_line - last_script - 1, 'orphan lines')