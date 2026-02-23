# ============================================================
# Aura Dental - Display Screen Patch
# Replaces renderDisplayScreen with full waiting room TV display
# Run from: C:\Users\sccha\aura-dental-fix
# ============================================================

$filePath = ".\public\index.html"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: Cannot find $filePath" -ForegroundColor Red
    exit
}

$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

if ($content -match "renderDisplayScreen_v2") {
    Write-Host "Already patched!" -ForegroundColor Green
    exit
}

Write-Host "Patching renderDisplayScreen..." -ForegroundColor Cyan

$oldFuncStart = $content.IndexOf("function renderDisplayScreen() {")
$oldFuncEnd   = $content.IndexOf("`nfunction approveBooking(", $oldFuncStart)

if ($oldFuncStart -eq -1 -or $oldFuncEnd -eq -1) {
    Write-Host "ERROR: Could not find renderDisplayScreen boundaries" -ForegroundColor Red
    exit
}

Write-Host "Found renderDisplayScreen at char $oldFuncStart to $oldFuncEnd" -ForegroundColor Yellow

$newFunc = @'
// renderDisplayScreen_v2
function renderDisplayScreen() {
  const app = document.getElementById('app');
  if (!app) return;

  const queue   = state.doctorQueue  || [];
  const chairs  = state.chairs       || [];
  const pts     = state.patients     || [];
  const doctors = state.doctors      || [];

  // Waiting patients (not yet called)
  const waiting = queue.filter(q => q.status === 'waiting');

  // Currently with doctor
  const withDoctor = queue.filter(q => q.status === 'with-doctor' || q.status === 'in-consultation');

  // Build chair rows
  let chairRows = '';
  const chairList = chairs.length
    ? chairs
    : [{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'},{id:4,name:'Chair 4'},{id:5,name:'Chair 5'},{id:6,name:'Chair 6'}];

  chairList.forEach(ch => {
    const qEntry  = queue.find(q => q.chairId === ch.id && (q.status === 'with-doctor' || q.status === 'in-consultation'));
    const patient = qEntry ? pts.find(p => p.id === qEntry.patientId) : null;
    const doctor  = qEntry ? doctors.find(d => d.id === qEntry.doctorId) : null;
    const occupied = !!qEntry;

    chairRows += `
      <div style="
        background:${occupied ? 'linear-gradient(135deg,#ef4444,#dc2626)' : 'linear-gradient(135deg,#10b981,#059669)'};
        border-radius:16px; padding:18px 20px;
        display:flex; align-items:center; gap:16px;
        box-shadow:0 4px 16px rgba(0,0,0,0.3);
        transition:all 0.3s;
      ">
        <div style="font-size:36px;">${occupied ? '🔴' : '🟢'}</div>
        <div style="flex:1;">
          <div style="font-size:18px;font-weight:800;color:white;letter-spacing:1px;">${ch.name || 'Chair '+ch.id}</div>
          <div style="font-size:22px;font-weight:700;color:${occupied?'#fef2f2':'#ecfdf5'};margin-top:4px;">
            ${occupied ? (patient ? patient.name : 'Patient') : 'AVAILABLE'}
          </div>
          ${doctor ? `<div style="font-size:13px;color:rgba(255,255,255,0.85);margin-top:2px;">${doctor.name}</div>` : ''}
        </div>
        <div style="
          background:rgba(255,255,255,0.2);
          border-radius:10px; padding:8px 16px;
          font-size:13px; font-weight:700; color:white; text-align:center;
        ">${occupied ? 'OCCUPIED' : 'FREE'}</div>
      </div>`;
  });

  // Build waiting queue rows
  let queueRows = '';
  if (waiting.length === 0) {
    queueRows = `<div style="text-align:center;padding:30px;color:#94a3b8;font-size:18px;">No patients waiting</div>`;
  } else {
    waiting.forEach((q, idx) => {
      const pt = pts.find(p => p.id === q.patientId);
      const dr = doctors.find(d => d.id === q.doctorId);
      const isNext = idx === 0;
      queueRows += `
        <div style="
          display:flex; align-items:center; gap:16px;
          background:${isNext ? 'linear-gradient(135deg,#667eea,#764ba2)' : 'rgba(255,255,255,0.05)'};
          border:2px solid ${isNext ? '#667eea' : 'rgba(255,255,255,0.1)'};
          border-radius:14px; padding:14px 18px; margin-bottom:10px;
          ${isNext ? 'box-shadow:0 4px 20px rgba(102,126,234,0.4);' : ''}
        ">
          <div style="
            width:48px;height:48px;border-radius:50%;
            background:${isNext ? 'rgba(255,255,255,0.25)' : 'rgba(255,255,255,0.1)'};
            display:flex;align-items:center;justify-content:center;
            font-size:20px;font-weight:900;color:white;flex-shrink:0;
          ">${idx + 1}</div>
          <div style="flex:1;">
            <div style="font-size:20px;font-weight:700;color:white;">${pt ? pt.name : 'Patient'}</div>
            <div style="font-size:13px;color:rgba(255,255,255,0.7);margin-top:3px;">
              ${dr ? dr.name : ''} ${q.time ? '&middot; Arrived '+q.time : ''}
            </div>
          </div>
          ${isNext ? '<div style="background:rgba(255,255,255,0.25);border-radius:8px;padding:6px 14px;font-size:13px;font-weight:700;color:white;">NEXT &#8594;</div>' : ''}
        </div>`;
    });
  }

  app.innerHTML = `
    <div style="
      min-height:100vh;
      background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);
      display:flex; flex-direction:column;
    ">
      <!-- TOP BAR -->
      <div style="
        background:linear-gradient(135deg,#667eea,#764ba2);
        padding:16px 32px;
        display:flex; align-items:center; justify-content:space-between;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
      ">
        <div style="display:flex;align-items:center;gap:16px;">
          <div style="font-size:36px;">🦷</div>
          <div>
            <div style="font-size:26px;font-weight:900;color:white;letter-spacing:1px;">AURA DENTAL CARE</div>
            <div style="font-size:13px;color:rgba(255,255,255,0.8);">Raipur, Chhattisgarh &nbsp;|&nbsp; ${state.config.clinicPhone || '+91-XXXXXXXXXX'}</div>
          </div>
        </div>
        <div style="text-align:right;">
          <div id="disp-time" style="font-size:32px;font-weight:800;color:white;font-variant-numeric:tabular-nums;"></div>
          <div id="disp-date" style="font-size:14px;color:rgba(255,255,255,0.8);margin-top:2px;"></div>
        </div>
      </div>

      <!-- MAIN CONTENT -->
      <div style="flex:1;display:grid;grid-template-columns:1fr 1fr;gap:0;overflow:hidden;">

        <!-- LEFT: WAITING QUEUE -->
        <div style="padding:28px;border-right:1px solid rgba(255,255,255,0.08);overflow-y:auto;">
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
            <div style="font-size:28px;">⏳</div>
            <div>
              <div style="font-size:22px;font-weight:800;color:white;letter-spacing:1px;">WAITING QUEUE</div>
              <div style="font-size:13px;color:#94a3b8;">${waiting.length} patient${waiting.length !== 1 ? 's' : ''} waiting</div>
            </div>
            <div style="margin-left:auto;background:linear-gradient(135deg,#667eea,#764ba2);color:white;font-size:28px;font-weight:900;width:52px;height:52px;border-radius:50%;display:flex;align-items:center;justify-content:center;">
              ${waiting.length}
            </div>
          </div>
          ${queueRows}

          <!-- NOW BEING SEEN -->
          ${withDoctor.length > 0 ? `
          <div style="margin-top:24px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.1);">
            <div style="font-size:15px;font-weight:700;color:#f59e0b;letter-spacing:1px;margin-bottom:12px;">&#9654; NOW BEING SEEN</div>
            ${withDoctor.map(q => {
              const pt = pts.find(p => p.id === q.patientId);
              const dr = doctors.find(d => d.id === q.doctorId);
              return `<div style="background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);border-radius:12px;padding:12px 16px;margin-bottom:8px;display:flex;align-items:center;gap:12px;">
                <div style="font-size:22px;">👨‍⚕️</div>
                <div>
                  <div style="font-size:18px;font-weight:700;color:#fbbf24;">${pt ? pt.name : 'Patient'}</div>
                  <div style="font-size:13px;color:rgba(255,255,255,0.6);">${dr ? dr.name : ''}</div>
                </div>
              </div>`;
            }).join('')}
          </div>` : ''}
        </div>

        <!-- RIGHT: CHAIR STATUS -->
        <div style="padding:28px;overflow-y:auto;">
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
            <div style="font-size:28px;">🪑</div>
            <div>
              <div style="font-size:22px;font-weight:800;color:white;letter-spacing:1px;">CHAIR STATUS</div>
              <div style="font-size:13px;color:#94a3b8;">
                ${chairList.filter(ch => queue.find(q => q.chairId === ch.id && (q.status==='with-doctor'||q.status==='in-consultation'))).length} occupied
                &nbsp;&middot;&nbsp;
                ${chairList.filter(ch => !queue.find(q => q.chairId === ch.id && (q.status==='with-doctor'||q.status==='in-consultation'))).length} available
              </div>
            </div>
          </div>
          <div style="display:flex;flex-direction:column;gap:12px;">
            ${chairRows}
          </div>
        </div>

      </div>

      <!-- BOTTOM BAR -->
      <div style="
        background:rgba(0,0,0,0.4);
        padding:12px 32px;
        display:flex; align-items:center; justify-content:space-between;
        border-top:1px solid rgba(255,255,255,0.08);
      ">
        <div style="font-size:14px;color:#64748b;">Aura Dental Care &mdash; Raipur, Chhattisgarh</div>
        <div style="font-size:14px;color:#64748b;">Thank you for your patience &nbsp;🙏</div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div style="width:8px;height:8px;background:#10b981;border-radius:50%;animation:pulse 2s infinite;"></div>
          <div style="font-size:13px;color:#94a3b8;">Live Display</div>
        </div>
      </div>
    </div>
    <style>
      @keyframes pulse { 0%,100%{opacity:1;} 50%{opacity:0.3;} }
    </style>
  `;

  // Live clock
  function updateClock() {
    const now  = new Date();
    const timeEl = document.getElementById('disp-time');
    const dateEl = document.getElementById('disp-date');
    if (timeEl) timeEl.textContent = now.toLocaleTimeString('en-IN', {hour:'2-digit',minute:'2-digit',second:'2-digit'});
    if (dateEl) dateEl.textContent = now.toLocaleDateString('en-IN', {weekday:'long',day:'numeric',month:'long',year:'numeric'});
  }
  updateClock();
  if (window._dispClockInterval) clearInterval(window._dispClockInterval);
  window._dispClockInterval = setInterval(updateClock, 1000);

  // Auto-refresh display every 15 seconds
  if (window._dispRefreshInterval) clearInterval(window._dispRefreshInterval);
  window._dispRefreshInterval = setInterval(() => {
    if (window.location.hash === '#display') renderDisplayScreen();
  }, 15000);
}

'@

$newContent = $content.Substring(0, $oldFuncStart) + $newFunc + $content.Substring($oldFuncEnd)
[System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)

Write-Host "Patch applied!" -ForegroundColor Green

if ((Select-String -Path $filePath -Pattern "renderDisplayScreen_v2") -ne $null) {
    Write-Host "Verified: Display screen v2 found in file" -ForegroundColor Green
} else {
    Write-Host "WARNING: Verification failed" -ForegroundColor Red
}
