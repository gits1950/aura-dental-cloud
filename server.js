// ============================================================
// 🦷 AURA DENTAL CLINIC — CLEAN CLOUD SERVER
// ============================================================

require('dotenv').config();

const express  = require('express');
const http     = require('http');
const { Server } = require('socket.io');
const mysql    = require('mysql2/promise');
const cors     = require('cors');
const path     = require('path');

const app    = express();
const server = http.createServer(app);
const io     = new Server(server, { cors: { origin: '*' } });

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ================= DATABASE =================
const db = mysql.createPool({
  host:     process.env.DB_HOST,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

db.getConnection()
  .then(c => { console.log('✅ MySQL connected'); c.release(); })
  .catch(e => console.warn('⚠️ MySQL not connected:', e.message));

// ================= SOCKET =================
io.on('connection', socket => {
  console.log('🔌 Client connected:', socket.id);

  socket.on('sendPrescription', data => {
    io.emit('newPrescription', { ...data, time: new Date().toISOString() });
  });

  socket.on('prescriptionPrinted', data => {
    io.emit('prescriptionPrinted', { ...data, time: new Date().toISOString() });
  });

  socket.on('confirmPayment', data => {
    io.emit('paymentConfirmed', { ...data, time: new Date().toISOString() });
  });

  socket.on('disconnect', () => console.log('❌ Disconnected:', socket.id));
});

// ================= API ROUTES =================
app.use('/api/patients', require('./routes/patients'));
app.use('/api/visits', require('./routes/visits'));
app.use('/api/queue', require('./routes/queue'));
app.use('/api/reference', require('./routes/reference'));

// SPA fallback
app.get('*', (req, res) =>
  res.sendFile(path.join(__dirname, 'public', 'index.html'))
);

// ================= START =================
const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🦷 Aura Dental running on http://localhost:${PORT}`);
});