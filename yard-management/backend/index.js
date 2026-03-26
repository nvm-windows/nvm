import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import { v4 as uuidv4 } from 'uuid';

const app = express();
app.use(cors());
app.use(bodyParser.json());

const users = [{ id: 'user1', username: 'admin', password: 'admin' }];
const validTokens = new Set();

const yardSlots = [];
const rows = ['A', 'B', 'C'];
const cols = ['1', '2', '3', '4'];
for (const r of rows) {
  for (const c of cols) {
    yardSlots.push({ id: `${r}${c}`, containerId: null });
  }
}

const containers = [];

function checkAuth(req, res, next) {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  if (!token || !validTokens.has(token)) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find((u) => u.username === username && u.password === password);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = uuidv4();
  validTokens.add(token);
  res.json({ token, user: { id: user.id, username: user.username } });
});

app.get('/api/containers', checkAuth, (req, res) => {
  res.json(containers);
});

app.post('/api/containers', checkAuth, (req, res) => {
  const { tag, type, locationId } = req.body;
  if (!tag || !locationId) {
    return res.status(400).json({ error: 'tag and locationId required' });
  }

  const location = yardSlots.find((s) => s.id === locationId);
  if (!location) return res.status(400).json({ error: 'Location not found' });
  if (location.containerId) return res.status(400).json({ error: 'Location occupied' });

  const newContainer = { id: uuidv4(), tag, type: type || 'general', locationId, lastUpdatedAt: new Date().toISOString() };
  containers.push(newContainer);
  location.containerId = newContainer.id;
  res.status(201).json(newContainer);
});

app.put('/api/containers/:id/move', checkAuth, (req, res) => {
  const { id } = req.params;
  const { locationId } = req.body;

  const container = containers.find((c) => c.id === id);
  if (!container) return res.status(404).json({ error: 'Container not found' });

  const target = yardSlots.find((s) => s.id === locationId);
  if (!target) return res.status(400).json({ error: 'Target location not found' });
  if (target.containerId) return res.status(400).json({ error: 'Target occupied' });

  const current = yardSlots.find((s) => s.id === container.locationId);
  if (current) current.containerId = null;

  target.containerId = container.id;
  container.locationId = locationId;
  container.lastUpdatedAt = new Date().toISOString();
  res.json(container);
});

app.get('/api/containers/search', checkAuth, (req, res) => {
  const q = String(req.query.q || '').trim().toLowerCase();
  if (!q) return res.json([]);

  const filtered = containers.filter((c) => c.tag.toLowerCase().includes(q) || c.locationId.toLowerCase().includes(q));
  res.json(filtered);
});

app.get('/api/yard/summary', checkAuth, (req, res) => {
  const occupied = yardSlots.filter((slot) => slot.containerId).length;
  const empty = yardSlots.length - occupied;
  res.json({ totalSlots: yardSlots.length, occupied, empty, totalContainers: containers.length });
});

app.get('/api/yard/slots', checkAuth, (req, res) => {
  const list = yardSlots.map((slot) => ({ ...slot, container: containers.find((c) => c.id === slot.containerId) || null }));
  res.json(list);
});

app.listen(4000, () => {
  console.log('Yard management backend running at http://localhost:4000');
});
