import sys

INPUT = r".\public\index.html"
OUTPUT = r".\public\index.html"

NEW_FUNC = '''function renderDisplayScreen() {
  var app = document.getElementById('app');
  if (!app) return;
  var queue = state.doctorQueue || [];
  var chairs = state.chairs || [];
  var pts = state.patients || [];
  var doctors = state.doctors || [];
  var cfg = state.config || {};
  var waiting = queue.filter(function(q){ return q.status==='waiting'; });
  var withDoctor = queue.filter(function(q){ return q.status==='with-doctor'||q.status==='in-consultation'; });
  var chairList = chairs.length ? chairs : [{id:1,name:'Chair 1'},{id:2,name:'Chair 2'},{id:3,name:'Chair 3'},{id:4,name:'Chair 4'},{id:5,name:'Chair 5'},{id:6,name:'Chair 6'}];
  var dotG = '<span style="display:inline-block;width:18px;height:18px;background:#22c55e;border-radius:50%;flex-shrink:0;"></span>';
  var dotR = '<span style="display:inline-block;width:18px;height:18px;background:#ef4444;border-radius:50%;flex-shrink:0;"></span>';
  var chairRows = '';
  chairList.forEach(function(ch) {
    var qe = queue.find(function(q){ return q.chairId===ch.id&&(q.status==='with-doctor'||q.status==='in-consultation'); });
    var pt = qe ? pts.find(function(p){ return p.id===qe.patientId; }) : null;
    var dr = qe ? doctors.find(function(d){ return d.id===qe.doctorId; }) : null;
    var occ = !!qe;
    var bg = occ?'linear-gradient(135deg,#ef4444,#dc2626)':'linear-gradient(135deg,#10b981,#059669)';
    chairRows += '<div style="background:'+bg+';border-radius:16px;padding:16px 18px;display:flex;align-items:center;gap:14px;box-shadow:0 4px 16px rgba(0,0,0,0.3);margin-bottom:10px;">'
      +'<div>'+(occ?dotR:dotG)+'</div>'
      +'<div style="flex:1;"><div style="font-size:15px;font-weight:800;color:white;">'+(ch.name||'Chair '+ch.id)+'</div>'
      +'<div style="font-size:20px;font-weight:700;color:white;margin-top:3px;">'+(occ?(pt?pt.name:'Patient'):'AVAILABLE')+'</div>'
      +(dr?'<div style="font-size:12px;color:rgba(255,255,255,0.8);margin-top:2px;">'+dr.name+'</div>':'')+'</div>'
      +'<div style="background:rgba(255,255,255,0.2);border-radius:8px;padding:6px 12px;font-size:12px;font-weight:700;color:white;">'+(occ?'OCCUPIED':'FREE')+'</div></div>';
  });
  var queueRows = '';
  if (waiting.length===0) {
    queueRows='<div style="text-align:center;padding:40px;color:#94a3b8;font-size:18px;">No patients waiting</div>';
  } else {
    waiting.forEach(function(q,idx){
      var pt=pts.find(function(p){return p.id===q.patientId;});
      var dr=doctors.find(function(d){return d.id===q.doctorId;});
      var isNext=idx===0;
      var bg=isNext?'linear-gradient(135deg,#667eea,#764ba2)':'rgba(255,255,255,0.05)';
      var border=isNext?'#667eea':'rgba(255,255,255,0.1)';
      queueRows+='<div style="display:flex;align-items:center;gap:14px;background:'+bg+';border:2px solid '+border+';border-radius:14px;padding:14px 16px;margin-bottom:10px;">'
        +'<div style="width:44px;height:44px;border-radius:50%;flex-shrink:0;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;font-size:18px;font-weight:900;color:white;">'+(idx+1)+'</div>'
        +'<div style="flex:1;"><div style="font-size:20px;font-weight:700;color:white;">'+(pt?pt.name:'Patient')+'</div>'
        +'<div style="font-size:13px;color:rgba(255,255,255,0.65);margin-top:3px;">'+(dr?dr.name:'')+(q.time?' - '+q.time:'')+'</div></div>'
        +(isNext?'<div style="background:rgba(255,255,255,0.25);border-radius:8px;padding:6px 12px;font-size:13px;font-weight:700;color:white;">NEXT</div>':'')
        +'</div>';
    });
  }
  var beingSeen='';
  if(withDoctor.length>0){
    beingSeen='<div style="margin-top:20px;padding-top:16px;border-top:1px solid rgba(255,255,255,0.1);"><div style="font-size:14px;font-weight:700;color:#f59e0b;margin-bottom:10px;">NOW BEING SEEN</div>';
    withDoctor.forEach(function(q){
      var pt=pts.find(function(p){return p.id===q.patientId;});
      var dr=doctors.find(function(d){return d.id===q.doctorId;});
      beingSeen+='<div style="background:rgba(245,158,11,0.15);border:1px solid rgba(245,158,11,0.3);border-radius:12px;padding:12px 16px;margin-bottom:8px;">'
        +'<div style="font-size:17px;font-weight:700;color:#fbbf24;">'+(pt?pt.name:'Patient')+'</div>'
        +'<div style="font-size:12px;color:rgba(255,255,255,0.6);">'+(dr?dr.name:'')+'</div></div>';
    });
    beingSeen+='</div>';
  }
  var oCount=chairList.filter(function(ch){return queue.find(function(q){return q.chairId===ch.id&&(q.status===\'with-doctor\'||q.status===\'in-consultation\');});}).length;
  var fCount=chairList.length-oCount;
  var phone=cfg.clinicPhone||'+91-XXXXXXXXXX';
  var wCount=waiting.length;
  app.innerHTML=
    '<div style="min-height:100vh;background:linear-gradient(135deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);display:flex;flex-direction:column;">'
    +'<div style="background:linear-gradient(135deg,#667eea,#764ba2);padding:14px 28px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 4px 20px rgba(0,0,0,0.4);">'
    +'<div><div style="font-size:24px;font-weight:900;color:white;letter-spacing:1px;">AURA DENTAL CARE</div>'
    +'<div style="font-size:13px;color:rgba(255,255,255,0.8);">Raipur, Chhattisgarh | '+phone+'</div></div>'
    +'<div style="text-align:right;"><div id="disp-time" style="font-size:30px;font-weight:800;color:white;"></div>'
    +'<div id="disp-date" style="font-size:13px;color:rgba(255,255,255,0.8);margin-top:2px;"></div></div></div>'
    +'<div style="flex:1;display:grid;grid-template-columns:1fr 1fr;gap:0;">'
    +'<div style="padding:24px;border-right:1px solid rgba(255,255,255,0.08);overflow-y:auto;">'
    +'<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;">'
    +'<div><div style="font-size:20px;font-weight:800;color:white;">WAITING QUEUE</div>'
    +'<div style="font-size:13px;color:#94a3b8;">'+wCount+' patient'+(wCount!==1?'s':'')+' waiting</div></div>'
    +'<div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;font-size:26px;font-weight:900;width:48px;height:48px;border-radius:50%;display:flex;align-items:center;justify-content:center;">'+wCount+'</div></div>'
    +queueRows+beingSeen+'</div>'
    +'<div style="padding:24px;overflow-y:auto;">'
    +'<div style="margin-bottom:18px;"><div style="font-size:20px;font-weight:800;color:white;">CHAIR STATUS</div>'
    +'<div style="font-size:13px;color:#94a3b8;">'+oCount+' occupied - '+fCount+' available</div></div>'
    +chairRows+'</div></div>'
    +'<div style="background:rgba(0,0,0,0.4);padding:10px 28px;display:flex;align-items:center;justify-content:space-between;border-top:1px solid rgba(255,255,255,0.08);">'
    +'<div style="font-size:13px;color:#64748b;">Aura Dental Care - Raipur</div>'
    +'<div style="font-size:13px;color:#64748b;">Thank you for your patience</div>'
    +'<div style="display:flex;align-items:center;gap:8px;"><div style="width:8px;height:8px;background:#10b981;border-radius:50%;"></div>'
    +'<div style="font-size:12px;color:#94a3b8;">Live</div></div></div></div>';
  function updateClock(){
    var now=new Date();
    var t=document.getElementById('disp-time');
    var d=document.getElementById('disp-date');
    if(t)t.textContent=now.toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit',second:'2-digit'});
    if(d)d.textContent=now.toLocaleDateString('en-IN',{weekday:'long',day:'numeric',month:'long',year:'numeric'});
  }
  updateClock();
  if(window._dispClockInterval)clearInterval(window._dispClockInterval);
  window._dispClockInterval=setInterval(updateClock,1000);
  if(window._dispRefreshInterval)clearInterval(window._dispRefreshInterval);
  window._dispRefreshInterval=setInterval(function(){if(window.location.hash==='#display')renderDisplayScreen();},15000);
}
'''

print(f"Reading {INPUT}...")
try:
    with open(INPUT, 'r', encoding='utf-8') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars (utf-8)")
except:
    with open(INPUT, 'r', encoding='utf-16') as f:
        content = f.read()
    print(f"Loaded {len(content)} chars (utf-16)")

# Fix routing
OLD_ROUTE = "'#display': () => { try { renderDisplayScreen ? renderDisplayScreen() : renderDashboard(); } catch(e) { renderDashboard(); } },"
NEW_ROUTE = "'#display': () => { renderDisplayScreen(); },"
if OLD_ROUTE in content:
    content = content.replace(OLD_ROUTE, NEW_ROUTE)
    print("Fixed: routing updated")
else:
    print("Routing already clean or not found - skipping")

# Remove old renderDisplayScreen if present
start = content.find("function renderDisplayScreen() {")
if start != -1:
    end = content.find("\nfunction approveBooking(", start)
    if end == -1:
        end = content.find("\r\nfunction approveBooking(", start)
    if end != -1:
        content = content[:start] + content[end:]
        print(f"Removed old renderDisplayScreen ({end-start} chars)")
    else:
        print("WARNING: Could not find end of old renderDisplayScreen")
else:
    print("No existing renderDisplayScreen found")

# Inject new function before approveBooking
insert_at = content.find("function approveBooking(")
if insert_at == -1:
    print("ERROR: Cannot find function approveBooking - aborting")
    sys.exit(1)

content = content[:insert_at] + NEW_FUNC + "\n" + content[insert_at:]
print(f"Injected new renderDisplayScreen before approveBooking")

# Verify
if "WAITING QUEUE" in content:
    print("Verified: WAITING QUEUE present")
else:
    print("WARNING: WAITING QUEUE not found")

if "CHAIR STATUS" in content:
    print("Verified: CHAIR STATUS present")
else:
    print("WARNING: CHAIR STATUS missing")

# Write output
with open(OUTPUT, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Saved: {OUTPUT} ({len(content)} chars)")
print("\nDone! Now run:")
print("  git add public/index.html")
print("  git commit -m 'fix: Display screen working'")
print("  git push origin main")
