/* SkyHighShop mini app — Telegram WebApp storefront */
(() => {
  const tg = window.Telegram?.WebApp;
  const SOL_ADDRESS = '3zZNiqGxXdupPNfEGsqRKE3x4ZFTzjTWvuVpbewFKYUH';
  const $ = (id) => document.getElementById(id);

  const store = {
    get(key, fallback) {
      try { return JSON.parse(localStorage.getItem('shs_' + key)) ?? fallback; }
      catch { return fallback; }
    },
    set(key, value) { localStorage.setItem('shs_' + key, JSON.stringify(value)); },
  };

  const state = {
    balance: store.get('balance', 0),
    cart: store.get('cart', []),
    city: store.get('city', 'Budaörs'),
    district: store.get('district', 'Belváros'),
    bet: store.get('bet', 500),
    theme: store.get('theme', 'sky'),
    accent: store.get('accent', ''),
    snow: store.get('snow', false),
    haptics: tg?.HapticFeedback,
  };

  const fmt = (n) => new Intl.NumberFormat('hu-HU').format(Math.round(n)) + ' Ft';

  function toast(msg) {
    const t = $('toast');
    t.textContent = msg;
    t.classList.remove('hidden');
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.add('hidden'), 1800);
  }

  function copy(text) {
    if (navigator.clipboard?.writeText) {
      navigator.clipboard.writeText(text).then(() => toast('Copied ✓'));
    } else {
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      ta.remove();
      toast('Copied ✓');
    }
  }

  document.querySelectorAll('.copy-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const el = $(btn.dataset.copy);
      if (el) copy(el.textContent.trim());
    });
  });

  /* ---------- Telegram ---------- */
  if (tg) {
    tg.ready();
    tg.expand();
    tg.setHeaderColor('#121212');
    tg.setBackgroundColor('#121212');
    $('closeBtn').addEventListener('click', () => tg.close());
  } else {
    $('closeBtn').addEventListener('click', () => toast('Running outside Telegram'));
  }

  const user = tg?.initDataUnsafe?.user;
  const username = user?.username || 'DzsukliSupport';
  const displayName = user?.first_name || 'DzsukliSupport';
  $('supportUser').textContent = displayName;
  $('profileName').textContent = displayName;
  $('detailUser').textContent = '@' + username;
  $('detailTg').textContent = String(user?.id || '6331949534');
  $('detailUid').textContent = String(user?.id || '3255').slice(-4);
  $('avatar').textContent = displayName.slice(0, 2).toUpperCase();
  $('solAddress').textContent = SOL_ADDRESS;

  /* ---------- navigation ---------- */
  const navItems = document.querySelectorAll('.nav-item');
  const screens = document.querySelectorAll('.screen');
  navItems.forEach((item) => {
    item.addEventListener('click', () => {
      state.haptics?.selectionChanged();
      const target = item.dataset.screen;
      navItems.forEach((n) => n.classList.toggle('active', n === item));
      screens.forEach((s) => s.classList.toggle('hidden', s.id !== 'screen-' + target));
      if (target === 'rewards') plinko.draw();
    });
  });

  /* ---------- store ---------- */
  const PRODUCTS = [
    { name: 'Choco Bites 200g', price: 890, icon: '🍫', tag: 'snack' },
    { name: 'Energy Boost 250ml', price: 590, icon: '🥤', tag: 'drink' },
    { name: 'Salted Peanuts 150g', price: 450, icon: '🥜', tag: 'snack' },
    { name: 'Wireless Earbuds', price: 4990, icon: '🎧' },
    { name: 'Powerbank 10 000mAh', price: 6490, icon: '🔋' },
    { name: 'USB-C Cable 1m', price: 1190, icon: '🔌' },
    { name: 'Desk Lamp Pro', price: 3990, icon: '💡' },
    { name: 'Smart Bottle 500ml', price: 2790, icon: '🧴' },
    { name: 'Gift Card 5 000', price: 5000, icon: '🎁', tag: 'digital' },
    { name: 'Phone Stand', price: 1490, icon: '📱' },
  ];

  const CITIES = ['Budaörs', 'Budapest', 'Debrecen', 'Tatabánya'];
  const DISTRICTS = ['Belváros', 'Külváros'];

  function renderCities() {
    const list = $('cityList');
    list.innerHTML = '';
    CITIES.forEach((city) => {
      const div = document.createElement('div');
      div.className = 'city';
      const expanded = city === state.city;
      const tabs = expanded
        ? `<div class="city-tabs">${DISTRICTS.map((d) =>
            `<button class="city-tab ${d === state.district ? 'selected' : ''}" data-d="${d}">${d}</button>`).join('')}</div>`
        : '';
      div.innerHTML = `
        <div class="city-top">
          <span class="city-name">📍 ${city} <span class="yellow">⚡</span></span>
          <span class="city-arrow">${expanded ? '▾' : '▸'}</span>
        </div>
        <span class="available">Available</span>
        ${tabs}`;
      div.addEventListener('click', (e) => {
        if (e.target.classList.contains('city-tab')) {
          state.district = e.target.dataset.d;
          store.set('district', state.district);
          renderCities();
          renderProducts();
          return;
        }
        state.city = city;
        state.district = DISTRICTS[0];
        store.set('city', city);
        store.set('district', state.district);
        renderCities();
        renderProducts();
        updateSaleCity();
        toast('Location: ' + city);
      });
      list.appendChild(div);
    });
  }

  function renderProducts() {
    const grid = $('productGrid');
    grid.innerHTML = '';
    const discount = 0.2;
    PRODUCTS.forEach((p) => {
      const sale = state.district === 'Belváros' && state.city === 'Budaörs';
      const finalPrice = sale ? Math.round(p.price * (1 - discount)) : p.price;
      const div = document.createElement('div');
      div.className = 'product';
      div.innerHTML = `
        <div class="product-art">
          ${sale ? `<span class="product-off">-20%</span>` : ''}
          <span>${p.icon}</span>
        </div>
        <div class="product-body">
          <span class="product-name">${p.name}</span>
          <span class="product-price">${fmt(finalPrice)}${sale ? `<s>${fmt(p.price)}</s>` : ''}</span>
          <button class="add-btn">+ Add to basket</button>
        </div>`;
      div.querySelector('.add-btn').addEventListener('click', () => addToCart(p, finalPrice));
      grid.appendChild(div);
    });
  }

  function updateSaleCity() {
    $('saleCity').textContent = state.city === 'Budaörs' && state.district === 'Belváros'
      ? 'All cities' : state.city + ' — ' + state.district;
  }

  /* ---------- basket ---------- */
  function addToCart(product, price) {
    state.cart.push({ name: product.name, icon: product.icon, price });
    store.set('cart', state.cart);
    renderBasket();
    toast('Added to basket ✓');
    state.haptics?.impactOccurred('light');
  }

  function renderBasket() {
    const items = $('basketItems');
    items.innerHTML = '';
    $('basketTitle').textContent = `Shopping Cart (${state.cart.length} item${state.cart.length === 1 ? '' : 's'})`;
    $('basketEmpty').classList.toggle('hidden', state.cart.length > 0);
    $('basketTotal').classList.toggle('hidden', state.cart.length === 0);
    let sum = 0;
    state.cart.forEach((item, i) => {
      sum += item.price;
      const div = document.createElement('div');
      div.className = 'basket-item';
      div.innerHTML = `
        <span class="bi-icon">${item.icon}</span>
        <span class="bi-name">${item.name}</span>
        <span class="bi-price">${fmt(item.price)}</span>
        <button class="rm" aria-label="Remove">×</button>`;
      div.querySelector('.rm').addEventListener('click', () => {
        state.cart.splice(i, 1);
        store.set('cart', state.cart);
        renderBasket();
      });
      items.appendChild(div);
    });
    $('basketSum').textContent = fmt(sum);
  }

  $('checkoutBtn').addEventListener('click', () => {
    const total = state.cart.reduce((a, b) => a + b.price, 0);
    if (state.balance < total) {
      toast('Not enough balance — add funds first');
      return;
    }
    state.balance -= total;
    store.set('balance', state.balance);
    state.cart = [];
    store.set('cart', state.cart);
    renderBasket();
    renderBalance();
    toast('Order placed ✓');
  });

  /* ---------- wallet / solana ---------- */
  let solPrice = null;
  let solPriceHuf = null;

  async function fetchSolPrice() {
    try {
      const res = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd,huf');
      if (!res.ok) throw new Error();
      const data = await res.json();
      solPrice = data.solana.usd;
      solPriceHuf = data.solana.huf;
      $('solUsd').textContent = '$' + solPrice.toFixed(2);
      $('solHuf').textContent = new Intl.NumberFormat('hu-HU').format(Math.round(solPriceHuf)) + ' Ft';
      $('lastUpdate').textContent = new Date().toLocaleTimeString('hu-HU', { hour: '2-digit', minute: '2-digit' });
      convert();
    } catch {
      $('solUsd').textContent = '—';
      $('solHuf').textContent = '—';
    }
  }

  function convert() {
    const sol = parseFloat($('convSol').value) || 0;
    if (solPriceHuf) {
      $('convHuf').value = new Intl.NumberFormat('hu-HU').format(sol * solPriceHuf) + ' Ft';
    } else {
      $('convHuf').value = '—';
    }
  }

  $('convSol').addEventListener('input', convert);
  $('refreshBtn').addEventListener('click', fetchSolPrice);
  setInterval(fetchSolPrice, 60000);

  $('addFundsBtn').addEventListener('click', () => {
    copy(SOL_ADDRESS);
    toast('Address copied — send SOL to fund your balance');
  });

  /* ---------- plinko ---------- */
  const ROWS = 10;
  const MULTIPLIERS = [13, 3.4, 1.2, 0.9, 0.6, 0.4, 0.6, 0.9, 1.2, 3.4, 13];
  const plinko = {
    canvas: $('plinko'),
    balls: [],
    running: false,
    queue: 0,

    draw() {
      const c = this.canvas;
      const ctx = c.getContext('2d');
      const W = c.width, H = c.height;
      ctx.clearRect(0, 0, W, H);
      ctx.fillStyle = '#0a0a0a';
      ctx.fillRect(0, 0, W, H);

      const accent = getComputedStyle(document.documentElement).getPropertyValue('--accent').trim();
      const top = 50;
      const spacing = 24;
      const cx = W / 2;
      ctx.fillStyle = accent;
      for (let r = 2; r <= ROWS; r++) {
        for (let i = 0; i <= r; i++) {
          const x = cx + (i - r / 2) * spacing;
          const y = top + r * spacing;
          ctx.beginPath();
          ctx.arc(x, y, 2.4, 0, Math.PI * 2);
          ctx.fill();
        }
      }

      const slotY = top + (ROWS + 1) * spacing + 22;
      const slotW = spacing * 0.86;
      MULTIPLIERS.forEach((m, i) => {
        const x = cx + (i - (MULTIPLIERS.length - 1) / 2) * spacing;
        const size = Math.max(1, Math.abs(m));
        let color = '#858a94';
        if (m >= 13) color = accent;
        else if (m >= 3.4) color = accent;
        else if (m < 1) color = '#d14f4f';
        ctx.fillStyle = color;
        ctx.beginPath();
        const r = 8;
        ctx.roundRect(x - slotW / 2, slotY, slotW, 22, r);
        ctx.fill();
        ctx.fillStyle = m >= 13 ? '#111' : '#fff';
        ctx.font = '700 9px "Outfit"';
        ctx.textAlign = 'center';
        ctx.fillText(m.toFixed(1), x, slotY + 14);
      });

      this.balls.forEach((b) => {
        ctx.beginPath();
        ctx.arc(b.x, b.y, 5, 0, Math.PI * 2);
        ctx.fillStyle = accent;
        ctx.shadowColor = accent;
        ctx.shadowBlur = 8;
        ctx.fill();
        ctx.shadowBlur = 0;
      });

      if (this.running || this.balls.length) requestAnimationFrame(() => this.draw());
    },

    drop() {
      const bet = state.bet;
      if (state.balance < bet) {
        toast('Not enough balance');
        return;
      }
      state.balance -= bet;
      store.set('balance', state.balance);
      renderBalance();

      const spacing = 24;
      const cx = this.canvas.width / 2;
      const balls = parseInt($('ballsPerDrop').value) || 1;
      let landed = 0;

      for (let b = 0; b < balls; b++) {
        const ball = { x: cx + (Math.random() - 0.5) * 6, y: 30, step: 0, dir: [], bet };
        ball.x0 = cx;
        this.balls.push(ball);
        this.queue++;
        setTimeout(() => {
          this.queue--;
          $('queuedLbl').textContent = 'Queued: ' + this.queue;
        }, 500 * b);
      }

      $('queuedLbl').textContent = 'Queued: ' + this.queue;
      this.running = true;

      const tick = () => {
        const activeBalls = this.balls.filter((b) => b.step < ROWS);
        activeBalls.forEach((b) => {
          if (b.step % 2 === 0) {
            b.dir.push(Math.random() < 0.5 ? -1 : 1);
          }
          const half = b.dir.length % 2 === 0 ? 0.5 : 0;
          b.x = b.x0 + b.dir.reduce((a, d) => a + d, 0) * spacing / 2 + (b.dir.length % 2 === 0 ? 0 : -spacing / 4);
          b.y = 30 + b.dir.length * spacing;
          b.step++;
          if (b.step >= ROWS) {
            const slot = Math.min(10, Math.max(0, 5 + b.dir.reduce((a, d) => a + d, 0) / 2));
            const mult = MULTIPLIERS[slot];
            const win = Math.round(b.bet * mult);
            if (win > 0) {
              state.balance += win;
              store.set('balance', state.balance);
            }
            landed++;
            toast(mult >= 1 ? `Win ${fmt(win)} (${mult}×)` : `Lost ${fmt(b.bet)} (${mult}×)`);
            state.haptics?.impactOccurred(mult >= 1 ? 'medium' : 'light');
            renderBalance();
          }
        });

        this.balls = this.balls.filter((b) => b.step < ROWS + 1);
        if (this.balls.length || this.queue > 0) {
          requestAnimationFrame(tick);
        } else {
          this.running = false;
          this.draw();
        }
      };

      requestAnimationFrame(() => this.draw());
      requestAnimationFrame(tick);
    },
  };

  $('dropBtn').addEventListener('click', () => plinko.drop());

  $('betMinus').addEventListener('click', () => {
    state.bet = Math.max(100, state.bet - 250);
    store.set('bet', state.bet);
    $('betVal').textContent = fmt(state.bet);
  });
  $('betPlus').addEventListener('click', () => {
    state.bet = state.bet + 250;
    store.set('bet', state.bet);
    $('betVal').textContent = fmt(state.bet);
  });
  document.querySelectorAll('.pill[data-bet]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.bet = btn.dataset.bet === 'min' ? 100 : 750;
      store.set('bet', state.bet);
      $('betVal').textContent = fmt(state.bet);
    });
  });

  /* ---------- news ---------- */
  const NEWS = [
    { title: 'Flash sale weekend in Budaörs', time: '2026-10-26', body: 'All downtown products are 20% off this week. Select Budaörs — Belváros in the Store tab to see discounted prices.' },
    { title: 'Now accepting SOL deposits', time: '2026-10-24', body: 'You can now fund your balance with Solana. Head to the Wallet tab and copy your deposit address.' },
    { title: 'New gadget drop', time: '2026-10-21', body: 'Wireless earbuds, powerbanks and desk lamps are back in stock — limited quantity.' },
  ];
  $('newsList').innerHTML = NEWS.map((n) => `
    <div class="news-item">
      <h3>${n.title}</h3>
      <time>${n.time}</time>
      <p>${n.body}</p>
    </div>`).join('');

  /* ---------- support ---------- */
  const FAQ = [
    { q: "Can't find SafeBuy?", a: 'SafeBuy is the checkout option under the Wallet tab. Make sure you selected a city in the Store tab first.' },
    { q: 'Sent crypto to an old address', a: 'Deposits to old addresses are refunded automatically within 24 hours. Contact support with your transaction ID.' },
    { q: 'Write from the affected account', a: 'Tickets are only processed from the account experiencing the issue. Switch accounts before opening a ticket.' },
  ];
  $('faqList').innerHTML = FAQ.map((f) => `
    <div class="faq-item">
      <button class="faq-q">${f.q}</button>
      <div class="faq-a"><p>${f.a}</p></div>
    </div>`).join('');
  document.querySelectorAll('.faq-q').forEach((q) => {
    q.addEventListener('click', () => q.parentElement.classList.toggle('open'));
  });

  $('openTicketsBtn').addEventListener('click', () => toast('No open tickets'));
  $('newTicketBtn').addEventListener('click', () => toast('Ticket form coming soon'));

  /* ---------- profile tabs ---------- */
  document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.tab').forEach((t) => t.classList.toggle('active', t === tab));
      document.querySelectorAll('.tab-panel').forEach((p) => p.classList.add('hidden'));
      $('tab-' + tab.dataset.tab).classList.remove('hidden');
    });
  });

  /* ---------- appearance ---------- */
  const THEMES = { sky: null, midnight: null, toffee: null };
  function applyTheme() {
    document.documentElement.dataset.theme = state.theme;
    if (state.accent) {
      document.documentElement.style.setProperty('--accent', state.accent);
    } else {
      document.documentElement.style.removeProperty('--accent');
    }
  }

  $('themeSelect').addEventListener('change', (e) => {
    state.theme = e.target.value;
    store.set('theme', state.theme);
    applyTheme();
  });

  $('accentColor').addEventListener('input', (e) => {
    $('accentHex').value = e.target.value;
  });
  $('saveAccent').addEventListener('click', () => {
    const hex = $('accentHex').value.trim();
    if (/^#[0-9a-f]{6}$/i.test(hex)) {
      state.accent = hex;
      store.set('accent', hex);
    } else {
      state.accent = '';
      store.set('accent', '');
    }
    applyTheme();
    toast('Saved ✓');
  });

  /* ---------- effects ---------- */
  function makeSnow() {
    const box = $('snow');
    if (!box.childElementCount) {
      for (let i = 0; i < 24; i++) {
        const f = document.createElement('span');
        f.className = 'snowflake';
        f.textContent = '❄';
        f.style.left = Math.random() * 100 + '%';
        f.style.animationDuration = 5 + Math.random() * 8 + 's';
        f.style.animationDelay = Math.random() * 8 + 's';
        f.style.opacity = 0.3 + Math.random() * 0.5;
        box.appendChild(f);
      }
    }
  }

  $('snowToggle').addEventListener('change', (e) => {
    state.snow = e.target.checked;
    store.set('snow', state.snow);
    $('snow').classList.toggle('hidden', !state.snow);
    if (state.snow) makeSnow();
  });

  $('jungleToggle').addEventListener('change', (e) => {
    toast(e.target.checked ? 'Jungle mode is a decorative overlay' : 'Jungle mode off');
    document.body.style.background = e.target.checked ? 'linear-gradient(180deg, #0f1a0d, #0a0a0a)' : '';
  });

  /* ---------- countdown & sale progress ---------- */
  const SALE_END = new Date();
  SALE_END.setHours(23, 59, 59, 0);
  function tickCountdown() {
    const diff = Math.max(0, SALE_END - Date.now());
    const d = Math.floor(diff / 86400000);
    const h = Math.floor((diff % 86400000) / 3600000);
    const m = Math.floor((diff % 3600000) / 60000);
    const s = Math.floor((diff % 60000) / 1000);
    $('countdown').textContent = `${d}d ${h}h ${m}m ${s}s`;
    const dayProgress = 1 - diff / 86400000;
    $('saleProgress').style.width = Math.round(dayProgress * 100) + '%';
  }
  setInterval(tickCountdown, 1000);
  tickCountdown();

  /* ---------- balance ---------- */
  function renderBalance() {
    $('walletBalance').textContent = fmt(state.balance);
    $('plinkoBalance').textContent = fmt(state.balance);
  }

  /* ---------- init ---------- */
  $('themeSelect').value = state.theme;
  $('accentColor').value = state.accent || '#f5f5a8';
  $('accentHex').value = state.accent || '#f5f5a8';
  applyTheme();
  $('snowToggle').checked = state.snow;
  if (state.snow) makeSnow();
  $('betVal').textContent = fmt(state.bet);
  renderCities();
  renderProducts();
  updateSaleCity();
  renderBasket();
  renderBalance();
  fetchSolPrice();
  plinko.draw();
})();
