import re
path = "index.html"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Add a trigger at the very end of the script to start the app
if "document.addEventListener" not in content:
    trigger = "\n<script>\ndocument.addEventListener('DOMContentLoaded', () => {\n  console.log('Force initiating app...');\n  if (typeof render === 'function') render();\n  else if (typeof initApp === 'function') initApp();\n  else console.error('Startup function not found!');\n});\n</script>\n"
    content = content.replace("</body>", trigger + "</body>")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("? Startup trigger added to root index.html")
