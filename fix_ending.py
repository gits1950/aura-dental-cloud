lines = open('public/index.html', 'r', encoding='utf-8').readlines()
# Find the incomplete service worker block and fix it
for i, line in enumerate(lines):
    if 'serviceWorker' in line and 'register' not in line:
        sw_start = i
        break

# Find where </body> is
for i, line in enumerate(lines):
    if '</body>' in line:
        body_end = i
        break

# Replace from sw_start to end with proper ending
proper_ending = [
    '<script>\n',
    'if (\'serviceWorker\' in navigator) {\n',
    '  window.addEventListener(\'load\', function() {\n',
    '    navigator.serviceWorker.register(\'/service-worker.js\').catch(function(err) {\n',
    '      console.log(\'SW registration failed:\', err);\n',
    '    });\n',
    '  });\n',
    '}\n',
    '</script>\n',
    '</body>\n',
    '</html>\n'
]

result = lines[:sw_start] + proper_ending
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(result)
print('Fixed ending at line', sw_start+1)
print('New length:', len(result))