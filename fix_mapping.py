lines = open("public/index.html", "r", encoding="utf-8").readlines()

mapping_js = """  treatmentMappings: {
    complaintToTreatments: {
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
    },
    treatmentToMedicines: {
      "1": [2, 4],
      "2": [1, 2, 3, 4],
      "3": [1, 2, 3, 4],
      "4": [4, 2],
      "5": [1, 3, 4, 2],
      "6": [4],
      "7": [2],
      "8": [1, 2, 4],
      "9": [1, 2, 3, 4],
      "10": [1, 2, 4],
      "11": [2, 4]
    }
  },
"""

for i, line in enumerate(lines):
    if "appointments: []," in line:
        lines.insert(i + 1, mapping_js)
        print("Inserted mapping after appointments at line", i+1)
        break

open("public/index.html", "w", encoding="utf-8", newline="").writelines(lines)
print("Done!")