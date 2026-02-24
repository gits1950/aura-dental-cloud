lines = open('public/index.html', 'r', encoding='utf-8').readlines()
in_script = False
depth = 0
script_start = 0
for i, line in enumerate(lines):
    if '<script>' in line and 'src=' not in line:
        in_script = True
        script_start = i+1
        depth = 0
    elif '</script>' in line:
        if in_script and depth != 0:
            print(f'UNCLOSED BRACES: script block starting line {script_start}, depth={depth} at line {i+1}')
        in_script = False
    elif in_script:
        for ch in line:
            if ch == '{': depth += 1
            elif ch == '}': depth -= 1
print('Done checking all script blocks')