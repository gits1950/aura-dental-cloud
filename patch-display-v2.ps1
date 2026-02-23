# ============================================================
# Aura Dental - Display Screen Fix Patch v2
# ============================================================

$filePath = ".\public\index.html"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: Cannot find $filePath" -ForegroundColor Red
    exit
}

$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Find the OLD renderDisplayScreen (identifiable by its unique first line)
$oldStart = $content.IndexOf("function renderDisplayScreen() {`n  const occupiedChairs")
if ($oldStart -eq -1) {
    $oldStart = $content.IndexOf("function renderDisplayScreen() {`r`n  const occupiedChairs")
}

if ($oldStart -eq -1) {
    # Try alternate - may already be patched differently
    Write-Host "Trying alternate search..." -ForegroundColor Yellow
    $oldStart = $content.IndexOf("// ========== DISPLAY SCREEN ==========`nfunction renderDisplayScreen()")
    if ($oldStart -eq -1) {
        $oldStart = $content.IndexOf("// ========== DISPLAY SCREEN ==========`r`nfunction renderDisplayScreen()")
    }
    if ($oldStart -ne -1) {
        # include the comment
        Write-Host "Found with comment prefix" -ForegroundColor Yellow
    }
}

if ($oldStart -eq -1) {
    Write-Host "ERROR: Could not find old renderDisplayScreen. Checking what's there..." -ForegroundColor Red
    $idx = $content.IndexOf("function renderDisplayScreen()")
    if ($idx -ne -1) {
        Write-Host "Found at index $idx. Context:" -ForegroundColor Yellow
        Write-Host $content.Substring($idx, [Math]::Min(150, $content.Length - $idx))
    }
    exit
}

# Find the end: }\nfunction approveBooking
$oldEnd = $content.IndexOf("`nfunction approveBooking(", $oldStart)
if ($oldEnd -eq -1) {
    $oldEnd = $content.IndexOf("`r`nfunction approveBooking(", $oldStart)
}

if ($oldEnd -eq -1) {
    Write-Host "ERROR: Could not find end boundary (approveBooking)" -ForegroundColor Red
    exit
}

# Include the closing }
$oldEnd = $oldEnd  # the \n is already excluded, we keep up to and including }

Write-Host "Found old renderDisplayScreen: chars $oldStart to $oldEnd" -ForegroundColor Yellow

$newFunc = @'
// renderDisplayScreen_v2 - Full Waiting Room Display
function renderDisplayScreen() {
  const app = document.getElementById('app');
  if (!app) return;

  const queue   = state.doctorQueue  || [];
  const chairs  = state.chairs       || [];
  const pts     = state.patients     || [];
  const doctors = state.doctors      || [];

  const waiting    = queue.filter(q => q.status === 'waiting');
  const withDoctor = queue.filter(q => q.status === 'with-doctor' || q.status === 'in-consultation');

  const chairList = chairs.length
    ? chairs
    : [{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'},
       {id:4,name:'Chair 4'},{id:5,name:'Chair 5'},{id:6,name:'Chair 6'}];

  let chairRows = '';
  chairList.forEach(ch => {
    const qEntry  = queue.find(q => q.chairId === ch.id && (q.status==='with-doctor'||q.status==='in-consultation'));
    const patient = qEntry ? pts.find(p => p.id === qEntry.patientId) : null;
    const doctor  = qEntry ? doctors.find(d => d.id === qEntry.doctorId) : null;
    const occupied = !!qEntry;
    chairRows += `
      <div style="background:${occupied?'linear-gradient(135deg,#ef4444,#dc2626)':'linear-gradient(135deg,#10b981,#059669)'};
        border-radius:16px;padding:16px 18px;display:flex;align-items:center;gap:14px;
        box-shadow:0 4px 16px rgba(0,0,0,0.3);">
        <div style="font-size:32px;">${occupied?'🔴':'🟢'}</div>
        <div style="flex:1;">
          <div style="font-size:16px;font-weight:800;color:white;letter-spacing:1px;">${ch.name||'Chair '+ch.id}</div>
          <div style="font-size:20px;font-weight:700;color:${occupied?'#fef2f2':'#ecfdf5'};margin-top:3px;">
            ${occupied?(patient?patient.name:'Patient'):'AVAILABLE'}
          </div>
          ${doctor?`<div style="font-size:12px;color:rgba(255,255,255,0.8);margin-top:2px;">${doctor.name}</div>`:''}
        </div>
        <div style="background:rgba(255,255,255,0.2);border-radius:8px;padding:6px 12px;
          font-size:12px;font-weight:700;color:white;">${occupied?'OCCUPIED':'FREE'}</div>
      </div>`;
  });

  let queueRows = '';
  if (waiting.length === 0) {
    queueRows = `<div style="text-align:center;padding:40px;color:#94a3b8;font-size:18px;">No patients waiting</div>`;
  } else {
    waiting.forEach((q, idx) => {
      const pt = pts.find(p => p.id === q.patientId);
      const dr = doctors.find(d => d.id === q.doctorId);
      const isNext = idx === 0;
      queueRows += `
        <div style="display:flex;align-items:center;gap:14px;
          background:${isNext?'linear-gradient(135deg,#667eea,#764ba2)':'rgba(255,255,255,0.05)'};
          border:2px solid ${isNext?'#667eea':'rgba(255,255,255,0.1)'};
          border-radius:14px;padding:14px 16px;margin-bottom:10px;
          ${isNext?'box-shadow:0 4px 20px rgba(102,126,234,0.4);':''}">
          <div style="width:44px;height:44px;border-radius:50%;flex-shrink:0;
            background:${isNext?'rgba(255,255,255,0.25)':'rgba(255,255,255,0.1)'};
            display:flex;align-items:center;justify-content:center;
            font-size:18px;font-weight:900;color:white;">${idx+1}</div>
          <div style="flex:1;">
            <div style="font-size:20px;font-weight:700;color:white;">${pt?pt.name:'Patient'}</div>
            <div style="font-size:13px;color:rgba(255,255,255,0.65);margin-top:3px;">
              ${dr?dr.name:''} ${q.time?'&middot; Arrived '+q.time:''}
            </div>
          </div>
          ${isNext?'<div style="background:rgba(255,255,255,0.25);border-radius:8px;padding:6px 12px;font-size:13px;font-weight:700;color:white;">NEXT &#8594;</div>':''}
        </div>`;
    });
  }

  app.innerHTML = `
    <div style="min-height:100vh;background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);display:flex;flex-direction:column;">
      <!-- TOP BAR -->
      <div style="background:linear-gradient(135deg,#667eea,#764ba2);padding:14px 28px;
        display:flex;align-items:center;justify-content:space-between;box-shadow:0 4px 20px rgba(0,0,0,0.4);">
        <div style="display:flex;align-items:center;gap:14px;">
          <div style="font-size:34px;">🦷</div>
          <div>
            <div style="font-size:24px;font-weight:900;color:white;letter-spacing:1px;">AURA DENTAL CARE</div>
            <div style="font-size:13px;color:rgba(255,255,255,0.8);">Raipur, Chhattisgarh &nbsp;|&nbsp; ${state.config&&state.config.clinicPhone?state.config.clinicPhone:'+91-XXXXXXXXXX'}</div>
          </div>
        </div>
        <div style="text-align:right;">
          <div id="disp-time" style="font-size:30px;font-weight:800;color:white;font-variant-numeric:tabular-nums;"></div>
          <div id="disp-date" style="font-size:13px;color:rgba(255,255,255,0.8);margin-top:2px;"></div>
        </div>
      </div>

      <!-- MAIN GRID -->
      <div style="flex:1;display:grid;grid-template-columns:1fr 1fr;gap:0;overflow:hidden;">

        <!-- LEFT: QUEUE -->
        <div style="padding:24px;border-right:1px solid rgba(255,255,255,0.08);overflow-y:auto;">
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:18px;">
            <div style="font-size:26px;">⏳</div>
            <div style="flex:1;">
              <div style="font-size:20px;font-weight:800;color:white;letter-spacing:1px;">WAITING QUEUE</div>
              <div style="font-size:13px;color:#94a3b8;">${waiting.length} patient${waiting.length!==1?'s':''} waiting</div>
            </div>
            <div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;
              font-size:26px;font-weight:900;width:48px;height:48px;border-radius:50%;
              display:flex;align-items:center;justify-content:center;">${waiting.length}</div>
          </div>
          ${queueRows}
          ${withDoctor.length>0?`
            <div style="margin-top:20px;padding-top:16px;border-top:1px solid rgba(255,255,255,0.1);">
              <div style="font-size:14px;font-weight:700;color:#f59e0b;letter-spacing:1px;margin-bottom:10px;">&#9654; NOW BEING SEEN</div>
              ${withDoctor.map(q=>{
                const pt=pts.find(p=>p.id===q.patientId);
                const dr=doctors.find(d=>d.id===q.doctorId);
                return `<div style="background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);
                  border-radius:12px;padding:12px 16px;margin-bottom:8px;display:flex;align-items:center;gap:10px;">
                  <div style="font-size:20px;">👨‍⚕️</div>
                  <div>
                    <div style="font-size:17px;font-weight:700;color:#fbbf24;">${pt?pt.name:'Patient'}</div>
                    <div style="font-size:12px;color:rgba(255,255,255,0.6);">${dr?dr.name:''}</div>
                  </div>
                </div>`;
              }).join('')}
            </div>`:''}
        </div>

        <!-- RIGHT: CHAIRS -->
        <div style="padding:24px;overflow-y:auto;">
          <div style="display:flex;align-items:center;gap:12px;margin-bottom:18px;">
            <div style="font-size:26px;">🪑</div>
            <div>
              <div style="font-size:20px;font-weight:800;color:white;letter-spacing:1px;">CHAIR STATUS</div>
              <div style="font-size:13px;color:#94a3b8;">
                ${chairList.filter(ch=>queue.find(q=>q.chairId===ch.id&&(q.status==='with-doctor'||q.status==='in-consultation'))).length} occupied
                &nbsp;&middot;&nbsp;
                ${chairList.filter(ch=>!queue.find(q=>q.chairId===ch.id&&(q.status==='with-doctor'||q.status==='in-consultation'))).length} available
              </div>
            </div>
          </div>
          <div style="display:flex;flex-direction:column;gap:10px;">${chairRows}</div>
        </div>
      </div>

      <!-- BOTTOM BAR -->
      <div style="background:rgba(0,0,0,0.4);padding:10px 28px;
        display:flex;align-items:center;justify-content:space-between;
        border-top:1px solid rgba(255,255,255,0.08);">
        <div style="font-size:13px;color:#64748b;">Aura Dental Care &mdash; Raipur, Chhattisgarh</div>
        <div style="font-size:13px;color:#64748b;">Thank you for your patience 🙏</div>
        <div style="display:flex;align-items:center;gap:8px;">
          <div style="width:8px;height:8px;background:#10b981;border-radius:50%;animation:dispPulse 2s infinite;"></div>
          <div style="font-size:12px;color:#94a3b8;">Live</div>
        </div>
      </div>
    </div>
    <style>@keyframes dispPulse{0%,100%{opacity:1;}50%{opacity:0.2;}}</style>`;

  // Live clock
  function updateClock() {
    const now = new Date();
    const t = document.getElementById('disp-time');
    const d = document.getElementById('disp-date');
    if (t) t.textContent = now.toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',second:'2-digit'});
    if (d) d.textContent = now.toLocaleDateString('en-IN',{weekday:'long',day:'numeric',month:'long',year:'numeric'});
  }
  updateClock();
  if (window._dispClockInterval) clearInterval(window._dispClockInterval);
  window._dispClockInterval = setInterval(updateClock, 1000);

  // Auto-refresh every 15s
  if (window._dispRefreshInterval) clearInterval(window._dispRefreshInterval);
  window._dispRefreshInterval = setInterval(function(){
    if (window.location.hash==='#display') renderDisplayScreen();
  }, 15000);
}

'@

$newContent = $content.Substring(0, $oldStart) + $newFunc + $content.Substring($oldEnd)
[System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
Write-Host "Patch applied!" -ForegroundColor Green

if ((Select-String -Path $filePath -Pattern "renderDisplayScreen_v2") -ne $null) {
    Write-Host "Verified: Display screen v2 is in the file" -ForegroundColor Green
} else {
    Write-Host "WARNING: Verification failed" -ForegroundColor Red
}
