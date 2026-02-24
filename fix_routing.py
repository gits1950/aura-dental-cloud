path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

print('Reading file...')

# ---------------------------
# 1. Add new route safely
# ---------------------------

if "case '#register-opd'" not in content:
    content = content.replace(
        "case '#walkin': renderWalkInBooking(); break;",
        "case '#walkin': renderWalkInBooking(); break;\n    case '#register-opd': renderOPDSection(); break;"
    )
    print('Register OPD route added.')
else:
    print('Register OPD route already exists.')

# ---------------------------
# 2. Update calendar redirect
# ---------------------------

content = content.replace(
    "window.location.hash = '#walkin';",
    "window.location.hash = '#register-opd';"
)

print('Calendar redirect updated.')

# ---------------------------
# Save file
# ---------------------------

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print('Routing enhancement complete.')
