# ============================================================
# Aura Dental - Dashboard Calendar Patch Script
# Run from: C:\Users\sccha\aura-dental-fix
# ============================================================

$filePath = ".\public\index.html"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: Cannot find $filePath" -ForegroundColor Red
    exit
}

$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Check if already patched
if ($content -match "dashCalChangeMonth") {
    Write-Host "Already patched!" -ForegroundColor Green
    exit
}

Write-Host "Patching renderDashboard..." -ForegroundColor Cyan

# Find the old renderDashboard function
$oldFuncPattern = "function renderDashboard\(\) \{"
$oldFuncStart = $content.IndexOf("function renderDashboard() {")

if ($oldFuncStart -eq -1) {
    Write-Host "ERROR: Could not find renderDashboard function" -ForegroundColor Red
    exit
}

# Find where renderPatients starts (end of renderDashboard)
$renderPatientsMarker = "`nfunction renderPatients() {"
$oldFuncEnd = $content.IndexOf($renderPatientsMarker, $oldFuncStart)

if ($oldFuncEnd -eq -1) {
    Write-Host "ERROR: Could not find end of renderDashboard" -ForegroundColor Red
    exit
}

Write-Host "Found renderDashboard at char $oldFuncStart to $oldFuncEnd" -ForegroundColor Yellow

$newFunc = @'
function renderDashboard() {
  const app = document.getElementById('app');
  if (!app) return;
  const today = new Date().toISOString().split('T')[0];
  const pts = state.patients || [];
  const queue = state.doctorQueue || [];
  const chairs = state.chairs || [];
  const bills = state.bills || [];
  const todayPts = pts.filter(p => p.registeredDate && p.registeredDate.startsWith(today)).length;
  const todayBills = bills.filter(b => b.date && b.date.startsWith(today));
  const todayRevenue = todayBills.reduce((s, b) => s + (parseFloat(b.totalAmount) || 0), 0);
  const occupied = queue.filter(q => q.status === 'in-consultation' || q.status === 'waiting').length;

  if (!state.dashCal) {
    const now = new Date();
    state.dashCal = { month: now.getMonth(), year: now.getFullYear() };
  }
  const calMonth = state.dashCal.month;
  const calYear  = state.dashCal.year;
  const monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const firstDay   = new Date(calYear, calMonth, 1).getDay();
  const daysInMonth = new Date(calYear, calMonth + 1, 0).getDate();
  const nowDate    = new Date();
  const isThisMonth = nowDate.getMonth() === calMonth && nowDate.getFullYear() === calYear;

  const monthApts = (state.appointments || []).filter(a => {
    const d = new Date(a.date);
    return d.getMonth() === calMonth && d.getFullYear() === calYear;
  });

  let dayCells = '';
  for (let i = 0; i < firstDay; i++) dayCells += '<div></div>';
  for (let day = 1; day <= daysInMonth; day++) {
    const dateStr = calYear + '-' + String(calMonth+1).padStart(2,'0') + '-' + String(day).padStart(2,'0');
    const dayApts = monthApts.filter(a => a.date === dateStr);
    const cellDate = new Date(calYear, calMonth, day);
    const isPast   = cellDate < new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate());
    const isToday  = isThisMonth && day === nowDate.getDate();
    const bg       = isToday ? 'linear-gradient(135deg,#667eea,#764ba2)' : (isPast ? '#f8fafc' : 'white');
    const txtColor = isToday ? 'white' : (isPast ? '#cbd5e1' : '#1e293b');
    const border   = isToday ? '#667eea' : (dayApts.length > 0 ? '#10b981' : '#e2e8f0');
    const cursor   = isPast ? 'default' : 'pointer';
    const click    = isPast ? '' : `onclick="dashCalBookDate('${dateStr}')"`;
    const hover    = isPast ? '' : `onmouseover="this.style.boxShadow='0 4px 12px rgba(102,126,234,0.3)'" onmouseout="this.style.boxShadow='none'"`;
    dayCells += `<div ${click} ${hover} style="border:2px solid ${border};background:${bg};border-radius:8px;padding:6px 4px;text-align:center;cursor:${cursor};min-height:54px;display:flex;flex-direction:column;align-items:center;justify-content:space-between;transition:box-shadow 0.2s;">
      <span style="font-size:14px;font-weight:700;color:${txtColor};">${day}</span>
      ${dayApts.length > 0 ? `<span style="font-size:10px;background:${isToday?'rgba(255,255,255,0.3)':'#10b981'};color:white;border-radius:4px;padding:1px 5px;">${dayApts.length} apt${dayApts.length>1?'s':''}</span>` : ''}
    </div>`;
  }

  const todayApts = (state.appointments || []).filter(a => a.date === today);

  app.innerHTML = renderSidebar('#dashboard') + `
    <div class="main-content" style="padding:24px;">
      <h2 style="color:#1e293b;margin-bottom:24px;font-size:24px;font-weight:700;">📊 Reception Dashboard</h2>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:28px;">
        <div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:20px;border-radius:16px;">
          <div style="font-size:32px;font-weight:700;">${todayPts}</div>
          <div style="opacity:0.9;margin-top:4px;font-size:14px;">Today's Patients</div>
        </div>
        <div style="background:linear-gradient(135deg,#f093fb,#f5576c);color:white;padding:20px;border-radius:16px;">
          <div style="font-size:32px;font-weight:700;">${occupied}</div>
          <div style="opacity:0.9;margin-top:4px;font-size:14px;">In Queue / Consulting</div>
        </div>
        <div style="background:linear-gradient(135deg,#4facfe,#00f2fe);color:white;padding:20px;border-radius:16px;">
          <div style="font-size:32px;font-weight:700;">&#8377;${todayRevenue.toLocaleString()}</div>
          <div style="opacity:0.9;margin-top:4px;font-size:14px;">Today's Revenue</div>
        </div>
        <div style="background:linear-gradient(135deg,#43e97b,#38f9d7);color:white;padding:20px;border-radius:16px;">
          <div style="font-size:32px;font-weight:700;">${todayApts.length}</div>
          <div style="opacity:0.9;margin-top:4px;font-size:14px;">Today's Appointments</div>
        </div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 340px;gap:20px;margin-bottom:24px;">
        <div style="background:white;border-radius:16px;padding:20px;border:1px solid #e2e8f0;box-shadow:0 2px 8px rgba(0,0,0,0.06);">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
            <h3 style="margin:0;font-size:18px;font-weight:700;color:#1e293b;">&#128197; Book Appointment</h3>
            <button onclick="dashCalOpenBookModal()" style="padding:8px 16px;background:linear-gradient(135deg,#667eea,#764ba2);color:white;border:none;border-radius:8px;cursor:pointer;font-size:13px;font-weight:600;">+ New Booking</button>
          </div>
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
            <button onclick="dashCalChangeMonth(-1)" style="padding:6px 12px;background:#f1f5f9;border:none;border-radius:8px;cursor:pointer;font-size:16px;color:#667eea;font-weight:700;">&#9664;</button>
            <div style="display:flex;align-items:center;gap:10px;">
              <select onchange="dashCalSetMonth(parseInt(this.value))" style="padding:6px 10px;border:2px solid #e2e8f0;border-radius:8px;font-size:14px;font-weight:600;">
                ${monthNames.map((m,i) => `<option value="${i}" ${i===calMonth?'selected':''}>${m}</option>`).join('')}
              </select>
              <select onchange="dashCalSetYear(parseInt(this.value))" style="padding:6px 10px;border:2px solid #e2e8f0;border-radius:8px;font-size:14px;font-weight:600;">
                ${Array.from({length:6},(_,i)=>nowDate.getFullYear()-1+i).map(y=>`<option value="${y}" ${y===calYear?'selected':''}>${y}</option>`).join('')}
              </select>
            </div>
            <button onclick="dashCalChangeMonth(1)" style="padding:6px 12px;background:#f1f5f9;border:none;border-radius:8px;cursor:pointer;font-size:16px;color:#667eea;font-weight:700;">&#9654;</button>
          </div>
          <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px;margin-bottom:6px;">
            ${['Sun','Mon','Tue','Wed','Thu','Fri','Sat'].map((d,i)=>`<div style="text-align:center;font-size:12px;font-weight:700;padding:6px 0;color:${i===0?'#ef4444':'#94a3b8'};">${d}</div>`).join('')}
          </div>
          <div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px;">${dayCells}</div>
          <div style="display:flex;gap:16px;margin-top:14px;font-size:12px;color:#64748b;">
            <span><span style="display:inline-block;width:10px;height:10px;background:#10b981;border-radius:2px;margin-right:4px;"></span>Has appointments</span>
            <span><span style="display:inline-block;width:10px;height:10px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:2px;margin-right:4px;"></span>Today</span>
          </div>
        </div>
        <div style="background:white;border-radius:16px;padding:20px;border:1px solid #e2e8f0;box-shadow:0 2px 8px rgba(0,0,0,0.06);">
          <h3 style="margin:0 0 16px 0;font-size:18px;font-weight:700;color:#1e293b;">&#128205; Today's Appointments <span style="background:#667eea;color:white;font-size:12px;padding:2px 8px;border-radius:12px;margin-left:6px;">${todayApts.length}</span></h3>
          ${todayApts.length === 0
            ? '<div style="text-align:center;padding:40px 20px;color:#94a3b8;"><div style="font-size:40px;margin-bottom:8px;">&#128237;</div><div style="font-size:14px;">No appointments today</div></div>'
            : todayApts.map(a => {
                const pt = pts.find(p => p.id === a.patientId);
                const dr = (state.doctors||[]).find(d => d.id === a.doctorId);
                return `<div style="padding:10px 12px;background:#f8fafc;border-left:4px solid #667eea;border-radius:8px;margin-bottom:8px;">
                  <div style="font-weight:600;color:#1e293b;font-size:14px;">${pt?pt.name:'Unknown'}</div>
                  <div style="font-size:12px;color:#64748b;margin-top:3px;">&#128336; ${a.time||'Time N/A'} &middot; ${dr?dr.name:'N/A'}</div>
                  ${a.treatment?`<div style="font-size:11px;color:#94a3b8;margin-top:2px;">${a.treatment}</div>`:''}
                </div>`;
              }).join('')
          }
        </div>
      </div>
      <div style="background:white;border-radius:16px;padding:20px;border:1px solid #e2e8f0;">
        <h3 style="margin-bottom:16px;color:#1e293b;font-size:16px;font-weight:700;">&#129681; Chair Status</h3>
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;">
          ${(chairs.length?chairs:[{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'}]).map(ch=>{
            const q=queue.find(q=>q.chairId===ch.id&&(q.status==='in-consultation'||q.status==='waiting'));
            const color=q?'#ef4444':'#10b981';
            const patient=q?pts.find(p=>p.id===q.patientId):null;
            return `<div style="padding:14px;border-radius:12px;border:2px solid ${color};text-align:center;">
              <div style="font-size:22px;">&#129681;</div>
              <div style="font-weight:600;color:#1e293b;font-size:14px;">${ch.name||'Chair '+ch.id}</div>
              <div style="color:${color};font-weight:600;font-size:12px;">${q?'Occupied':'Available'}</div>
              ${patient?`<div style="font-size:11px;color:#64748b;margin-top:3px;">${patient.name}</div>`:''}
            </div>`;
          }).join('')}
        </div>
      </div>
    </div>
    <div id="dashCalModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:9999;align-items:center;justify-content:center;">
      <div style="background:white;border-radius:20px;padding:28px;width:480px;max-width:95vw;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
          <h3 style="margin:0;font-size:20px;font-weight:700;color:#1e293b;">&#128197; Book Appointment</h3>
          <button onclick="dashCalCloseModal()" style="background:none;border:none;font-size:24px;cursor:pointer;color:#94a3b8;">&#x2715;</button>
        </div>
        <div style="margin-bottom:14px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Date *</label>
          <input type="date" id="dashCal_date" style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;">
        </div>
        <div style="margin-bottom:14px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Time *</label>
          <select id="dashCal_time" style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;">
            <option value="">-- Select Time --</option>
            <option>09:00 AM</option><option>09:30 AM</option><option>10:00 AM</option><option>10:30 AM</option>
            <option>11:00 AM</option><option>11:30 AM</option><option>12:00 PM</option><option>12:30 PM</option>
            <option>02:00 PM</option><option>02:30 PM</option><option>03:00 PM</option><option>03:30 PM</option>
            <option>04:00 PM</option><option>04:30 PM</option><option>05:00 PM</option><option>05:30 PM</option><option>06:00 PM</option>
          </select>
        </div>
        <div style="margin-bottom:14px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Patient *</label>
          <input type="text" id="dashCal_patSearch" placeholder="Search by name or phone..." oninput="dashCalSearchPat(this.value)"
            style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;">
          <div id="dashCal_patResults" style="background:white;border:1px solid #e2e8f0;border-radius:8px;margin-top:4px;max-height:140px;overflow-y:auto;display:none;"></div>
          <input type="hidden" id="dashCal_patId">
          <div id="dashCal_patSelected" style="margin-top:6px;font-size:13px;color:#10b981;font-weight:600;"></div>
          <div style="margin-top:6px;font-size:12px;color:#94a3b8;">New patient? <a href="#" onclick="dashCalCloseModal();window.location.hash='#walkin';" style="color:#667eea;font-weight:600;">Register first &rarr;</a></div>
        </div>
        <div style="margin-bottom:14px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Doctor *</label>
          <select id="dashCal_doctor" style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;">
            <option value="">-- Select Doctor --</option>
            ${(state.doctors||[]).map(d=>`<option value="${d.id}">${d.name}</option>`).join('')}
          </select>
        </div>
        <div style="margin-bottom:14px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Treatment / Reason</label>
          <input type="text" id="dashCal_treatment" placeholder="e.g. Scaling, Root Canal, Consultation..."
            style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;">
        </div>
        <div style="margin-bottom:20px;">
          <label style="display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:6px;">Notes</label>
          <textarea id="dashCal_notes" rows="2" style="width:100%;padding:10px 14px;border:2px solid #e2e8f0;border-radius:10px;font-size:14px;box-sizing:border-box;resize:vertical;"></textarea>
        </div>
        <div style="display:flex;gap:12px;">
          <button onclick="dashCalSaveBooking()" style="flex:1;padding:12px;background:linear-gradient(135deg,#667eea,#764ba2);color:white;border:none;border-radius:10px;cursor:pointer;font-size:15px;font-weight:700;">&#10003; Book Appointment</button>
          <button onclick="dashCalCloseModal()" style="padding:12px 20px;background:#f1f5f9;color:#64748b;border:none;border-radius:10px;cursor:pointer;font-size:15px;">Cancel</button>
        </div>
      </div>
    </div>`;
}

function dashCalChangeMonth(delta) {
  if (!state.dashCal) return;
  state.dashCal.month += delta;
  if (state.dashCal.month > 11) { state.dashCal.month = 0; state.dashCal.year++; }
  else if (state.dashCal.month < 0) { state.dashCal.month = 11; state.dashCal.year--; }
  renderDashboard();
}
function dashCalSetMonth(m) { if (!state.dashCal) return; state.dashCal.month = m; renderDashboard(); }
function dashCalSetYear(y)  { if (!state.dashCal) return; state.dashCal.year  = y; renderDashboard(); }
function dashCalBookDate(dateStr) {
  const modal = document.getElementById('dashCalModal');
  if (!modal) return;
  document.getElementById('dashCal_date').value = dateStr;
  document.getElementById('dashCal_patId').value = '';
  document.getElementById('dashCal_patSelected').textContent = '';
  document.getElementById('dashCal_patSearch').value = '';
  document.getElementById('dashCal_time').value = '';
  document.getElementById('dashCal_treatment').value = '';
  document.getElementById('dashCal_notes').value = '';
  modal.style.display = 'flex';
}
function dashCalOpenBookModal() { dashCalBookDate(new Date().toISOString().split('T')[0]); }
function dashCalCloseModal() { const m = document.getElementById('dashCalModal'); if (m) m.style.display = 'none'; }
function dashCalSearchPat(query) {
  const results = document.getElementById('dashCal_patResults');
  if (!query || query.length < 2) { results.style.display = 'none'; return; }
  const matches = (state.patients||[]).filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase()) || (p.phone||'').includes(query) || (p.contact||'').includes(query)
  ).slice(0,8);
  if (!matches.length) { results.style.display = 'none'; return; }
  results.innerHTML = matches.map(p =>
    `<div onclick="dashCalSelectPat(${p.id},'${p.name.replace(/'/g,"\\'")}','${(p.phone||p.contact||'')}')"
      style="padding:10px 14px;cursor:pointer;border-bottom:1px solid #f1f5f9;font-size:14px;"
      onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='white'">
      <span style="font-weight:600;">${p.name}</span>
      <span style="color:#94a3b8;margin-left:8px;font-size:12px;">${p.phone||p.contact||''}</span>
    </div>`).join('');
  results.style.display = 'block';
}
function dashCalSelectPat(id, name, phone) {
  document.getElementById('dashCal_patId').value = id;
  document.getElementById('dashCal_patSearch').value = name;
  document.getElementById('dashCal_patSelected').textContent = '&#10003; ' + name + (phone?' · '+phone:'');
  document.getElementById('dashCal_patResults').style.display = 'none';
}
function dashCalSaveBooking() {
  const date     = document.getElementById('dashCal_date').value;
  const time     = document.getElementById('dashCal_time').value;
  const patId    = parseInt(document.getElementById('dashCal_patId').value);
  const doctorId = parseInt(document.getElementById('dashCal_doctor').value);
  const treatment= document.getElementById('dashCal_treatment').value;
  const notes    = document.getElementById('dashCal_notes').value;
  if (!date)    { alert('Please select a date.'); return; }
  if (!time)    { alert('Please select a time.'); return; }
  if (!patId)   { alert('Please select a patient.'); return; }
  if (!doctorId){ alert('Please select a doctor.'); return; }
  if (!state.appointments) state.appointments = [];
  const apt = { id: Date.now(), patientId: patId, doctorId: doctorId, date: date, time: time,
    treatment: treatment||'Consultation', status: 'scheduled', source: 'reception', notes: notes };
  state.appointments.push(apt);
  if (typeof DataStore !== 'undefined') DataStore.save('appointments', state.appointments);
  if (typeof saveAllData === 'function') saveAllData();
  dashCalCloseModal();
  renderDashboard();
  const pt = (state.patients||[]).find(p=>p.id===patId);
  const msg = 'Appointment booked for ' + (pt?pt.name:'Patient') + ' on ' + date + ' at ' + time;
  if (typeof showToast === 'function') showToast('&#10003; ' + msg); else alert(msg);
}

'@

$newContent = $content.Substring(0, $oldFuncStart) + $newFunc + $content.Substring($oldFuncEnd)

[System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)

Write-Host "Patch applied!" -ForegroundColor Green

# Verify
if ((Select-String -Path $filePath -Pattern "dashCalChangeMonth") -ne $null) {
    Write-Host "Verified: dashCalChangeMonth found in file" -ForegroundColor Green
} else {
    Write-Host "WARNING: Verification failed" -ForegroundColor Red
}
