path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Inject OPD mode detection once
if "const isOPDMode" not in content:
    content = content.replace(
        "function renderWalkInBooking() {",
        "function renderWalkInBooking() {\n  console.log('RENDER WALKIN CALLED');\n  const isOPDMode = window.location.hash === '#register-opd';"
    )

# Replace static title safely
content = content.replace(
    "Book New Appointment",
    "' + (isOPDMode ? 'Register OPD Patient' : 'Book New Appointment') + '"
)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("OPD mode fully activated.")
