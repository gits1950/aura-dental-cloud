lines = open('public/index.html', 'r', encoding='utf-8').readlines()
print('Line 8015:', repr(lines[8014]))
lines[8015] = '           (true || state.currentUser.role === ' + chr(39) + 'admin' + chr(39) + ');\n'
print('Fixed!')
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')