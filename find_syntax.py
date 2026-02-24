lines = open('public/index.html', 'r', encoding='utf-8').readlines()
depth = 0
for i in range(25, 862):
    for ch in lines[i]:
        if ch == '{': depth += 1
        elif ch == '}': depth -= 1
print('Brace depth at end of first script block:', depth)
print('(Should be 0 - if not, there are unclosed braces)')