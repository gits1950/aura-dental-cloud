FILE = r".\public\index.html"

# This JS fixes the inline margin-left on .main-content for mobile
MOBILE_FIX_JS = """
<script>
(function() {
  function fixMobileLayout() {
    var isMobile = window.innerWidth <= 768;
    var main = document.getElementById('main-content') || document.querySelector('.main-content');
    if (main) {
      main.style.marginLeft = isMobile ? '0' : '280px';
      main.style.width = isMobile ? '100%' : 'calc(100% - 280px)';
    }
    var sidebar = document.querySelector('.sidebar');
    if (sidebar && isMobile) {
      sidebar.style.transform = sidebar.classList.contains('mobile-open') ? 'translateX(0)' : 'translateX(-100%)';
    } else if (sidebar) {
      sidebar.style.transform = '';
    }
  }

  function initMobile() {
    fixMobileLayout();
    if (document.getElementById('mobile-overlay')) return;
    // Add overlay
    var overlay = document.createElement('div');
    overlay.id = 'mobile-overlay';
    overlay.style.cssText = 'display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:999;';
    overlay.onclick = closeMobileMenu;
    document.body.appendChild(overlay);
    injectHamburger();
  }

  function injectHamburger() {
    if (document.getElementById('mobile-menu-btn')) return;
    var header = document.querySelector('.header');
    if (!header) return;
    var btn = document.createElement('button');
    btn.id = 'mobile-menu-btn';
    btn.style.cssText = 'display:' + (window.innerWidth<=768?'flex':'none') + ';align-items:center;justify-content:center;width:40px;height:40px;background:none;border:none;cursor:pointer;border-radius:8px;margin-right:8px;flex-shrink:0;';
    btn.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#374151" stroke-width="2.5"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
    btn.onclick = toggleMobileMenu;
    header.insertBefore(btn, header.firstChild);
  }

  window.toggleMobileMenu = function() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (!s) return;
    var isOpen = s.classList.toggle('mobile-open');
    s.style.transform = isOpen ? 'translateX(0)' : 'translateX(-100%)';
    if (o) o.style.display = isOpen ? 'block' : 'none';
  };

  window.closeMobileMenu = function() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (s) { s.classList.remove('mobile-open'); s.style.transform = 'translateX(-100%)'; }
    if (o) o.style.display = 'none';
  };

  // Close on sidebar item click
  document.addEventListener('click', function(e) {
    if (window.innerWidth <= 768 && e.target.closest && e.target.closest('.sidebar-item')) {
      setTimeout(window.closeMobileMenu, 150);
    }
  });

  // Re-run on resize
  window.addEventListener('resize', fixMobileLayout);

  // Re-run after hash changes (page re-renders)
  window.addEventListener('hashchange', function() {
    setTimeout(function() { initMobile(); fixMobileLayout(); }, 400);
  });

  // Initial run
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { setTimeout(initMobile, 300); });
  } else {
    setTimeout(initMobile, 300);
  }
})();
</script>
"""

print(f"Reading {FILE}...")
try:
    with open(FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars")
except:
    with open(FILE, 'r', encoding='utf-16') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars (utf-16)")

# Remove old mobile script blocks if any
import re
content = re.sub(r'\n<script>\n\(function\(\) \{[\s\S]*?fixMobileLayout[\s\S]*?\}\);\n</script>\n', '', content)
print("Removed old mobile JS if present")

# Inject before </body>
body_end = content.rfind('</body>')
if body_end == -1:
    body_end = content.rfind('</html>')
content = content[:body_end] + MOBILE_FIX_JS + content[body_end:]
print("Injected mobile fix JS")

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Saved! {len(content)} chars")
print("\nNow run:")
print("  git add public/index.html")
print("  git commit -m 'fix: Mobile layout blank screen'")
print("  git push origin main")
