lines = open('public/index.html', 'r', encoding='utf-8').readlines()
for i, line in enumerate(lines):
    if 'const observer = new MutationObserver' in line and line.strip() == 'const observer = new MutationObserver':
        lines[i] = '// observer removed\n'
        print('Fixed incomplete MutationObserver at line', i+1)
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')