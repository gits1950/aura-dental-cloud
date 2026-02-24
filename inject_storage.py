import re

path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'(const diagnosis = document\.getElementById\([^)]+\)\.value\.trim\(\)\.toUpperCase\(\);)'

injection = r"""\1

  // ===== CONSULTATION STORAGE START =====
  if (!state.consultations) state.consultations = [];

  const consultationData = {
    id: Date.now(),
    queueId: c.queueId,
    patientId: c.patientId,
    doctorId: state.currentUser.id,
    chiefComplaint,
    diagnosis,
    selectedTeeth: c.selectedTeeth || [],
    treatments: c.treatments || [],
    medicines: c.medicines || [],
    notes: c.notes || '',
    date: new Date().toISOString()
  };

  state.consultations.push(consultationData);

  const queueEntry = state.doctorQueue.find(q => q.id === c.queueId);
  if (queueEntry) queueEntry.status = 'consulted';

  saveAllData();
  // ===== CONSULTATION STORAGE END =====
"""

content = re.sub(pattern, injection, content)

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Consultation storage safely injected.")
