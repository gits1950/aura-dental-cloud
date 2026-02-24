lines = open("public/index.html", "r", encoding="utf-8").readlines()

new_func = """function autoSuggestTreatments(complaint) {
  if (!complaint) return;
  var map = {
    "Toothache / Severe Pain": [2, 7, 1],
    "Bleeding Gums": [4, 5, 7],
    "Cavity / Tooth Decay": [1, 2, 7],
    "Missing Tooth": [9, 10, 7],
    "Loose Tooth": [5, 3, 7],
    "Swelling in Gums": [5, 4, 7],
    "Sensitivity (Hot/Cold)": [1, 2, 7],
    "Broken/Chipped Tooth": [1, 8, 7],
    "Stained/Yellow Teeth": [6, 4, 7],
    "Wisdom Tooth Pain": [3, 7],
    "Bad Breath (Halitosis)": [4, 6, 7],
    "Braces / Orthodontic Query": [7],
    "Scaling / Cleaning": [4, 6],
    "Routine Checkup": [7, 4]
  };
  var tids = map[complaint];
  if (!tids) return;
  document.querySelectorAll('.consult-t-cb').forEach(function(cb) { cb.checked = false; });
  if (state.currentConsultation) state.currentConsultation.selectedTreatments = [];
  tids.forEach(function(tid) {
    var cb = document.querySelector('.consult-t-cb[value="' + tid + '"]');
    if (cb) {
      cb.checked = true;
      if (state.currentConsultation) {
        var t = state.treatments.find(function(t) { return t.id === tid; });
        if (t) state.currentConsultation.selectedTreatments.push(t);
      }
    }
  });
  updateConsultationTotal();
  autoSuggestMedicines();
  showToast('Treatments & medicines suggested for: ' + complaint);
}
function autoSuggestMedicines() {
  var medMap = {
    "1": [2, 4], "2": [1, 2, 3, 4], "3": [1, 2, 3, 4],
    "4": [4, 2], "5": [1, 3, 4, 2], "6": [4],
    "7": [2], "8": [1, 2, 4], "9": [1, 2, 3, 4],
    "10": [1, 2, 4], "11": [2, 4]
  };
  var treatmentIds = Array.from(document.querySelectorAll('.consult-t-cb:checked')).map(function(cb) { return cb.value; });
  var medicineIds = new Set();
  treatmentIds.forEach(function(tid) {
    var meds = medMap[tid];
    if (meds) meds.forEach(function(mid) { medicineIds.add(mid); });
  });
  document.querySelectorAll('.consult-m-cb').forEach(function(cb) { cb.checked = false; });
  if (state.currentConsultation) state.currentConsultation.selectedMedicines = [];
  medicineIds.forEach(function(mid) {
    var cb = document.querySelector('.consult-m-cb[value="' + mid + '"]');
    if (cb) {
      cb.checked = true;
      if (state.currentConsultation) {
        var m = state.medicines.find(function(m) { return m.id === mid; });
        if (m) state.currentConsultation.selectedMedicines.push(m);
      }
    }
  });
}
"""

# Find and replace both functions
start = None
end = None
for i, line in enumerate(lines):
    if "function autoSuggestTreatments" in line and start is None:
        start = i
    if start is not None and "function updateConsultationTotal" in line:
        end = i
        break

if start and end:
    lines[start:end] = [new_func]
    print("Replaced functions from line", start+1, "to", end)
else:
    print("Not found! start:", start, "end:", end)

open("public/index.html", "w", encoding="utf-8", newline="").writelines(lines)
print("Done!")