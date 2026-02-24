path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add test comment at top
if '<!-- CLOUD TEST -->' not in content:
    content = '<!-- CLOUD TEST -->\n' + content

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print('TEST INJECTION DONE')
