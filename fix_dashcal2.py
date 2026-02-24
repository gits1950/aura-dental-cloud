lines = open('public/index.html', 'r', encoding='utf-8').readlines()
for i, line in enumerate(lines):
    if 'function dashCalBookDate' in line:
        lines[i] = 'function dashCalBookDate(dateStr) {\n'
        lines[i+1] = '  state.selectedDate = dateStr;\n'
        lines[i+2] = '  window.location.hash = ' + chr(39) + '#walkin' + chr(39) + ';\n'
        lines[i+3] = '  render();\n'
        lines[i+4] = '  showToast(' + chr(39) + 'Date ' + chr(39) + ' + dateStr + ' + chr(39) + ' - Register patient below' + chr(39) + ');\n'
        lines[i+5] = '}\n'
        j = i + 6
        while j < len(lines) and lines[j].strip() != '}': lines[j] = '\n'; j += 1
        if j < len(lines): lines[j] = '\n'
        print('Fixed at line', i+1)
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')