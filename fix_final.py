lines = open('public/index.html', 'r', encoding='utf-8').readlines()
print('Line 8081:', repr(lines[8081]))
lines[8081] = '           (true);\n'
print('Fixed!')
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')