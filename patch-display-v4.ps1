# ============================================================
# Aura Dental - Fix garbled emojis in display screen
# Uses CSS shapes instead of emojis - encoding safe
# ============================================================

$filePath = ".\public\index.html"
if (-not (Test-Path $filePath)) { Write-Host "ERROR: file not found" -ForegroundColor Red; exit }

# Read as bytes then decode properly
$bytes = [System.IO.File]::ReadAllBytes($filePath)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

Write-Host "File loaded: $($content.Length) chars" -ForegroundColor Cyan

# Find the display function
$dispStart = $content.IndexOf("function renderDisplayScreen() {")
if ($dispStart -eq -1) { Write-Host "ERROR: display function not found" -ForegroundColor Red; exit }

$dispEnd = $content.IndexOf("`nfunction approveBooking(", $dispStart)
if ($dispEnd -eq -1) { $dispEnd = $content.IndexOf("`r`nfunction approveBooking(", $dispStart) }
if ($dispEnd -eq -1) { Write-Host "ERROR: end boundary not found" -ForegroundColor Red; exit }

Write-Host "Found display function: $dispStart to $dispEnd" -ForegroundColor Yellow

# New display function - zero emojis, pure CSS/HTML entities
$newFunc = "function renderDisplayScreen() {" + [char]10 +
"  var app = document.getElementById('app');" + [char]10 +
"  if (!app) return;" + [char]10 +
"  var queue   = state.doctorQueue  || [];" + [char]10 +
"  var chairs  = state.chairs       || [];" + [char]10 +
"  var pts     = state.patients     || [];" + [char]10 +
"  var doctors = state.doctors      || [];" + [char]10 +
"  var cfg     = state.config       || {};" + [char]10 +
"  var waiting    = queue.filter(function(q){ return q.status === 'waiting'; });" + [char]10 +
"  var withDoctor = queue.filter(function(q){ return q.status === 'with-doctor' || q.status === 'in-consultation'; });" + [char]10 +
"  var chairList = chairs.length ? chairs : [{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'},{id:4,name:'Chair 4'},{id:5,name:'Chair 5'},{id:6,name:'Chair 6'}];" + [char]10 +
"  var dotGreen = '<span style=""display:inline-block;width:22px;height:22px;background:#22c55e;border-radius:50%;border:3px solid rgba(255,255,255,0.4);""></span>';" + [char]10 +
"  var dotRed   = '<span style=""display:inline-block;width:22px;height:22px;background:#ef4444;border-radius:50%;border:3px solid rgba(255,255,255,0.4);""></span>';" + [char]10 +
"  var chairIcon = '<span style=""display:inline-block;width:32px;height:32px;background:rgba(255,255,255,0.2);border-radius:8px;text-align:center;line-height:32px;font-size:18px;font-weight:900;color:white;"">C</span>';" + [char]10 +
"" + [char]10 +
"  var chairRows = '';" + [char]10 +
"  chairList.forEach(function(ch) {" + [char]10 +
"    var qEntry  = queue.find(function(q){ return q.chairId === ch.id && (q.status==='with-doctor'||q.status==='in-consultation'); });" + [char]10 +
"    var patient = qEntry ? pts.find(function(p){ return p.id === qEntry.patientId; }) : null;" + [char]10 +
"    var doctor  = qEntry ? doctors.find(function(d){ return d.id === qEntry.doctorId; }) : null;" + [char]10 +
"    var occupied = !!qEntry;" + [char]10 +
"    var bg = occupied ? 'linear-gradient(135deg,#ef4444,#dc2626)' : 'linear-gradient(135deg,#10b981,#059669)';" + [char]10 +
"    var ptName = occupied ? (patient ? patient.name : 'Patient') : 'AVAILABLE';" + [char]10 +
"    var drLine = doctor ? '<div style=""font-size:12px;color:rgba(255,255,255,0.8);margin-top:2px;"">' + doctor.name + '</div>' : '';" + [char]10 +
"    chairRows +=" + [char]10 +
"      '<div style=""background:' + bg + ';border-radius:16px;padding:16px 18px;display:flex;align-items:center;gap:14px;box-shadow:0 4px 16px rgba(0,0,0,0.3);margin-bottom:10px;"">' +" + [char]10 +
"      '<div style=""flex-shrink:0;"">' + (occupied ? dotRed : dotGreen) + '</div>' +" + [char]10 +
"      '<div style=""flex:1;"">' +" + [char]10 +
"        '<div style=""font-size:15px;font-weight:800;color:white;letter-spacing:1px;"">' + (ch.name || 'Chair ' + ch.id) + '</div>' +" + [char]10 +
"        '<div style=""font-size:20px;font-weight:700;color:white;margin-top:3px;"">' + ptName + '</div>' +" + [char]10 +
"        drLine +" + [char]10 +
"      '</div>' +" + [char]10 +
"      '<div style=""background:rgba(255,255,255,0.2);border-radius:8px;padding:6px 12px;font-size:12px;font-weight:700;color:white;"">' + (occupied ? 'OCCUPIED' : 'FREE') + '</div>' +" + [char]10 +
"      '</div>';" + [char]10 +
"  });" + [char]10 +
"" + [char]10 +
"  var queueRows = '';" + [char]10 +
"  if (waiting.length === 0) {" + [char]10 +
"    queueRows = '<div style=""text-align:center;padding:40px;color:#94a3b8;font-size:18px;"">No patients waiting</div>';" + [char]10 +
"  } else {" + [char]10 +
"    waiting.forEach(function(q, idx) {" + [char]10 +
"      var pt = pts.find(function(p){ return p.id === q.patientId; });" + [char]10 +
"      var dr = doctors.find(function(d){ return d.id === q.doctorId; });" + [char]10 +
"      var isNext = idx === 0;" + [char]10 +
"      var bg     = isNext ? 'linear-gradient(135deg,#667eea,#764ba2)' : 'rgba(255,255,255,0.05)';" + [char]10 +
"      var border = isNext ? '#667eea' : 'rgba(255,255,255,0.1)';" + [char]10 +
"      var shadow = isNext ? 'box-shadow:0 4px 20px rgba(102,126,234,0.4);' : '';" + [char]10 +
"      var badge  = isNext ? '<div style=""background:rgba(255,255,255,0.25);border-radius:8px;padding:6px 12px;font-size:13px;font-weight:700;color:white;"">NEXT &rarr;</div>' : '';" + [char]10 +
"      queueRows +=" + [char]10 +
"        '<div style=""display:flex;align-items:center;gap:14px;background:' + bg + ';border:2px solid ' + border + ';border-radius:14px;padding:14px 16px;margin-bottom:10px;' + shadow + '"">' +" + [char]10 +
"        '<div style=""width:44px;height:44px;border-radius:50%;flex-shrink:0;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:900;color:white;"">' + (idx+1) + '</div>' +" + [char]10 +
"        '<div style=""flex:1;"">' +" + [char]10 +
"          '<div style=""font-size:20px;font-weight:700;color:white;"">' + (pt ? pt.name : 'Patient') + '</div>' +" + [char]10 +
"          '<div style=""font-size:13px;color:rgba(255,255,255,0.65);margin-top:3px;"">' + (dr ? dr.name : '') + (q.time ? ' &middot; Arrived ' + q.time : '') + '</div>' +" + [char]10 +
"        '</div>' +" + [char]10 +
"        badge +" + [char]10 +
"        '</div>';" + [char]10 +
"    });" + [char]10 +
"  }" + [char]10 +
"" + [char]10 +
"  var beingSeenHtml = '';" + [char]10 +
"  if (withDoctor.length > 0) {" + [char]10 +
"    beingSeenHtml = '<div style=""margin-top:20px;padding-top:16px;border-top:1px solid rgba(255,255,255,0.1);"">' +" + [char]10 +
"      '<div style=""font-size:14px;font-weight:700;color:#f59e0b;letter-spacing:1px;margin-bottom:10px;"">&#9654; NOW BEING SEEN</div>';" + [char]10 +
"    withDoctor.forEach(function(q) {" + [char]10 +
"      var pt = pts.find(function(p){ return p.id === q.patientId; });" + [char]10 +
"      var dr = doctors.find(function(d){ return d.id === q.doctorId; });" + [char]10 +
"      beingSeenHtml +=" + [char]10 +
"        '<div style=""background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);border-radius:12px;padding:12px 16px;margin-bottom:8px;display:flex;align-items:center;gap:10px;"">' +" + [char]10 +
"        '<div style=""width:36px;height:36px;background:#f59e0b;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:900;color:white;flex-shrink:0;"">+</div>' +" + [char]10 +
"        '<div>' +" + [char]10 +
"          '<div style=""font-size:17px;font-weight:700;color:#fbbf24;"">' + (pt ? pt.name : 'Patient') + '</div>' +" + [char]10 +
"          '<div style=""font-size:12px;color:rgba(255,255,255,0.6);"">' + (dr ? dr.name : '') + '</div>' +" + [char]10 +
"        '</div>' +" + [char]10 +
"        '</div>';" + [char]10 +
"    });" + [char]10 +
"    beingSeenHtml += '</div>';" + [char]10 +
"  }" + [char]10 +
"" + [char]10 +
"  var occupiedCount = chairList.filter(function(ch){" + [char]10 +
"    return queue.find(function(q){ return q.chairId===ch.id&&(q.status==='with-doctor'||q.status==='in-consultation'); });" + [char]10 +
"  }).length;" + [char]10 +
"  var freeCount = chairList.length - occupiedCount;" + [char]10 +
"  var phone = cfg.clinicPhone || '+91-XXXXXXXXXX';" + [char]10 +
"  var wCount = waiting.length;" + [char]10 +
"" + [char]10 +
"  app.innerHTML =" + [char]10 +
"    '<div style=""min-height:100vh;background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);display:flex;flex-direction:column;"">' +" + [char]10 +
"    '<div style=""background:linear-gradient(135deg,#667eea,#764ba2);padding:14px 28px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 4px 20px rgba(0,0,0,0.4);"">' +" + [char]10 +
"      '<div style=""display:flex;align-items:center;gap:14px;"">' +" + [char]10 +
"        '<div style=""width:48px;height:48px;background:rgba(255,255,255,0.2);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:900;color:white;"">A</div>' +" + [char]10 +
"        '<div>' +" + [char]10 +
"          '<div style=""font-size:24px;font-weight:900;color:white;letter-spacing:1px;"">AURA DENTAL CARE</div>' +" + [char]10 +
"          '<div style=""font-size:13px;color:rgba(255,255,255,0.8);"">Raipur, Chhattisgarh &nbsp;|&nbsp; ' + phone + '</div>' +" + [char]10 +
"        '</div>' +" + [char]10 +
"      '</div>' +" + [char]10 +
"      '<div style=""text-align:right;"">' +" + [char]10 +
"        '<div id=""disp-time"" style=""font-size:30px;font-weight:800;color:white;""></div>' +" + [char]10 +
"        '<div id=""disp-date"" style=""font-size:13px;color:rgba(255,255,255,0.8);margin-top:2px;""></div>' +" + [char]10 +
"      '</div>' +" + [char]10 +
"    '</div>' +" + [char]10 +
"    '<div style=""flex:1;display:grid;grid-template-columns:1fr 1fr;gap:0;overflow:hidden;"">' +" + [char]10 +
"      '<div style=""padding:24px;border-right:1px solid rgba(255,255,255,0.08);overflow-y:auto;"">' +" + [char]10 +
"        '<div style=""display:flex;align-items:center;gap:12px;margin-bottom:18px;"">' +" + [char]10 +
"          '<div style=""width:42px;height:42px;background:rgba(255,255,255,0.1);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:900;color:#94a3b8;"">Q</div>' +" + [char]10 +
"          '<div style=""flex:1;"">' +" + [char]10 +
"            '<div style=""font-size:20px;font-weight:800;color:white;letter-spacing:1px;"">WAITING QUEUE</div>' +" + [char]10 +
"            '<div style=""font-size:13px;color:#94a3b8;"">' + wCount + ' patient' + (wCount !== 1 ? 's' : '') + ' waiting</div>' +" + [char]10 +
"          '</div>' +" + [char]10 +
"          '<div style=""background:linear-gradient(135deg,#667eea,#764ba2);color:white;font-size:26px;font-weight:900;width:48px;height:48px;border-radius:50%;display:flex;align-items:center;justify-content:center;"">' + wCount + '</div>' +" + [char]10 +
"        '</div>' +" + [char]10 +
"        queueRows +" + [char]10 +
"        beingSeenHtml +" + [char]10 +
"      '</div>' +" + [char]10 +
"      '<div style=""padding:24px;overflow-y:auto;"">' +" + [char]10 +
"        '<div style=""display:flex;align-items:center;gap:12px;margin-bottom:18px;"">' +" + [char]10 +
"          '<div style=""width:42px;height:42px;background:rgba(255,255,255,0.1);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:900;color:#94a3b8;"">C</div>' +" + [char]10 +
"          '<div>' +" + [char]10 +
"            '<div style=""font-size:20px;font-weight:800;color:white;letter-spacing:1px;"">CHAIR STATUS</div>' +" + [char]10 +
"            '<div style=""font-size:13px;color:#94a3b8;"">' + occupiedCount + ' occupied &middot; ' + freeCount + ' available</div>' +" + [char]10 +
"          '</div>' +" + [char]10 +
"        '</div>' +" + [char]10 +
"        chairRows +" + [char]10 +
"      '</div>' +" + [char]10 +
"    '</div>' +" + [char]10 +
"    '<div style=""background:rgba(0,0,0,0.4);padding:10px 28px;display:flex;align-items:center;justify-content:space-between;border-top:1px solid rgba(255,255,255,0.08);"">' +" + [char]10 +
"      '<div style=""font-size:13px;color:#64748b;"">Aura Dental Care &mdash; Raipur, Chhattisgarh</div>' +" + [char]10 +
"      '<div style=""font-size:13px;color:#64748b;"">Thank you for your patience</div>' +" + [char]10 +
"      '<div style=""display:flex;align-items:center;gap:8px;"">' +" + [char]10 +
"        '<div style=""width:8px;height:8px;background:#10b981;border-radius:50%;animation:dispPulse 2s infinite;""></div>' +" + [char]10 +
"        '<div style=""font-size:12px;color:#94a3b8;"">Live</div>' +" + [char]10 +
"      '</div>' +" + [char]10 +
"    '</div>' +" + [char]10 +
"    '</div>' +" + [char]10 +
"    '<style>@keyframes dispPulse{0%,100%{opacity:1;}50%{opacity:0.2;}}</style>';" + [char]10 +
"" + [char]10 +
"  function updateClock() {" + [char]10 +
"    var now = new Date();" + [char]10 +
"    var t = document.getElementById('disp-time');" + [char]10 +
"    var d = document.getElementById('disp-date');" + [char]10 +
"    if (t) t.textContent = now.toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',second:'2-digit'});" + [char]10 +
"    if (d) d.textContent = now.toLocaleDateString('en-IN',{weekday:'long',day:'numeric',month:'long',year:'numeric'});" + [char]10 +
"  }" + [char]10 +
"  updateClock();" + [char]10 +
"  if (window._dispClockInterval) clearInterval(window._dispClockInterval);" + [char]10 +
"  window._dispClockInterval = setInterval(updateClock, 1000);" + [char]10 +
"  if (window._dispRefreshInterval) clearInterval(window._dispRefreshInterval);" + [char]10 +
"  window._dispRefreshInterval = setInterval(function(){" + [char]10 +
"    if (window.location.hash === '#display') renderDisplayScreen();" + [char]10 +
"  }, 15000);" + [char]10 +
"}" + [char]10

$newContent = $content.Substring(0, $dispStart) + $newFunc + $content.Substring($dispEnd)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($filePath, $newContent, $utf8NoBom)

Write-Host "Done!" -ForegroundColor Green

$check = Select-String -Path $filePath -Pattern "WAITING QUEUE"
if ($check) { Write-Host "Verified: WAITING QUEUE found" -ForegroundColor Green }
else { Write-Host "WARNING: not found" -ForegroundColor Red }
