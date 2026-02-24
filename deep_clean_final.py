import re

def deep_clean(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Isolate the core HTML structure up to the first script tag
        script_pos = content.find('<script>')
        if script_pos == -1:
            print(f"Error: <script> tag not found in {path}")
            return

        header = content[:script_pos + 8] 
        
        # Extract unique function definitions using regex to remove duplicates
        # This removes the 10+ copies of the same functions causing the bloat
        func_pattern = re.compile(r'function\s+(\w+)\s*\((?:[^)(]+|\((?:[^)(]+|\([^)(]*\))*\))*\)\s*\{(?:[^{}]+|\{(?:[^{}]+|\{[^{}]*\})*\})*\}')
        
        found_functions = {}
        for match in func_pattern.finditer(content):
            name = match.group(1)
            if name not in found_functions:
                found_functions[name] = match.group(0)

        # Surgical Syntax Fix for Line 267 (Calendar Click Error)
        cleaned_js = "\n\n".join(found_functions.values())
        cleaned_js = re.sub(r'onclick="openRegistrationForDate\([^"]+\)"', 
                            'onclick="openRegistrationForDate(\'\')"', cleaned_js)

        # Reconstruct with exactly ONE closing body/html structure
        final_output = header + "\n" + cleaned_js + "\n  </script>\n</body>\n</html>"

        with open(path, 'w', encoding='utf-8', newline='') as f:
            f.write(final_output)
        print(f"? Cleaned {path}: Kept {len(found_functions)} unique functions.")
    except Exception as e:
        print(f"Error processing {path}: {str(e)}")

# Run the clean on both possible locations
deep_clean('index.html')
deep_clean('public/index.html')
