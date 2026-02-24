lines = open('public/index.html', 'r', encoding='utf-8').readlines()
# Remove lines 32 to 861 (0-based) - the incomplete renderCalendar in first script block
# Keep lines 0-31 and 861 onward
before = lines[:32]
after = lines[861:]
result = before + after
open('public/index.html', 'w', encoding='utf-8', newline='').writelines(result)
print('Removed incomplete renderCalendar block, lines 33-861')
print('New file length:', len(result))