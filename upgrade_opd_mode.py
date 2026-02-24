path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add OPD mode detection inside renderWalkInBooking

if "const isRegisterOPDMode" not in content:
    content = content.replace(
        "function renderWalkInBooking() {",
        """function renderWalkInBooking() {

  const isRegisterOPDMode = window.location.hash === '#register-opd';
"""
    )

# Change heading text dynamically
content = content.replace(
    "Book New Appointment",
    ""
)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Walk-in booking upgraded with OPD mode.")
