lines = open('public/index.html', 'r', encoding='utf-8').readlines()
depth = 0
for i in range(8914, 10135):
    for ch in lines[i]:
        if ch == '{': depth += 1
        elif ch == '}': depth -= 1
    if depth < 0:
        print('Depth went negative at line', i+1, ':', lines[i].rstrip())
        break