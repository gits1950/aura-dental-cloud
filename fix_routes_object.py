path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add register-opd inside routes object
if "'#register-opd': () => renderWalkInBooking()" not in content:

    content = content.replace(
        "'#walkin': () => renderWalkInBooking ? renderWalkInBooking() : renderDashboard(),",
        "'#walkin': () => renderWalkInBooking ? renderWalkInBooking() : renderDashboard(),\n  '#register-opd': () => renderWalkInBooking ? renderWalkInBooking() : renderDashboard(),"
    )

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Routes object updated correctly.")
