'use strict';

/* ===== Константы ===== */

const COLORS = ['#000000', '#f2454e', '#33d699', '#59b8ff', '#9e73ff', '#ff9e42', '#fac44d', '#fc7ac9'];

const SHAPES = [
  { id: 'capsule', label: 'Капсула' },
  { id: 'pill', label: 'Пилл' },
  { id: 'rounded', label: 'Круглый' },
  { id: 'squircle', label: 'Сквиркл' }
];

const CONTENTS = [
  { id: 'none', label: 'Пустой', icon: '○' },
  { id: 'music', label: 'Музыка', icon: '♪' },
  { id: 'timer', label: 'Таймер', icon: '⏱' },
  { id: 'call', label: 'Звонок', icon: '📞' },
  { id: 'camera', label: 'Камера', icon: '🎥' },
  { id: 'charging', label: 'Зарядка', icon: '⚡' }
];

const SETTINGS_META = [
  {
    group: 'Экран',
    items: [
      { id: 'showBatteryPercent', icon: '🔋', title: 'Процент заряда', sub: 'Показывать % заряда на статус-баре' },
      { id: 'showSeconds', icon: '⏱️', title: 'Секунды в часах', sub: 'Точное время с секундами' },
      { id: 'showCarrier', icon: '📡', title: 'Оператор сети', sub: 'Название оператора под временем' },
      { id: 'hideDock', icon: '📱', title: 'Скрыть Dock', sub: 'Убрать панель быстрых приложений' },
      { id: 'autoNight', icon: '🌙', title: 'Авто-ночь', sub: 'Ночная подсветка экрана' }
    ]
  },
  {
    group: 'Батарея',
    items: [
      { id: 'lowBattery', icon: '🪫', title: 'Низкий заряд: 12%', sub: 'Показывать предупреждение о разряде' },
      { id: 'adaptiveBrightness', icon: '☀️', title: 'Адаптивная яркость', sub: 'Яркость по окружающему свету' },
      { id: 'ultraPower', icon: '🍃', title: 'Сверхэкономия', sub: 'Максимальная экономия энергии' }
    ]
  },
  {
    group: 'Звук и тактильность',
    items: [
      { id: 'hapticToggles', icon: '📳', title: 'Тактильные отклики', sub: 'Вибрация при переключении' },
      { id: 'silentOnLock', icon: '🔕', title: 'Тишина при блокировке', sub: 'Глушить звук на заблокированном экране' }
    ]
  },
  {
    group: 'Система',
    items: [
      { id: 'developerMode', icon: '🛠️', title: 'Режим разработчика', sub: 'Служебные данные и отладка' },
      { id: 'showFPS', icon: '🏎️', title: 'Счётчик FPS', sub: 'Показывать частоту кадров' },
      { id: 'autoUpdate', icon: '🔄', title: 'Автообновление', sub: 'Обновлять приложения автоматически' },
      { id: 'privateSafari', icon: '️', title: 'Приватный Safari', sub: 'Автоматически открывать приватную вкладку' }
    ]
  }
];

const DEFAULT_SETTINGS = {
  showBatteryPercent: true,
  showSeconds: false,
  showCarrier: true,
  hideDock: false,
  autoNight: false,
  lowBattery: false,
  adaptiveBrightness: false,
  ultraPower: false,
  hapticToggles: true,
  silentOnLock: false,
  developerMode: false,
  showFPS: false,
  autoUpdate: true,
  privateSafari: false
};

/* ===== Состояние ===== */

const state = loadState();

function loadState() {
  let stored = {};
  try {
    stored = JSON.parse(localStorage.getItem('ultratools') || '{}') || {};
  } catch (e) {
    stored = {};
  }
  return {
    island: Object.assign(
      { name: 'Мой островок', shape: 'capsule', content: 'music', colorIndex: 0, gradient: true, pulse: true, scale: 1 },
      stored.island
    ),
    settings: Object.assign({}, DEFAULT_SETTINGS, stored.settings),
    presets: Array.isArray(stored.presets) ? stored.presets : []
  };
}

function saveState() {
  localStorage.setItem('ultratools', JSON.stringify(state));
}

function escapeHTML(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
}

function haptic() {
  if (state.settings.hapticToggles && navigator.vibrate) navigator.vibrate(10);
}

/* ===== Островок ===== */

function renderIsland() {
  const el = document.getElementById('island');
  const s = state.island;

  let w = 118 * s.scale;
  if (s.shape === 'pill') w *= 1.45;
  el.style.width = Math.round(w) + 'px';
  el.style.height = '36px';

  const radii = { capsule: 999, pill: 999, rounded: 12, squircle: 16 };
  el.style.borderRadius = radii[s.shape] + 'px';

  const c1 = COLORS[s.colorIndex];
  const c2 = COLORS[(s.colorIndex + 2) % COLORS.length];
  el.style.background = s.gradient
    ? `linear-gradient(135deg, ${c1}, ${c2})`
    : c1;
  el.classList.toggle('pulse', !!s.pulse);
  el.innerHTML = islandContentHTML(s.content);
}

function islandContentHTML(content) {
  switch (content) {
    case 'none':
      return '<span class="cam"></span>';
    case 'music':
      return '<span class="ic">♪</span><span class="bar"><i style="width:62%"></i></span><span class="t">4:12</span>';
    case 'timer':
      return '<span class="ic">⏱</span><span class="t">12:34</span>';
    case 'call':
      return '<span class="ic">📞</span><span class="dots"><i></i><i></i><i></i></span>';
    case 'camera':
      return '<span class="ic">🎥</span><span class="t rec">REC</span><span class="recdot"></span>';
    case 'charging':
      return '<span class="ic">⚡</span><span class="t">87%</span>';
    default:
      return '';
  }
}

function syncIslandUI() {
  const s = state.island;

  document.getElementById('island-name').value = s.name;
  document.getElementById('tg-gradient').checked = !!s.gradient;
  document.getElementById('tg-pulse').checked = !!s.pulse;
  document.getElementById('scale').value = s.scale;
  document.getElementById('scale-value').textContent = Math.round(s.scale * 100) + '%';

  document.querySelectorAll('#shape-chips .chip').forEach((b) => {
    b.classList.toggle('active', b.dataset.id === s.shape);
  });
  document.querySelectorAll('#content-chips .chip').forEach((b) => {
    b.classList.toggle('active', b.dataset.id === s.content);
  });
  document.querySelectorAll('#swatches .swatch').forEach((b, i) => {
    b.classList.toggle('active', i === s.colorIndex);
  });
}

function buildIslandControls() {
  const shapes = document.getElementById('shape-chips');
  SHAPES.forEach((sh) => {
    const b = document.createElement('button');
    b.className = 'chip';
    b.type = 'button';
    b.dataset.id = sh.id;
    b.textContent = sh.label;
    b.onclick = () => {
      state.island.shape = sh.id;
      saveState();
      syncIslandUI();
      renderIsland();
    };
    shapes.appendChild(b);
  });

  const contents = document.getElementById('content-chips');
  CONTENTS.forEach((c) => {
    const b = document.createElement('button');
    b.className = 'chip';
    b.type = 'button';
    b.dataset.id = c.id;
    b.textContent = `${c.icon} ${c.label}`;
    b.onclick = () => {
      state.island.content = c.id;
      saveState();
      syncIslandUI();
      renderIsland();
    };
    contents.appendChild(b);
  });

  const swatches = document.getElementById('swatches');
  COLORS.forEach((c, i) => {
    const b = document.createElement('span');
    b.className = 'swatch';
    b.style.background = c;
    b.title = 'Цвет ' + (i + 1);
    b.onclick = () => {
      state.island.colorIndex = i;
      saveState();
      syncIslandUI();
      renderIsland();
    };
    swatches.appendChild(b);
  });

  document.getElementById('island-name').addEventListener('input', (e) => {
    state.island.name = e.target.value;
    saveState();
  });

  document.getElementById('tg-gradient').addEventListener('change', (e) => {
    state.island.gradient = e.target.checked;
    saveState();
    renderIsland();
  });

  document.getElementById('tg-pulse').addEventListener('change', (e) => {
    state.island.pulse = e.target.checked;
    saveState();
    renderIsland();
  });

  document.getElementById('scale').addEventListener('input', (e) => {
    state.island.scale = parseFloat(e.target.value);
    document.getElementById('scale-value').textContent = Math.round(state.island.scale * 100) + '%';
    saveState();
    renderIsland();
  });

  document.getElementById('save-preset').onclick = () => {
    state.presets.push(Object.assign({}, state.island, { id: Date.now() }));
    saveState();
    renderPresets();
  };

  document.getElementById('export-png').onclick = exportPNG;
}

/* ===== Пресеты ===== */

function shapeLabel(id) {
  const s = SHAPES.find((x) => x.id === id);
  return s ? s.label : id;
}

function contentLabel(id) {
  const c = CONTENTS.find((x) => x.id === id);
  return c ? c.label : id;
}

function renderPresets() {
  const list = document.getElementById('preset-list');
  list.innerHTML = '';

  if (!state.presets.length) {
    list.innerHTML = '<div class="empty">Пока пусто — настройте островок и сохраните его.</div>';
    return;
  }

  state.presets.forEach((p) => {
    const row = document.createElement('div');
    row.className = 'preset-row';

    const c1 = COLORS[p.colorIndex];
    const c2 = COLORS[(p.colorIndex + 2) % COLORS.length];
    const bg = p.gradient ? `linear-gradient(135deg, ${c1}, ${c2})` : c1;

    row.innerHTML =
      `<span class="p-dot" style="background:${bg}"></span>` +
      `<span class="p-name">${escapeHTML(p.name)}<small>${escapeHTML(shapeLabel(p.shape))} • ${escapeHTML(contentLabel(p.content))}</small></span>`;

    const apply = document.createElement('button');
    apply.className = 'p-btn';
    apply.type = 'button';
    apply.textContent = 'Применить';
    apply.onclick = () => {
      state.island = Object.assign({}, state.island, p);
      saveState();
      syncIslandUI();
      renderIsland();
    };

    const del = document.createElement('button');
    del.className = 'p-btn danger';
    del.type = 'button';
    del.textContent = '✕';
    del.onclick = () => {
      state.presets = state.presets.filter((x) => x.id !== p.id);
      saveState();
      renderPresets();
    };

    row.append(apply, del);
    list.appendChild(row);
  });
}

/* ===== Статус-бар ===== */

function fpsValue() {
  return 58 + Math.floor(Math.random() * 4);
}

function renderStatusBar() {
  const now = new Date();
  const p = (n) => String(n).padStart(2, '0');

  const time = state.settings.showSeconds
    ? `${p(now.getHours())}:${p(now.getMinutes())}:${p(now.getSeconds())}`
    : `${p(now.getHours())}:${p(now.getMinutes())}`;
  document.getElementById('sb-time').textContent = time;

  document.getElementById('sb-carrier').style.display = state.settings.showCarrier ? '' : 'none';

  const fps = document.getElementById('sb-fps');
  fps.style.display = state.settings.showFPS ? '' : 'none';
  if (state.settings.showFPS) fps.textContent = fpsValue() + ' FPS';

  const low = !!state.settings.lowBattery;
  const pct = low ? 12 : 87;

  document.getElementById('sb-batt-pct').style.display = state.settings.showBatteryPercent ? '' : 'none';
  document.getElementById('sb-batt-pct').textContent = pct;

  const fill = document.getElementById('batt-fill');
  fill.style.width = pct + '%';
  fill.style.background = low ? '#f2454e' : '#33d699';
}

/* ===== Обои / макет ===== */

function renderWallpaper() {
  const s = state.settings;
  const wp = document.getElementById('wallpaper');
  wp.classList.toggle('night', !!s.autoNight);
  wp.classList.toggle('ultra', !!s.ultraPower);
  wp.classList.toggle('adaptive', !!s.adaptiveBrightness);

  document.getElementById('dock').style.display = s.hideDock ? 'none' : '';
  document.getElementById('devbadge').style.display = s.developerMode ? '' : 'none';
  document.getElementById('toast').style.display = s.lowBattery ? '' : 'none';
}

/* ===== Настройки ===== */

function buildSettings() {
  const wrap = document.getElementById('settings-list');
  wrap.innerHTML = '';

  SETTINGS_META.forEach((g) => {
    const card = document.createElement('div');
    card.className = 'card';

    const title = document.createElement('div');
    title.className = 'group-title';
    title.textContent = g.group;
    card.appendChild(title);

    g.items.forEach((item) => {
      const row = document.createElement('label');
      row.className = 'setting-row';
      row.innerHTML =
        `<span class="s-icon">${item.icon}</span>` +
        `<span class="s-text"><span>${escapeHTML(item.title)}</span><small>${escapeHTML(item.sub)}</small></span>` +
        `<span class="switch"><input type="checkbox" data-setting="${item.id}"><i></i></span>`;
      card.appendChild(row);
    });

    wrap.appendChild(card);
  });

  wrap.querySelectorAll('input[data-setting]').forEach((inp) => {
    inp.checked = !!state.settings[inp.dataset.setting];
    inp.addEventListener('change', (e) => {
      state.settings[inp.dataset.setting] = e.target.checked;
      haptic();
      saveState();
      renderAll();
    });
  });
}

document.getElementById('reset-settings').onclick = () => {
  state.settings = Object.assign({}, DEFAULT_SETTINGS);
  saveState();
  buildSettings();
  renderAll();
};

/* ===== Экспорт PNG ===== */

function roundRectPath(ctx, x, y, w, h, r) {
  r = Math.min(r, w / 2, h / 2);
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

function exportPNG() {
  const s = state.island;
  const W = 340, H = 140, k = 4;

  const canvas = document.createElement('canvas');
  canvas.width = W * k;
  canvas.height = H * k;
  const ctx = canvas.getContext('2d');
  ctx.scale(k, k);

  // фон
  ctx.fillStyle = '#0a0d16';
  ctx.fillRect(0, 0, W, H);

  // островок
  const h = 44 * s.scale;
  let w = 150 * s.scale;
  if (s.shape === 'pill') w *= 1.45;
  const x = (W - w) / 2;
  const y = (H - h) / 2;

  const radii = { capsule: h / 2, pill: h / 2, rounded: h * 0.3, squircle: h * 0.45 };
  const c1 = COLORS[s.colorIndex];
  const c2 = COLORS[(s.colorIndex + 2) % COLORS.length];

  let fill;
  if (s.gradient) {
    const g = ctx.createLinearGradient(x, y, x + w, y + h);
    g.addColorStop(0, c1);
    g.addColorStop(1, c2);
    fill = g;
  } else {
    fill = c1;
  }

  ctx.fillStyle = fill;
  ctx.beginPath();
  if (typeof ctx.roundRect === 'function') {
    ctx.roundRect(x, y, w, h, radii[s.shape]);
  } else {
    roundRectPath(ctx, x, y, w, h, radii[s.shape]);
  }
  ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255,0.2)';
  ctx.lineWidth = 1;
  ctx.stroke();

  // содержимое
  ctx.fillStyle = '#fff';
  ctx.font = '600 15px -apple-system, "SF Pro Text", system-ui, sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  const cx = W / 2;
  const cy = H / 2;

  switch (s.content) {
    case 'none':
      ctx.beginPath();
      ctx.arc(cx, cy, 6, 0, Math.PI * 2);
      ctx.fillStyle = '#1b2c44';
      ctx.fill();
      ctx.beginPath();
      ctx.arc(cx, cy, 2.2, 0, Math.PI * 2);
      ctx.fillStyle = '#4f7fd9';
      ctx.fill();
      break;
    case 'music':
      ctx.fillText('♪   4:12', cx, cy + 1);
      break;
    case 'timer':
      ctx.fillText('⏱   12:34', cx, cy + 1);
      break;
    case 'call':
      ctx.fillText('●   ●   ●', cx, cy + 1);
      break;
    case 'camera':
      ctx.fillText('🎥   REC', cx, cy + 1);
      break;
    case 'charging':
      ctx.fillText('⚡   87%', cx, cy + 1);
      break;
  }

  canvas.toBlob((blob) => {
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `ultra-island-${Date.now()}.png`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 5000);
  });
}

/* ===== Вкладки ===== */

function initTabs() {
  const buttons = document.querySelectorAll('.nav button');
  buttons.forEach((btn) => {
    btn.onclick = () => {
      buttons.forEach((b) => b.classList.toggle('active', b === btn));
      document.querySelectorAll('.tab').forEach((t) => {
        t.classList.toggle('active', t.id === 'tab-' + btn.dataset.tab);
      });
    };
  });
}

/* ===== Инициализация ===== */

function renderAll() {
  renderIsland();
  renderStatusBar();
  renderWallpaper();
  renderPresets();
}

function init() {
  buildIslandControls();
  buildSettings();
  initTabs();
  syncIslandUI();
  renderAll();
  setInterval(renderStatusBar, 1000);
}

document.addEventListener('DOMContentLoaded', init);
