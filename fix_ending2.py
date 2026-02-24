lines = open('public/index.html', 'r', encoding='utf-8').readlines()
last_script_close = None
body_line = None
for i, line in enumerate(lines):
    if '</script>' in line:
        last_script_close = i
    if '</body>' in line:
        body_line = i
        break
print('Last </script> at line:', last_script_close+1)
print('</body> at line:', body_line+1)
print('Lines between:', lines[last_script_close+1:body_line])