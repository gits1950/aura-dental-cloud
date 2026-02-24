import re

path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'function autoSuggestTreatments\(complaint\)[\s\S]*?\n\}'

replacement = '''

function autoSuggestTreatments(complaint) {

  if (!complaint || !state.treatmentMappings) return;

  // ===== CLEAR OLD SELECTIONS =====
  document.querySelectorAll('.consult-t-cb').forEach(cb => cb.checked = false);
  state.currentConsultation.selectedTreatments = [];

  const mappings = state.treatmentMappings.complaintToTreatments[complaint];
  if (!mappings) return;

  mappings.forEach(function(tid) {
    const cb = document.querySelector('.consult-t-cb[value="' + tid + '"]');
    if (cb) {
      cb.checked = true;
      const treatment = state.treatments.find(t => t.id === tid);
      if (treatment) {
        state.currentConsultation.selectedTreatments.push(treatment);
      }
    }
  });

  updateConsultationTotal();
  autoSuggestMedicines();
  showToast('? Treatments updated based on complaint');
}
'''

content = re.sub(pattern, replacement, content)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("autoSuggestTreatments upgraded properly.")
