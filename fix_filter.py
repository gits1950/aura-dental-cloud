lines = open('public/index.html', 'r', encoding='utf-8').readlines()
for i, line in enumerate(lines):
    if 'parseInt(q.doctorId) === parseInt(state.currentUser.id) || !q.doctorId' in line:
        lines[i] = line.replace('parseInt(q.doctorId) === parseInt(state.currentUser.id) || !q.doctorId', 'true')
        print('Fixed at line', i+1)
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(lines)
print('Done!')