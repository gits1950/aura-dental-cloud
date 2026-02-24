path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

if "console.log('RENDER WALKIN CALLED')" not in content:
    content = content.replace(
        "function renderWalkInBooking() {",
        "function renderWalkInBooking() {\n  console.log('RENDER WALKIN CALLED');"
    )

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print('Debug log injected.')
