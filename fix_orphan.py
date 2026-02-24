lines = open('public/index.html', 'r', encoding='utf-8').readlines()
result = []
i = 0
removed = 0
while i < len(lines):
    if i+1 < len(lines) and lines[i].strip() == '}, 100);' and lines[i+1].strip() == '}':
        removed += 1
        i += 2
    else:
        result.append(lines[i])
        i += 1
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(result)
print('Removed', removed, 'orphan blocks')