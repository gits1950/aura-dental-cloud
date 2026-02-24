import re

path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# --- Locate saveConsultationForm ---
pattern = r'function saveConsultationForm\(\)\s*\{'

if not re.search(pattern, content):
    print("saveConsultationForm not found!")
    exit()

# Wiring block to inject at top of function
injection = """

  // ===== CONSULTATION DATA WIRING START =====
  if (!state.consultations) state.consultations = [];

  if (!state.activeConsultation) {
    alert("No active consultation found.");
    return;
  }

  const chiefComplaint =
    document.getElementById('chiefComplaint')?.value || '';

  const diagnosis =
    document.getElementById('diagnosis')?.value || '';

  const notes =
    document.getElementById('consultNotes')?.value || '';

  const suggestedTreatments = [];
  document.querySelectorAll('.treatment-checkbox:checked')
    .forEach(cb => suggestedTreatments.push(cb.value));

  const medicines = [];
  document.querySelectorAll('.medicine-row').forEach(row => {
    medicines.push({
      name: row.querySelector('.med-name')?.value || '',
      dose: row.querySelector('.med-dose')?.value || '',
      days: row.querySelector('.med-days')?.value || ''
    });
  });

  const consultationData = {
    id: Date.now(),
    queueId: state.activeConsultation.queueId,
    patientId: state.activeConsultation.patientId,
    doctorId: state.activeConsultation.doctorId,
    chiefComplaint,
    diagnosis,
    suggestedTreatments,
    medicines,
    notes,
    date: new Date().toISOString()
  };

  state.consultations.push(consultationData);

  const queueItem = state.doctorQueue.find(
    q => q.id === state.activeConsultation.queueId
  );

  if (queueItem) {
    queueItem.status = 'consulted';
  }

  saveData();
  // ===== CONSULTATION DATA WIRING END =====

"""

# Inject right after function declaration
content = re.sub(pattern, lambda m: m.group(0) + injection, content)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Consultation wiring injected successfully.")
