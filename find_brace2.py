lines = open('public/index.html', 'r', encoding='utf-8').readlines()
depth = 0
prev = 0
for i in range(25, 862):
    prev = depth
    for ch in lines[i]:
        if ch == '{': depth += 1
        elif ch == '}': depth -= 1
    if prev == 2 and depth == 1:
        print('Depth dropped to 1 at line', i+1, ':', lines[i].rstrip())
    if prev == 0 and depth == 1:
        print('Depth rose to 1 (unclosed open) at line', i+1, ':', lines[i].rstrip())