path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove test marker
content = content.replace('<!-- CLOUD TEST -->', '')

calendar_block = """

/* ===== AURA DENTAL CLOUD CALENDAR ===== */

if (!state.calendar) {
  const now = new Date();
  state.calendar = {
    month: now.getMonth(),
    year: now.getFullYear()
  };
}

function openRegistrationForDate(dateStr) {
  state.selectedDate = dateStr;
  window.location.hash = '#walkin';
  if (typeof render === 'function') render();

  setTimeout(function () {
    const dateInput =
      document.getElementById('appointment-date') ||
      document.querySelector('input[type="date"]');
    if (dateInput) {
      dateInput.value = dateStr;
      dateInput.dispatchEvent(new Event('change'));
    }
  }, 200);
}

"""

if "AURA DENTAL CLOUD CALENDAR" not in content:
    content = content + calendar_block

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Cloud Calendar Core Injected")
