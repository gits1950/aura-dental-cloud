import re

path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'function dashCalBookDate\(dateStr\)[\s\S]*?\n\}'

replacement = """function dashCalBookDate(dateStr) {
  console.log('Dashboard calendar clicked ? redirecting to OPD');

  // Save selected date globally
  state.selectedDate = dateStr;

  // Close modal if it exists
  const modal = document.getElementById('dashCalModal');
  if (modal) modal.style.display = 'none';

  // Navigate to OPD registration route
  window.location.hash = '#register-opd';

  // Force router execution if required
  if (typeof render === 'function') {
    render();
  }
}
"""

content = re.sub(pattern, replacement, content)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Dashboard calendar now routes directly to OPD page.")
