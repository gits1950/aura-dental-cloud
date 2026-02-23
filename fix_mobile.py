import sys

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
  .sidebar.mobile-open {
    transform: translateX(0);
  }
  .main-content {
    margin-left: 0 !important;
    width: 100% !important;
  }
  .sidebar-logo {
    font-size: 15px !important;
    padding: 0 12px 16px 12px !important;
    overflow: hidden !important;
  }
  .sidebar-logo img, .sidebar-logo svg {
    width: 28px !important;
    height: 28px !important;
    max-width: 28px !important;
    flex-shrink: 0 !important;
  }
  .mobile-menu-btn {
    display: flex !important;
  }
  .header {
    padding: 10px 12px !important;
  }
  .stats-grid {
    grid-template-columns: 1fr 1fr !important;
    gap: 10px !important;
  }
  .page-title { font-size: 18px !important; }
}
@media (max-width: 480px) {
  .stats-grid { grid-template-columns: 1fr !important; }
}
"""

MOBILE_JS = """
(function() {
  function initMobileMenu() {
    if (document.getElementById('mobile-overlay')) return;
    var overlay = document.createElement('div');
    overlay.id = 'mobile-overlay';
    overlay.className = 'mobile-overlay';
    overlay.onclick = closeMobileMenu;
    document.body.appendChild(overlay);
    injectHamburger();
  }
  function injectHamburger() {
    var header = document.querySelector('.header');
    if (!header || document.getElementById('mobile-menu-btn')) return;
    var btn = document.createElement('button');
    btn.id = 'mobile-menu-btn';
    btn.className = 'mobile-menu-btn';
    btn.innerHTML = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
    btn.onclick = toggleMobileMenu;
    header.insertBefore(btn, header.firstChild);
  }
  window.toggleMobileMenu = function() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (s) s.classList.toggle('mobile-open');
    if (o) o.classList.toggle('active');
  };
  window.closeMobileMenu = function() {
    var s = document.querySelector('.sidebar');
    var o = document.getElementById('mobile-overlay');
    if (s) s.classList.remove('mobile-open');
    if (o) o.classList.remove('active');
  };
  document.addEventListener('click', function(e) {
    if (window.innerWidth <= 768 && e.target.closest && e.target.closest('.sidebar-item')) {
      setTimeout(window.closeMobileMenu, 150);
    }
  });
  var _orig = window.renderDashboard;
  function afterRender() { setTimeout(initMobileMenu, 100); }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { setTimeout(initMobileMenu, 500); });
  } else {
    setTimeout(initMobileMenu, 500);
  }
  // Re-inject hamburger after any hash change
  window.addEventListener('hashchange', function() { setTimeout(injectHamburger, 300); });
})();
"""

print(f"Reading {FILE}...")
try:
    with open(FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars (utf-8)")
except:
    with open(FILE, 'r', encoding='utf-16') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars (utf-16)")

# Inject CSS before last </style>
style_end = content.rfind('</style>')
if style_end != -1:
    content = content[:style_end] + MOBILE_CSS + content[style_end:]
    print("Injected mobile CSS")
else:
    print("WARNING: no </style> found")

# Inject JS before </body>
body_end = content.rfind('</body>')
if body_end == -1:
    body_end = content.rfind('</html>')
content = content[:body_end] + '\n<script>\n' + MOBILE_JS + '\n</script>\n' + content[body_end:]
print("Injected mobile JS")

with open(FILE, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Saved! {len(content)} chars")
print("\nNow run:")
print("  git add public/index.html")
print("  git commit -m 'feat: Mobile responsive sidebar and logo fix'")
print("  git push origin main")
