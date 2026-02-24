import re

path = 'public/index.html'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

if "TREATMENT MAPPING INIT START" not in content:

    init_code = '''

  // ===== TREATMENT MAPPING INIT START =====
  if (!state.treatmentMappings) {
    state.treatmentMappings = {
      complaintToTreatments: {},
      complaintToMedicines: {}
    };
  }

  // Example mapping (edit treatment IDs as per your database)
  state.treatmentMappings.complaintToTreatments["Tooth Pain"] = [1, 2];
  state.treatmentMappings.complaintToTreatments["Bleeding Gums"] = [3];
  state.treatmentMappings.complaintToTreatments["Missing Tooth"] = [4, 5];

  state.treatmentMappings.complaintToMedicines["Tooth Pain"] = [
    { name: "Amoxicillin 500mg", dose: "1-0-1", days: 5 },
    { name: "Ibuprofen 400mg", dose: "1-1-1", days: 3 }
  ];

  state.treatmentMappings.complaintToMedicines["Bleeding Gums"] = [
    { name: "Metrogyl 400mg", dose: "1-0-1", days: 5 },
    { name: "Chlorhexidine Mouthwash", dose: "2x daily", days: 7 }
  ];
  // ===== TREATMENT MAPPING INIT END =====

'''

    content = content.replace(
        "function autoSuggestTreatments",
        init_code + "\nfunction autoSuggestTreatments"
    )

with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print("Treatment mapping initialized.")
