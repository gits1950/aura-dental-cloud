import re

FILE = r".\public\index.html"

MOBILE_CSS = """
/* ===== MOBILE RESPONSIVE ===== */
.mobile-menu-btn {
  display: none;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: none;
  border: none;
  cursor: pointer;
  border-radius: 8px;
  color: #374151;
}
.mobile-menu-btn:hover { background: #f3f4f6; }
.mobile-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  z-index: 999;
}
.mobile-overlay.active { display: block; }
@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    z-index: 1000;
    width: 260px !important;
  }
  .sidebar.mobile-open { transform: translateX(0); }
  .mobile-menu-btn { display: flex !important; }
  .header { padding: 10px 12px !important; }
}
"""

MOBILE_JS = """<script>
(function() {
  function fixLayout() {
    var isMobile = window.innerWidth <= 768;
    var main = document.getElementById('main-content') || document.querySelector('.main-content');
    if (main) {
      main.style.marginLeft = isMobile ? '0' : '280px';
      main.style.width = isMobile ? '100%' : '';
    }
    var btn = document.getElementById('mobile-menu-btn');
    if (btn) btn.style.display = isMobile ? 'flex' : 'none';
  }
  function init() {
    fixLayout();
    if (document.getElementById('mobile-overlay')) { fixLayout(); return; }
    var overlay = document.createElement('div');
    overlay.id = 'mobile-overlay';
    overlay.className = 'mobile-overlay';
    overlay.onclick = function() { closeSidebar(); };
    document.body.appendChild(overlay);
    injectBtn();
  }
  function injectBtn() {
    if (document.getElementById('mobile-menu-btn')) return;
    var header = document.querySelector('.header');
    if (!header) return;
    var btn = document.createElement('button');
    btn.id = 'mobile-menu-btn';
    btn.className = 'mobile-menu-btn';
    btn.style.display = window.innerWidth <= 768 ? 'flex' : 'none';
    btn.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#374151" stroke-width="2.5"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
    btn.onclick = toggleSidebar;
    header.insertBefore(btn, header.firstChild);
  }
  function toggleSidebar() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (!s) return;
    var open = s.classList.toggle('mobile-open');
    if (o) o.classList.toggle('active', open);
  }
  function closeSidebar() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (s) s.classList.remove('mobile-open');
    if (o) o.classList.remove('active');
  }
  document.addEventListener('click', function(e) {
    if (window.innerWidth <= 768 && e.target.closest && e.target.closest('.sidebar-item')) {
      setTimeout(closeSidebar, 150);
    }
  });
  window.addEventListener('resize', fixLayout);
  window.addEventListener('hashchange', function() { setTimeout(function(){ init(); fixLayout(); }, 400); });
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { setTimeout(init, 400); });
  } else {
    setTimeout(init, 400);
  }
})();
</script>"""

print("Reading file...")
with open(FILE, 'r', encoding='utf-8') as f:
    content = f.read()
print(f"Loaded {len(content)} chars")

# Remove ALL previously injected mobile CSS/JS blocks
# Remove mobile CSS that got injected in wrong place (inside printWindow.write)
bad_pattern = r"printWindow\.document\.write\('\\n\n/\* ===== MOBILE RESPONSIVE ===== \*/[\s\S]*?'\);"
content, n = re.subn(bad_pattern, "printWindow.document.write('');", content)
print(f"Removed {n} bad CSS injections")

# Remove old <style> mobile blocks
content = re.sub(r'\n/\* ===== MOBILE RESPONSIVE ===== \*/[\s\S]*?</style>', '</style>', content)

# Remove old mobile JS script blocks  
content = re.sub(r'\n<script>\n\(function\(\) \{[\s\S]*?fixLayout[\s\S]*?\}\);\n</script>', '', content)
content = re.sub(r'\n<script>\n\(function\(\) \{[\s\S]*?initMobileMenu[\s\S]*?\}\)\(\);\n</script>', '', content)

print("Cleaned old injections")

# Find the REAL last </style> - must not be inside a string/template
# We look for </style> that appears as actual HTML, not inside JS strings
lines = content.split('\n')
real_style_end = -1
for i in range(len(lines)-1, -1, -1):
    line = lines[i].strip()
    if line == '</style>' or line.startswith('</style>'):
        # Check it's not inside a printWindow or template string context
        # by checking the line doesn't have leading JS chars
        raw = lines[i]
        if not raw.strip().startswith("'") and not raw.strip().startswith('"') and not raw.strip().startswith('`'):
            real_style_end = i
            break

if real_style_end != -1:
    lines.insert(real_style_end, MOBILE_CSS)
    content = '\n'.join(lines)
    print(f"Injected CSS before line {real_style_end}")
else:
    print("WARNING: Could not find safe </style> - injecting in <head>")
    content = content.replace('</head>', f'<style>{MOBILE_CSS}</style>\n</head>', 1)

# Inject JS before </body>
body_end = content.rfind('</body>')
if body_end == -1:
    body_end = content.rfind('</html>')
content = content[:body_end] + '\n' + MOBILE_JS + '\n' + content[body_end:]
print("Injected mobile JS")

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Saved! {len(content)} chars")
print("\nNow run:")
print("  git add public/index.html")
print("  git commit -m 'fix: Mobile CSS in correct place'")
print("  git push origin main")
