# ============================================================
# Aura Dental - Display Screen Fix v3 (safe string concat)
# ============================================================

$filePath = ".\public\index.html"
if (-not (Test-Path $filePath)) { Write-Host "ERROR: file not found" -ForegroundColor Red; exit }

$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Remove old v2 (between // renderDisplayScreen_v2 and \nfunction approveBooking)
$oldStart = $content.IndexOf("// renderDisplayScreen_v2")
if ($oldStart -eq -1) { $oldStart = $content.IndexOf("function renderDisplayScreen()") }

$oldEnd = $content.IndexOf("`nfunction approveBooking(", $oldStart)
if ($oldEnd -eq -1) { $oldEnd = $content.IndexOf("`r`nfunction approveBooking(", $oldStart) }

if ($oldStart -eq -1 -or $oldEnd -eq -1) {
    Write-Host "ERROR: boundaries not found" -ForegroundColor Red
    exit
}

Write-Host "Replacing chars $oldStart to $oldEnd" -ForegroundColor Yellow

# New function using string concatenation (no template literals = safe from PowerShell)
$newFunc = @'
function renderDisplayScreen() {
  var app = document.getElementById('app');
  if (!app) return;

  var queue   = state.doctorQueue  || [];
  var chairs  = state.chairs       || [];
  var pts     = state.patients     || [];
  var doctors = state.doctors      || [];
  var cfg     = state.config       || {};

  var waiting    = queue.filter(function(q){ return q.status === 'waiting'; });
  var withDoctor = queue.filter(function(q){ return q.status === 'with-doctor' || q.status === 'in-consultation'; });

  var chairList = chairs.length ? chairs :
    [{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'},
     {id:4,name:'Chair 4'},{id:5,name:'Chair 5'},{id:6,name:'Chair 6'}];

  // --- Build chair rows ---
  var chairRows = '';
  chairList.forEach(function(ch) {
    var qEntry  = queue.find(function(q){ return q.chairId === ch.id && (q.status==='with-doctor'||q.status==='in-consultation'); });
    var patient = qEntry ? pts.find(function(p){ return p.id === qEntry.patientId; }) : null;
    var doctor  = qEntry ? doctors.find(function(d){ return d.id === qEntry.doctorId; }) : null;
    var occupied = !!qEntry;
    var bg      = occupied ? 'linear-gradient(135deg,#ef4444,#dc2626)' : 'linear-gradient(135deg,#10b981,#059669)';
    var ptName  = occupied ? (patient ? patient.name : 'Patient') : 'AVAILABLE';
    var drName  = doctor ? '<div style="font-size:12px;color:rgba(255,255,255,0.8);margin-top:2px;">' + doctor.name + '</div>' : '';
    chairRows += '<div style="background:' + bg + ';border-radius:16px;padding:16px 18px;display:flex;align-items:center;gap:14px;box-shadow:0 4px 16px rgba(0,0,0,0.3);margin-bottom:10px;">' +
      '<div style="font-size:32px;">' + (occupied ? '🔴' : '🟢') + '</div>' +
      '<div style="flex:1;">' +
        '<div style="font-size:15px;font-weight:800;color:white;letter-spacing:1px;">' + (ch.name || 'Chair ' + ch.id) + '</div>' +
        '<div style="font-size:20px;font-weight:700;color:white;margin-top:3px;">' + ptName + '</div>' +
        drName +
      '</div>' +
      '<div style="background:rgba(255,255,255,0.2);border-radius:8px;padding:6px 12px;font-size:12px;font-weight:700;color:white;">' + (occupied ? 'OCCUPIED' : 'FREE') + '</div>' +
    '</div>';
  });

  // --- Build queue rows ---
  var queueRows = '';
  if (waiting.length === 0) {
    queueRows = '<div style="text-align:center;padding:40px;color:#94a3b8;font-size:18px;">No patients waiting</div>';
  } else {
    waiting.forEach(function(q, idx) {
      var pt = pts.find(function(p){ return p.id === q.patientId; });
      var dr = doctors.find(function(d){ return d.id === q.doctorId; });
      var isNext = idx === 0;
      var bg = isNext ? 'linear-gradient(135deg,#667eea,#764ba2)' : 'rgba(255,255,255,0.05)';
      var border = isNext ? '#667eea' : 'rgba(255,255,255,0.1)';
      var shadow = isNext ? 'box-shadow:0 4px 20px rgba(102,126,234,0.4);' : '';
      var nextBadge = isNext ? '<div style="background:rgba(255,255,255,0.25);border-radius:8px;padding:6px 12px;font-size:13px;font-weight:700;color:white;">NEXT &#8594;</div>' : '';
      var drInfo = dr ? dr.name : '';
      var timeInfo = q.time ? ' &middot; Arrived ' + q.time : '';
      queueRows +=
        '<div style="display:flex;align-items:center;gap:14px;background:' + bg + ';border:2px solid ' + border + ';border-radius:14px;padding:14px 16px;margin-bottom:10px;' + shadow + '">' +
          '<div style="width:44px;height:44px;border-radius:50%;flex-shrink:0;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:900;color:white;">' + (idx+1) + '</div>' +
          '<div style="flex:1;">' +
            '<div style="font-size:20px;font-weight:700;color:white;">' + (pt ? pt.name : 'Patient') + '</div>' +
            '<div style="font-size:13px;color:rgba(255,255,255,0.65);margin-top:3px;">' + drInfo + timeInfo + '</div>' +
          '</div>' +
          nextBadge +
        '</div>';
    });
  }

  // --- Now being seen ---
  var beingSeenHtml = '';
  if (withDoctor.length > 0) {
    beingSeenHtml = '<div style="margin-top:20px;padding-top:16px;border-top:1px solid rgba(255,255,255,0.1);">' +
      '<div style="font-size:14px;font-weight:700;color:#f59e0b;letter-spacing:1px;margin-bottom:10px;">&#9654; NOW BEING SEEN</div>';
    withDoctor.forEach(function(q) {
      var pt = pts.find(function(p){ return p.id === q.patientId; });
      var dr = doctors.find(function(d){ return d.id === q.doctorId; });
      beingSeenHtml +=
        '<div style="background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);border-radius:12px;padding:12px 16px;margin-bottom:8px;display:flex;align-items:center;gap:10px;">' +
          '<div style="font-size:20px;">&#128104;&#8205;&#9877;&#65039;</div>' +
          '<div>' +
            '<div style="font-size:17px;font-weight:700;color:#fbbf24;">' + (pt ? pt.name : 'Patient') + '</div>' +
            '<div style="font-size:12px;color:rgba(255,255,255,0.6);">' + (dr ? dr.name : '') + '</div>' +
          '</div>' +
        '</div>';
    });
    beingSeenHtml += '</div>';
  }

  var occupiedCount = chairList.filter(function(ch){
    return queue.find(function(q){ return q.chairId===ch.id&&(q.status==='with-doctor'||q.status==='in-consultation'); });
  }).length;
  var freeCount = chairList.length - occupiedCount;
  var phone = cfg.clinicPhone || '+91-XXXXXXXXXX';
  var wCount = waiting.length;
  var wLabel = wCount !== 1 ? 's' : '';

  app.innerHTML =
    '<div style="min-height:100vh;background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);display:flex;flex-direction:column;">' +

    // Top bar
    '<div style="background:linear-gradient(135deg,#667eea,#764ba2);padding:14px 28px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 4px 20px rgba(0,0,0,0.4);">' +
      '<div style="display:flex;align-items:center;gap:14px;">' +
        '<div style="font-size:34px;">&#129463;</div>' +
        '<div>' +
          '<div style="font-size:24px;font-weight:900;color:white;letter-spacing:1px;">AURA DENTAL CARE</div>' +
          '<div style="font-size:13px;color:rgba(255,255,255,0.8);">Raipur, Chhattisgarh &nbsp;|&nbsp; ' + phone + '</div>' +
        '</div>' +
      '</div>' +
      '<div style="text-align:right;">' +
        '<div id="disp-time" style="font-size:30px;font-weight:800;color:white;"></div>' +
        '<div id="disp-date" style="font-size:13px;color:rgba(255,255,255,0.8);margin-top:2px;"></div>' +
      '</div>' +
    '</div>' +

    // Main grid
    '<div style="flex:1;display:grid;grid-template-columns:1fr 1fr;gap:0;overflow:hidden;">' +

      // Left: Queue
      '<div style="padding:24px;border-right:1px solid rgba(255,255,255,0.08);overflow-y:auto;">' +
        '<div style="display:flex;align-items:center;gap:12px;margin-bottom:18px;">' +
          '<div style="font-size:26px;">&#9203;</div>' +
          '<div style="flex:1;">' +
            '<div style="font-size:20px;font-weight:800;color:white;letter-spacing:1px;">WAITING QUEUE</div>' +
            '<div style="font-size:13px;color:#94a3b8;">' + wCount + ' patient' + wLabel + ' waiting</div>' +
          '</div>' +
          '<div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;font-size:26px;font-weight:900;width:48px;height:48px;border-radius:50%;display:flex;align-items:center;justify-content:center;">' + wCount + '</div>' +
        '</div>' +
        queueRows +
        beingSeenHtml +
      '</div>' +

      // Right: Chairs
      '<div style="padding:24px;overflow-y:auto;">' +
        '<div style="display:flex;align-items:center;gap:12px;margin-bottom:18px;">' +
          '<div style="font-size:26px;">&#129681;</div>' +
          '<div>' +
            '<div style="font-size:20px;font-weight:800;color:white;letter-spacing:1px;">CHAIR STATUS</div>' +
            '<div style="font-size:13px;color:#94a3b8;">' + occupiedCount + ' occupied &middot; ' + freeCount + ' available</div>' +
          '</div>' +
        '</div>' +
        chairRows +
      '</div>' +
    '</div>' +

    // Bottom bar
    '<div style="background:rgba(0,0,0,0.4);padding:10px 28px;display:flex;align-items:center;justify-content:space-between;border-top:1px solid rgba(255,255,255,0.08);">' +
      '<div style="font-size:13px;color:#64748b;">Aura Dental Care &mdash; Raipur, Chhattisgarh</div>' +
      '<div style="font-size:13px;color:#64748b;">Thank you for your patience &#128591;</div>' +
      '<div style="display:flex;align-items:center;gap:8px;"><div style="width:8px;height:8px;background:#10b981;border-radius:50%;animation:dispPulse 2s infinite;"></div><div style="font-size:12px;color:#94a3b8;">Live</div></div>' +
    '</div>' +

    '</div>' +
    '<style>@keyframes dispPulse{0%,100%{opacity:1;}50%{opacity:0.2;}}</style>';

  // Live clock
  function updateClock() {
    var now = new Date();
    var t = document.getElementById('disp-time');
    var d = document.getElementById('disp-date');
    if (t) t.textContent = now.toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',second:'2-digit'});
    if (d) d.textContent = now.toLocaleDateString('en-IN',{weekday:'long',day:'numeric',month:'long',year:'numeric'});
  }
  updateClock();
  if (window._dispClockInterval) clearInterval(window._dispClockInterval);
  window._dispClockInterval = setInterval(updateClock, 1000);
  if (window._dispRefreshInterval) clearInterval(window._dispRefreshInterval);
  window._dispRefreshInterval = setInterval(function(){
    if (window.location.hash === '#display') renderDisplayScreen();
  }, 15000);
}

'@

$newContent = $content.Substring(0, $oldStart) + $newFunc + $content.Substring($oldEnd)
[System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
Write-Host "Done!" -ForegroundColor Green

$check = Select-String -Path $filePath -Pattern "WAITING QUEUE"
if ($check) { Write-Host "Verified: WAITING QUEUE found in file" -ForegroundColor Green }
else { Write-Host "WARNING: verification failed" -ForegroundColor Red }
