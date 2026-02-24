lines = open('public/index.html', 'r', encoding='utf-8').readlines()
depth = 0
for i in range(25, 862):
    for ch in lines[i]:
        if ch == '{': depth += 1
        elif ch == '}': depth -= 1
    if depth == 1 and i > 800:
        print('Depth is 1 at line', i+1, ':', lines[i].rstrip())