lines = open('public/index.html', 'r', encoding='utf-8').readlines()
for i, line in enumerate(lines):
    if '// observer removed' in line:
        lines[i] = '// observer removed\n}\n'
        print('Fixed at line', i+1)
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')