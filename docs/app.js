(() => {
  'use strict';

  const GENRES = window.GENRES;
  const SHOPS = window.SHOPS;
  const DEMO_REVIEWS = window.DEMO_REVIEWS;
  const LS_KEY = 'ramen_ikitai_v1';
  // 疑似的な「イキタイ」数（コミュニティ感を出すためのダミー）
  const DEMO_WANTS = {
    s01: 342, s02: 128, s03: 89, s04: 256, s05: 198, s06: 421,
    s07: 167, s08: 72, s09: 143, s10: 58, s11: 94, s12: 103,
    s13: 215, s14: 186, s15: 312, s16: 145, s17: 98, s18: 234,
    s19: 121, s20: 287, s21: 176, s22: 298, s23: 389, s24: 201,
    s25: 156, s26: 244, s27: 87, s28: 112, s29: 456, s30: 378,
    s31: 163, s32: 189,
  };

  // ---------- Store ----------
  const Store = {
    data: null,
    load() {
      try {
        const raw = localStorage.getItem(LS_KEY);
        if (raw) { this.data = JSON.parse(raw); }
      } catch (e) { console.warn('load failed', e); }
      if (!this.data) {
        this.data = {
          reviews: DEMO_REVIEWS.slice(),
          wants: ['s01', 's05'],
          profile: { name: 'ラーメン好き', note: '' },
        };
        this.save();
      }
      if (!this.data.reviews) this.data.reviews = [];
      if (!this.data.wants) this.data.wants = [];
      if (!this.data.profile) this.data.profile = { name: 'ラーメン好き', note: '' };
    },
    save() {
      try { localStorage.setItem(LS_KEY, JSON.stringify(this.data)); }
      catch (e) { console.warn('save failed', e); alert('保存できませんでした（ストレージ容量不足の可能性）'); }
    },
    reviewsByShop(id) {
      return this.data.reviews.filter(r => r.shopId === id)
        .sort((a, b) => new Date(b.visitedAt) - new Date(a.visitedAt));
    },
    shopRating(id) {
      const rs = this.data.reviews.filter(r => r.shopId === id);
      if (!rs.length) return 0;
      return rs.reduce((s, r) => s + (r.rating || 0), 0) / rs.length;
    },
    shopReviewCount(id) {
      return this.data.reviews.filter(r => r.shopId === id).length;
    },
    shopWantCount(id) {
      let base = this.isWanted(id) ? 1 : 0;
      const demo = DEMO_WANTS[id] || 0;
      return base + demo;
    },
    shopTrendScore(id) {
      const rs = this.data.reviews.filter(r => r.shopId === id);
      const recent = rs.filter(r => (Date.now() - new Date(r.visitedAt).getTime()) < 14 * 86400000).length;
      return recent * 10 + this.shopReviewCount(id) + this.shopWantCount(id) * 2 + this.shopRating(id);
    },
    prefRank(shop) {
      const siblings = SHOPS.filter(s => s.pref === shop.pref)
        .sort((a, b) => {
          const d = this.shopRating(b.id) - this.shopRating(a.id);
          return d !== 0 ? d : this.shopReviewCount(b.id) - this.shopReviewCount(a.id);
        });
      return siblings.findIndex(s => s.id === shop.id) + 1;
    },
    toggleWant(id) {
      const i = this.data.wants.indexOf(id);
      if (i >= 0) this.data.wants.splice(i, 1);
      else this.data.wants.push(id);
      this.save();
    },
    isWanted(id) { return this.data.wants.includes(id); },
    addReview(r) { this.data.reviews.unshift(r); this.save(); },
    removeReview(id) {
      this.data.reviews = this.data.reviews.filter(r => r.id !== id);
      this.save();
    },
    resetAll() {
      localStorage.removeItem(LS_KEY);
      this.data = null;
      this.load();
    },
    latestPhoto(shopId) {
      const rs = this.reviewsByShop(shopId);
      for (const r of rs) {
        if (r.photos && r.photos.length) return r.photos[0];
      }
      return null;
    },
  };

  // ---------- Utils ----------
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const genre = k => GENRES.find(g => g.key === k) || GENRES[0];
  const stars = v => {
    const n = Math.round(v);
    return '★'.repeat(n) + '☆'.repeat(5 - n);
  };
  const fmtDate = iso => {
    const d = new Date(iso);
    if (isNaN(d)) return '';
    return `${d.getFullYear()}/${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`;
  };
  const relDate = iso => {
    const d = new Date(iso);
    const diff = Date.now() - d.getTime();
    const day = Math.floor(diff / 86400000);
    if (day === 0) return '今日';
    if (day === 1) return '昨日';
    if (day < 7) return `${day}日前`;
    if (day < 30) return `${Math.floor(day / 7)}週間前`;
    return fmtDate(iso);
  };

  // ---------- Router ----------
  const views = {};
  function showView(name, ctx) {
    $$('.view').forEach(v => v.hidden = v.dataset.view !== name);
    $$('.tab-item').forEach(b => b.classList.toggle('active', b.dataset.go === name));
    if (views[name]) views[name](ctx);
    window.scrollTo(0, 0);
  }

  // ---------- Home ----------
  views.home = () => {
    const totalReviews = Store.data.reviews.length;
    $('#st-shops').textContent = SHOPS.length;
    $('#st-reviews').textContent = totalReviews;
    $('#st-wants').textContent = Store.data.wants.length;
    const stTop = $('#st-shops-top');
    if (stTop) stTop.textContent = SHOPS.length;

    $('#genre-grid').innerHTML = GENRES.map(g => {
      const cnt = SHOPS.filter(s => s.genre === g.key).length;
      return `<button class="genre-card" data-genre="${g.key}">
        <span class="ico">${g.emoji}</span>
        <div class="name">${esc(g.name)}</div>
        <div class="cnt">${cnt}店</div>
      </button>`;
    }).join('');
    $$('#genre-grid .genre-card').forEach(el => {
      el.onclick = () => { State.filterGenre = el.dataset.genre; showView('search'); };
    });

    const trending = SHOPS.slice().sort((a, b) => Store.shopTrendScore(b.id) - Store.shopTrendScore(a.id)).slice(0, 5);
    $('#trending').innerHTML = trending.map(s => shopCardHTML(s, { trending: true })).join('');
    $$('#trending .shop-card').forEach(el => {
      el.onclick = () => openShop(el.dataset.id);
    });

    const featured = SHOPS.slice().sort((a, b) => Store.shopRating(b.id) - Store.shopRating(a.id)).slice(0, 6);
    $('#featured').innerHTML = featured.map(s => shopCardHTML(s, { showRank: true })).join('');
    $$('#featured .shop-card').forEach(el => {
      el.onclick = () => openShop(el.dataset.id);
    });

    const recent = Store.data.reviews.slice(0, 5);
    $('#recent-activity').innerHTML = recent.length
      ? recent.map(r => activityHTML(r)).join('')
      : `<div class="empty"><span class="emoji">🍜</span>まだラー活がありません</div>`;
    $$('#recent-activity .activity-item').forEach(el => {
      el.onclick = () => openShop(el.dataset.id);
    });
  };

  function rankBadgeHTML(n) {
    if (n <= 0 || n > 3) return '';
    const cls = n === 1 ? 'gold' : n === 2 ? 'silver' : 'bronze';
    return `<span class="rank-badge ${cls}"><span class="crown">👑</span>${n}位</span>`;
  }

  function statsRowHTML(s) {
    const rating = Store.shopRating(s.id);
    return `<div class="shop-stats">
      <span class="stat-item rating"><span class="ico">⭐</span><span class="num">${rating > 0 ? rating.toFixed(1) : '-'}</span></span>
      <span class="sep">|</span>
      <span class="stat-item"><span class="ico">📝</span><span class="num">${Store.shopReviewCount(s.id)}</span>ラー活</span>
      <span class="sep">|</span>
      <span class="stat-item"><span class="ico">🔖</span><span class="num">${Store.shopWantCount(s.id)}</span>行きたい</span>
    </div>`;
  }

  function shopCardHTML(s, opt = {}) {
    const g = genre(s.genre);
    const photo = Store.latestPhoto(s.id);
    const thumb = photo
      ? `<img src="${photo}" alt="">`
      : `<span>${g.emoji}</span>`;
    const rank = opt.showRank ? Store.prefRank(s) : 0;
    const rankOv = (opt.showRank && rank <= 3) ? `<div class="rank-badge-ov">${rankBadgeHTML(rank)}</div>` : '';
    const trending = opt.trending ? `<span class="trending-badge">🔥 急上昇</span>` : '';
    return `<div class="shop-card" data-id="${s.id}" style="position:relative">
      ${rankOv}
      <div class="shop-thumb" style="background:${g.color}">
        ${thumb}
        <span class="genre-tag">${esc(g.name)}</span>
      </div>
      <div class="shop-body">
        ${trending ? `<div style="margin-bottom:4px">${trending}</div>` : ''}
        <div class="shop-name">${esc(s.name)}</div>
        <div class="shop-meta">${esc(s.pref)} ${esc(s.area)}</div>
        ${statsRowHTML(s)}
      </div>
    </div>`;
  }

  function activityHTML(r) {
    const s = SHOPS.find(x => x.id === r.shopId);
    if (!s) return '';
    const g = genre(s.genre);
    const photos = (r.photos || []).slice(0, 3)
      .map(p => `<img src="${p}" alt="">`).join('');
    return `<div class="activity-item" data-id="${s.id}">
      <div class="act-avatar" style="background:${g.color}22">${g.emoji}</div>
      <div class="act-main">
        <div class="act-head">
          <span class="act-shop">${esc(s.name)}</span>
          <span class="act-date">${relDate(r.visitedAt)}</span>
        </div>
        <div class="act-menu">${esc(r.menu)} ・ ${stars(r.rating)}</div>
        ${r.comment ? `<div class="act-comment">${esc(r.comment)}</div>` : ''}
        ${photos ? `<div class="act-photos">${photos}</div>` : ''}
      </div>
    </div>`;
  }

  // ---------- Search ----------
  const State = { filterGenre: '', query: '', sort: 'rating', pref: '', wantsOnly: false };

  views.search = () => {
    const chipRow = $('#chip-row');
    chipRow.innerHTML = [
      `<button class="chip${State.filterGenre === '' ? ' active' : ''}" data-g="">すべて</button>`,
      ...GENRES.map(g => `<button class="chip${State.filterGenre === g.key ? ' active' : ''}" data-g="${g.key}">${g.emoji} ${esc(g.name)}</button>`),
    ].join('');
    $$('#chip-row .chip').forEach(el => {
      el.onclick = () => { State.filterGenre = el.dataset.g; views.search(); };
    });

    const prefSel = $('#pref-select');
    if (!prefSel.dataset.init) {
      const prefs = [...new Set(SHOPS.map(s => s.pref))].sort();
      prefSel.innerHTML = `<option value="">すべてのエリア</option>` +
        prefs.map(p => `<option value="${esc(p)}">${esc(p)}</option>`).join('');
      prefSel.dataset.init = '1';
      prefSel.onchange = () => { State.pref = prefSel.value; views.search(); };
      $('#sort-select').onchange = () => { State.sort = $('#sort-select').value; views.search(); };
      $('#wants-only').onchange = () => { State.wantsOnly = $('#wants-only').checked; views.search(); };
      $('#search-input').oninput = () => { State.query = $('#search-input').value; views.search(); };
    }
    prefSel.value = State.pref;
    $('#sort-select').value = State.sort;
    $('#wants-only').checked = State.wantsOnly;
    $('#search-input').value = State.query;

    let list = SHOPS.slice();
    if (State.filterGenre) list = list.filter(s => s.genre === State.filterGenre);
    if (State.pref) list = list.filter(s => s.pref === State.pref);
    if (State.wantsOnly) list = list.filter(s => Store.isWanted(s.id));
    if (State.query) {
      const q = State.query.toLowerCase();
      list = list.filter(s =>
        s.name.toLowerCase().includes(q) ||
        (s.kana || '').toLowerCase().includes(q) ||
        s.area.toLowerCase().includes(q) ||
        s.pref.toLowerCase().includes(q) ||
        genre(s.genre).name.includes(State.query)
      );
    }
    list.sort((a, b) => {
      if (State.sort === 'rating') return Store.shopRating(b.id) - Store.shopRating(a.id);
      if (State.sort === 'reviews') return Store.shopReviewCount(b.id) - Store.shopReviewCount(a.id);
      return a.kana.localeCompare(b.kana, 'ja');
    });

    const results = $('#search-results');
    results.innerHTML = `<div class="result-count">${list.length} 件</div>` +
      (list.length ? list.map(shopRowHTML).join('') : `<div class="empty"><span class="emoji">🔍</span>見つかりませんでした</div>`);
    $$('#search-results .shop-row').forEach(el => {
      el.onclick = () => openShop(el.dataset.id);
    });
  };

  function shopRowHTML(s) {
    const g = genre(s.genre);
    const photo = Store.latestPhoto(s.id);
    const thumb = photo ? `<img src="${photo}" alt="">` : g.emoji;
    const rank = Store.prefRank(s);
    return `<a class="shop-row" data-id="${s.id}">
      <div class="shop-row-thumb" style="background:${g.color}">${thumb}</div>
      <div class="shop-row-main">
        <div class="shop-row-head">
          <span class="mini-genre" style="background:${g.color}22;color:${g.color}">${esc(g.name)}</span>
          ${rank <= 3 ? rankBadgeHTML(rank) : ''}
          ${Store.isWanted(s.id) ? '<span class="want-mark">🔖</span>' : ''}
        </div>
        <div class="shop-row-name">${esc(s.name)}</div>
        <div style="font-size:11px;color:var(--sub)">${esc(s.pref)} ${esc(s.area)} ・ ${esc(s.station)}</div>
        ${statsRowHTML(s)}
      </div>
    </a>`;
  }

  // ---------- Ranking ----------
  const RankState = { genre: '' };
  views.ranking = () => {
    const tabs = $('#ranking-tabs');
    tabs.innerHTML = [
      `<button class="tab${RankState.genre === '' ? ' active' : ''}" data-g="">総合</button>`,
      ...GENRES.map(g => `<button class="tab${RankState.genre === g.key ? ' active' : ''}" data-g="${g.key}">${g.emoji} ${esc(g.name)}</button>`),
    ].join('');
    $$('#ranking-tabs .tab').forEach(el => {
      el.onclick = () => { RankState.genre = el.dataset.g; views.ranking(); };
    });

    let list = SHOPS.slice();
    if (RankState.genre) list = list.filter(s => s.genre === RankState.genre);
    list.sort((a, b) => {
      const d = Store.shopRating(b.id) - Store.shopRating(a.id);
      return d !== 0 ? d : Store.shopReviewCount(b.id) - Store.shopReviewCount(a.id);
    });

    const ol = $('#ranking-list');
    ol.innerHTML = list.map((s, i) => {
      const g = genre(s.genre);
      const photo = Store.latestPhoto(s.id);
      const thumb = photo ? `<img src="${photo}" alt="">` : g.emoji;
      return `<li class="ranking-item" data-id="${s.id}">
        <div class="rank-no">${i + 1}</div>
        <div class="rank-thumb" style="background:${g.color}22">${thumb}</div>
        <div class="rank-main">
          <div class="rank-name">${esc(s.name)}</div>
          <div class="rank-meta">${g.emoji} ${esc(g.name)} ・ ${esc(s.pref)} ${esc(s.area)}</div>
          ${statsRowHTML(s)}
        </div>
      </li>`;
    }).join('');
    $$('#ranking-list .ranking-item').forEach(el => {
      el.onclick = () => openShop(el.dataset.id);
    });
  };

  // ---------- MyPage ----------
  const MyState = { tab: 'reviews' };
  views.mypage = () => {
    $('#profile-name').textContent = Store.data.profile.name || 'ラーメン好き';
    const my = Store.data.reviews;
    $('#my-reviews').textContent = my.length;
    $('#my-wants').textContent = Store.data.wants.length;
    const avg = my.length ? (my.reduce((s, r) => s + r.rating, 0) / my.length).toFixed(1) : '-';
    $('#my-avg').textContent = avg;

    $$('#mypage-tabs .tab').forEach(el => {
      el.classList.toggle('active', el.dataset.my === MyState.tab);
      el.onclick = () => { MyState.tab = el.dataset.my; views.mypage(); };
    });

    const host = $('#my-content');
    if (MyState.tab === 'reviews') {
      if (!my.length) {
        host.innerHTML = `<div class="empty"><span class="emoji">📝</span>まだラー活の記録がありません</div>`;
      } else {
        host.innerHTML = my.map(r => {
          const s = SHOPS.find(x => x.id === r.shopId);
          if (!s) return '';
          const g = genre(s.genre);
          const photos = (r.photos || []).map((p, i) => `<img src="${p}" data-rid="${r.id}" data-i="${i}" alt="">`).join('');
          return `<div class="my-review" data-id="${s.id}">
            <div class="my-review-head">
              <span class="my-review-shop">${g.emoji} ${esc(s.name)}</span>
              <span class="act-date">${fmtDate(r.visitedAt)}</span>
            </div>
            <div class="my-review-menu">${esc(r.menu)}</div>
            <div class="shop-row-rating"><span class="stars">${stars(r.rating)}</span><span>${r.rating.toFixed ? r.rating.toFixed(1) : r.rating}</span></div>
            ${r.comment ? `<div class="my-review-comment">${esc(r.comment)}</div>` : ''}
            ${photos ? `<div class="my-review-photos">${photos}</div>` : ''}
            <div style="margin-top:8px;text-align:right">
              <button class="link-btn" data-del="${r.id}" style="color:#999">削除</button>
            </div>
          </div>`;
        }).join('');
        $$('#my-content .my-review').forEach(el => {
          el.onclick = (ev) => {
            if (ev.target.closest('[data-del]')) return;
            if (ev.target.tagName === 'IMG') return;
            openShop(el.dataset.id);
          };
        });
        $$('#my-content [data-del]').forEach(b => {
          b.onclick = (ev) => {
            ev.stopPropagation();
            if (confirm('このラー活を削除しますか？')) {
              Store.removeReview(b.dataset.del);
              views.mypage();
            }
          };
        });
        $$('#my-content .my-review-photos img').forEach(img => {
          img.onclick = (ev) => {
            ev.stopPropagation();
            const r = my.find(x => x.id === img.dataset.rid);
            if (r) openViewer(r.photos, Number(img.dataset.i));
          };
        });
      }
    } else if (MyState.tab === 'wants') {
      const wanted = SHOPS.filter(s => Store.isWanted(s.id));
      if (!wanted.length) {
        host.innerHTML = `<div class="empty"><span class="emoji">🔖</span>行きたいリストが空です</div>`;
      } else {
        host.innerHTML = wanted.map(shopRowHTML).join('');
        $$('#my-content .shop-row').forEach(el => {
          el.onclick = () => openShop(el.dataset.id);
        });
      }
    } else {
      host.innerHTML = `<div class="settings-form">
        <label><span>ユーザー名</span><input type="text" id="set-name" value="${esc(Store.data.profile.name)}"></label>
        <label><span>好きなジャンル・メモ</span><input type="text" id="set-note" value="${esc(Store.data.profile.note || '')}"></label>
        <button class="btn primary" id="set-save">保存する</button>
        <button class="btn outline" id="set-reset">すべてのデータをリセット</button>
        <p style="font-size:11px;color:var(--sub);margin:0;text-align:center">本アプリはデモ版です。掲載されている店舗情報はサンプルデータです。</p>
      </div>`;
      $('#set-save').onclick = () => {
        Store.data.profile.name = $('#set-name').value.trim() || 'ラーメン好き';
        Store.data.profile.note = $('#set-note').value.trim();
        Store.save();
        alert('保存しました');
        views.mypage();
      };
      $('#set-reset').onclick = () => {
        if (confirm('すべてのデータをリセットしますか？')) {
          Store.resetAll();
          views.mypage();
        }
      };
    }
  };

  // ---------- Feed (ラー活タブ) ----------
  const FeedState = { tab: 'all' };
  views.feed = () => {
    $$('.feed-tabs .tab').forEach(t => {
      t.classList.toggle('active', t.dataset.feed === FeedState.tab);
      t.onclick = () => { FeedState.tab = t.dataset.feed; views.feed(); };
    });
    const all = Store.data.reviews.slice().sort((a, b) => new Date(b.visitedAt) - new Date(a.visitedAt));
    const list = FeedState.tab === 'mine' ? all : all;
    const host = $('#feed-list');
    if (!list.length) {
      host.innerHTML = `<div class="empty" style="margin-top:20px"><span class="emoji">🍜</span>まだラー活がありません</div>`;
      return;
    }
    host.innerHTML = list.map(r => feedItemHTML(r)).join('');
    $$('#feed-list .feed-shop-link').forEach(el => {
      el.onclick = ev => { ev.preventDefault(); openShop(el.dataset.id); };
    });
    $$('#feed-list .feed-photos img').forEach(img => {
      img.onclick = () => {
        const r = list.find(x => x.id === img.dataset.rid);
        if (r) openViewer(r.photos, Number(img.dataset.i));
      };
    });
  };

  function feedItemHTML(r) {
    const s = SHOPS.find(x => x.id === r.shopId);
    if (!s) return '';
    const g = genre(s.genre);
    const user = Store.data.profile.name || 'ラーメン好き';
    const init = user.charAt(0);
    const photos = (r.photos || []).map((p, i) => `<img src="${p}" data-rid="${r.id}" data-i="${i}" alt="">`).join('');
    return `<div class="feed-item">
      <div class="feed-item-head">
        <div class="feed-avatar" style="background:${g.color}">${init}</div>
        <div class="feed-user">
          <div class="uname">${esc(user)}</div>
          <div class="udate">${relDate(r.visitedAt)}</div>
        </div>
      </div>
      <a class="feed-shop-link" data-id="${s.id}">
        <div class="feed-shop-emoji" style="background:${g.color}">${g.emoji}</div>
        <div class="feed-shop-main">
          <div class="feed-shop-name">${esc(s.name)}</div>
          <div class="feed-shop-meta">${esc(s.pref)} ${esc(s.area)}</div>
        </div>
        <span style="color:var(--sub);font-size:14px">›</span>
      </a>
      <div class="feed-menu">${esc(r.menu)}</div>
      <div class="feed-rating-row">
        <span class="big">${Number(r.rating).toFixed(1)}</span>
        <span class="stars" style="font-size:14px">${stars(r.rating)}</span>
      </div>
      ${r.comment ? `<div class="feed-comment">${esc(r.comment)}</div>` : ''}
      ${photos ? `<div class="feed-photos">${photos}</div>` : ''}
      <div class="feed-scores">
        <span class="feed-score">スープ <span class="n">${r.soup}</span></span>
        <span class="feed-score">麺 <span class="n">${r.noodle}</span></span>
        <span class="feed-score">具 <span class="n">${r.topping}</span></span>
      </div>
    </div>`;
  }

  // ---------- Notify ----------
  views.notify = () => {
    $('#notify-dot').hidden = true;
    localStorage.setItem('ramen_notify_read', '1');
    const items = [
      { ico: '🎉', title: 'ラーメンイキタイへようこそ！', text: '全国のラーメン店を検索・記録できるアプリです。まずはジャンルから探してみよう。', time: '今日', unread: true },
      { ico: '🏆', title: '今週の注目ランキング', text: `${SHOPS.length}店舗からあなたの次の一杯を見つけよう。`, time: '今日', unread: true },
      { ico: '🔖', title: '行きたいリストを活用しよう', text: '気になる店をブックマークして、食べたい一杯を逃さない。', time: '昨日' },
      { ico: '📝', title: 'ラー活で記録を残そう', text: 'スープ・麺・具を5段階で評価。写真も最大4枚まで添付できます。', time: '3日前' },
    ];
    $('#notify-list').innerHTML = items.map(n => `<div class="notify-item${n.unread ? ' unread' : ''}">
      <div class="notify-ico">${n.ico}</div>
      <div class="notify-body">
        <div class="notify-title">${esc(n.title)}</div>
        <div class="notify-text">${esc(n.text)}</div>
        <div class="notify-time">${esc(n.time)}</div>
      </div>
    </div>`).join('');
  };

  // ---------- Map ----------
  let mapInstance = null;
  views.map = () => {
    setTimeout(() => initMap(), 50);
  };
  function initMap() {
    if (typeof L === 'undefined') {
      $('#leaflet-map').innerHTML = '<div class="empty"><span class="emoji">🗺</span>地図ライブラリの読み込みに失敗しました</div>';
      return;
    }
    if (!mapInstance) {
      mapInstance = L.map('leaflet-map', { zoomControl: true }).setView([36.5, 138.0], 5);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap',
        maxZoom: 19,
      }).addTo(mapInstance);
      SHOPS.forEach(s => {
        const g = genre(s.genre);
        const icon = L.divIcon({
          className: '',
          html: `<div class="map-pin" style="background:${g.color}">${g.emoji}</div>`,
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });
        const marker = L.marker([s.lat, s.lon], { icon }).addTo(mapInstance);
        marker.on('click', () => showMapShopInfo(s));
      });
    }
    setTimeout(() => mapInstance.invalidateSize(), 120);
  }
  function showMapShopInfo(s) {
    const g = genre(s.genre);
    const rating = Store.shopRating(s.id);
    const panel = $('#map-shop-info');
    panel.hidden = false;
    panel.innerHTML = `<div class="map-shop-info-head">
      <div class="feed-shop-emoji" style="background:${g.color}">${g.emoji}</div>
      <div class="feed-shop-main">
        <div class="feed-shop-name">${esc(s.name)}</div>
        <div class="feed-shop-meta">${esc(s.area)} ・ ⭐${rating > 0 ? rating.toFixed(1) : '-'} ・ 🔖${Store.shopWantCount(s.id)}</div>
      </div>
      <span style="color:var(--sub);font-size:18px">›</span>
    </div>`;
    panel.onclick = () => openShop(s.id);
  }

  // ---------- Post picker (投稿タブ) ----------
  function openPicker() {
    $('#picker-modal').hidden = false;
    $('#picker-input').value = '';
    renderPicker('');
    $('#picker-input').oninput = () => renderPicker($('#picker-input').value);
    $$('#picker-modal [data-close]').forEach(el => {
      el.onclick = () => { $('#picker-modal').hidden = true; };
    });
  }
  function renderPicker(q) {
    q = (q || '').toLowerCase();
    const list = SHOPS.filter(s =>
      !q ||
      s.name.toLowerCase().includes(q) ||
      (s.kana || '').toLowerCase().includes(q) ||
      s.area.toLowerCase().includes(q) ||
      s.pref.toLowerCase().includes(q)
    );
    $('#picker-list').innerHTML = list.map(s => {
      const g = genre(s.genre);
      return `<div class="picker-item" data-id="${s.id}">
        <div class="picker-thumb" style="background:${g.color}">${g.emoji}</div>
        <div class="picker-main">
          <div class="picker-name">${esc(s.name)}</div>
          <div class="picker-meta">${esc(g.name)} ・ ${esc(s.pref)} ${esc(s.area)}</div>
        </div>
      </div>`;
    }).join('') || `<div class="empty" style="padding:20px"><span class="emoji">🔍</span>見つかりませんでした</div>`;
    $$('#picker-list .picker-item').forEach(el => {
      el.onclick = () => {
        const s = SHOPS.find(x => x.id === el.dataset.id);
        $('#picker-modal').hidden = true;
        openReviewModal(s);
      };
    });
  }

  // ---------- Shop detail ----------
  let currentShopId = null;
  function openShop(id) {
    currentShopId = id;
    showView('shop');
    renderShopDetail();
  }

  function renderShopDetail() {
    const s = SHOPS.find(x => x.id === currentShopId);
    if (!s) return;
    const g = genre(s.genre);
    const rating = Store.shopRating(s.id);
    const photo = Store.latestPhoto(s.id);
    const heroStyle = photo
      ? `background-image:url('${photo}');background-size:cover;background-position:center`
      : `background:${g.color}`;
    const wanted = Store.isWanted(s.id);
    const reviews = Store.reviewsByShop(s.id);
    const mapsUrl = `https://maps.apple.com/?q=${encodeURIComponent(s.name)}&ll=${s.lat},${s.lon}`;
    const osmSrc = `https://www.openstreetmap.org/export/embed.html?bbox=${s.lon - 0.005},${s.lat - 0.003},${s.lon + 0.005},${s.lat + 0.003}&layer=mapnik&marker=${s.lat},${s.lon}`;

    const rank = Store.prefRank(s);
    $('#shop-detail').innerHTML = `
      <div class="detail-head" style="${heroStyle}">
        <button class="detail-back" data-back aria-label="戻る">←</button>
        <span class="detail-genre">${g.emoji} ${esc(g.name)}</span>
        ${rank <= 3 ? `<div style="margin-top:6px">${rankBadgeHTML(rank)} <span style="font-size:11px;opacity:.9">${esc(s.pref)}</span></div>` : ''}
        <h1 class="detail-name">${esc(s.name)}</h1>
        <div class="detail-kana">${esc(s.kana)}</div>
        <div class="detail-area">${esc(s.pref)} ${esc(s.area)}</div>
        <div class="detail-rating">
          <span class="big">${rating > 0 ? rating.toFixed(1) : '-'}</span>
          <span class="stars" style="font-size:16px">${stars(rating)}</span>
        </div>
      </div>

      <div class="detail-stats-banner">
        <div class="ds-item rating">
          <strong>${rating > 0 ? rating.toFixed(1) : '-'}</strong>
          <span><span class="ico">⭐</span>評価</span>
        </div>
        <div class="ds-divider"></div>
        <div class="ds-item">
          <strong>${reviews.length}</strong>
          <span><span class="ico">📝</span>ラー活</span>
        </div>
        <div class="ds-divider"></div>
        <div class="ds-item">
          <strong>${Store.shopWantCount(s.id)}</strong>
          <span><span class="ico">🔖</span>行きたい</span>
        </div>
      </div>

      <div class="detail-actions">
        <button class="btn want-big${wanted ? ' active' : ''}" id="btn-want">
          <span class="ico">${wanted ? '✓' : '🔖'}</span>${wanted ? '行きたい登録中' : '行きたい'}
        </button>
        <button class="btn primary" id="btn-review">＋ ラー活を記録</button>
      </div>

      <div class="detail-section">
        <h3>基本情報</h3>
        <div class="info-line"><div class="k">住所</div><div class="v">${esc(s.address)}</div></div>
        <div class="info-line"><div class="k">アクセス</div><div class="v">${esc(s.station)}</div></div>
        <div class="info-line"><div class="k">営業時間</div><div class="v">${esc(s.hours)}</div></div>
        <div class="info-line"><div class="k">定休日</div><div class="v">${esc(s.closed)}</div></div>
        <div class="info-line"><div class="k">価格帯</div><div class="v">${esc(s.price)}</div></div>
        <div class="info-line"><div class="k">駐車場</div><div class="v">${s.parking ? 'あり' : 'なし'}</div></div>
        <div class="info-line"><div class="k">予約</div><div class="v">${s.reservation ? '可' : '不可'}</div></div>
        <div class="info-line"><div class="k">替え玉</div><div class="v">${s.kaedama ? 'あり' : 'なし'}</div></div>
      </div>

      <div class="detail-section">
        <h3>スペック</h3>
        <div class="spec-grid">
          <div class="spec-card"><div class="spec-label">麺</div><div class="spec-value">${esc(s.noodle)}</div></div>
          <div class="spec-card"><div class="spec-label">スープ</div><div class="spec-value">${esc(s.soup)}</div></div>
        </div>
        <p style="font-size:12.5px;color:var(--sub);margin:12px 0 0;line-height:1.7">${esc(s.desc)}</p>
      </div>

      <div class="detail-section">
        <h3>メニュー</h3>
        ${s.menus.map(m => `<div class="menu-row">
          <span>${m.sig ? '<span class="sig">看板</span>' : ''}${esc(m.name)}</span>
          <span class="price">¥${m.price.toLocaleString()}</span>
        </div>`).join('')}
      </div>

      <div class="detail-section">
        <h3>地図</h3>
        <iframe class="map-embed" loading="lazy" src="${osmSrc}" title="地図"></iframe>
        <a class="btn primary" href="${mapsUrl}" target="_blank" rel="noopener" style="display:block;text-align:center;text-decoration:none;margin-top:10px">Apple マップで開く</a>
      </div>

      <div class="detail-section">
        <h3>ラー活 <span class="cnt">${reviews.length}件</span></h3>
        ${reviews.length
          ? reviews.map(r => timelineReviewHTML(r)).join('')
          : `<div class="empty" style="padding:20px"><span class="emoji">📝</span>まだラー活がありません。最初の一杯を記録しよう！</div>`
        }
      </div>
    `;
    $('[data-back]').onclick = () => showView('home');
    $('#btn-review').onclick = () => openReviewModal(s);
    $('#btn-want').onclick = () => { Store.toggleWant(s.id); renderShopDetail(); };
    $$('#shop-detail .tl-photos img').forEach(img => {
      img.onclick = () => {
        const r = reviews.find(x => x.id === img.dataset.rid);
        if (r) openViewer(r.photos, Number(img.dataset.i));
      };
    });
  }

  function timelineReviewHTML(r) {
    const photos = (r.photos || []).map((p, i) => `<img src="${p}" data-rid="${r.id}" data-i="${i}" alt="">`).join('');
    const userName = Store.data.profile.name || 'ラーメン好き';
    const initial = userName.charAt(0);
    return `<div class="timeline-review">
      <div class="tl-avatar" style="background:${genre('shoyu').color}">${initial}</div>
      <div class="tl-body">
        <div class="tl-head">
          <span class="tl-user">${esc(userName)}</span>
          <span class="tl-date">${relDate(r.visitedAt)}</span>
        </div>
        <div class="tl-menu">${esc(r.menu)}</div>
        <div class="tl-rating-row">
          <span class="big">${Number(r.rating).toFixed(1)}</span>
          <span class="stars" style="font-size:14px">${stars(r.rating)}</span>
        </div>
        ${r.comment ? `<div class="tl-comment">${esc(r.comment)}</div>` : ''}
        ${photos ? `<div class="tl-photos">${photos}</div>` : ''}
        <div class="tl-scores">
          <span class="tl-score">スープ <span class="n">${r.soup}</span></span>
          <span class="tl-score">麺 <span class="n">${r.noodle}</span></span>
          <span class="tl-score">具 <span class="n">${r.topping}</span></span>
        </div>
      </div>
    </div>`;
  }

  // ---------- Review modal ----------
  let reviewShop = null;
  let reviewPhotos = [];

  function openReviewModal(shop) {
    reviewShop = shop;
    reviewPhotos = [];
    const modal = $('#review-modal');
    modal.hidden = false;
    $('#review-shop-label').innerHTML = `<strong>${esc(shop.name)}</strong><br><small style="color:var(--sub)">${esc(shop.pref)} ${esc(shop.area)}</small>`;
    const form = $('#review-form');
    form.reset();
    form.visitedAt.value = new Date().toISOString().slice(0, 10);
    form.rating.value = '4';
    updateStarPicker(4);
    renderPhotoRow();
  }

  function closeReviewModal() { $('#review-modal').hidden = true; }

  function updateStarPicker(v) {
    $$('#star-picker button').forEach(b => {
      b.classList.toggle('active', Number(b.dataset.rate) <= v);
    });
  }

  function renderPhotoRow() {
    const row = $('#photo-row');
    $$('#photo-row .thumb').forEach(t => t.remove());
    const addLbl = row.querySelector('.photo-add');
    reviewPhotos.forEach((p, i) => {
      const div = document.createElement('div');
      div.className = 'thumb';
      div.innerHTML = `<img src="${p}" alt=""><button type="button" class="x" data-rm="${i}">×</button>`;
      row.insertBefore(div, addLbl);
    });
    $$('#photo-row [data-rm]').forEach(b => {
      b.onclick = () => { reviewPhotos.splice(Number(b.dataset.rm), 1); renderPhotoRow(); };
    });
    addLbl.style.display = reviewPhotos.length >= 4 ? 'none' : '';
  }

  async function compressImage(file, max = 1024, quality = 0.8) {
    const bmpSrc = await new Promise((res, rej) => {
      const fr = new FileReader();
      fr.onload = () => res(fr.result);
      fr.onerror = rej;
      fr.readAsDataURL(file);
    });
    const img = await new Promise((res, rej) => {
      const im = new Image();
      im.onload = () => res(im);
      im.onerror = rej;
      im.src = bmpSrc;
    });
    let { width, height } = img;
    if (width > max || height > max) {
      if (width > height) { height = Math.round(height * max / width); width = max; }
      else { width = Math.round(width * max / height); height = max; }
    }
    const canvas = document.createElement('canvas');
    canvas.width = width; canvas.height = height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0, width, height);
    return canvas.toDataURL('image/jpeg', quality);
  }

  // ---------- Photo viewer ----------
  let viewerPhotos = [];
  let viewerIdx = 0;
  function openViewer(photos, idx) {
    if (!photos || !photos.length) return;
    viewerPhotos = photos; viewerIdx = idx || 0;
    $('#photo-viewer').hidden = false;
    renderViewer();
  }
  function renderViewer() {
    $('#viewer-image').src = viewerPhotos[viewerIdx];
    $('#viewer-pager').innerHTML = viewerPhotos.map((_, i) => `<span class="dot${i === viewerIdx ? ' on' : ''}"></span>`).join('');
  }
  function closeViewer() { $('#photo-viewer').hidden = true; }

  // swipe
  let touchStart = null;
  $('#photo-viewer').addEventListener('touchstart', e => {
    touchStart = e.touches[0].clientX;
  });
  $('#photo-viewer').addEventListener('touchend', e => {
    if (touchStart == null) return;
    const dx = e.changedTouches[0].clientX - touchStart;
    if (Math.abs(dx) > 50) {
      if (dx < 0 && viewerIdx < viewerPhotos.length - 1) viewerIdx++;
      else if (dx > 0 && viewerIdx > 0) viewerIdx--;
      renderViewer();
    }
    touchStart = null;
  });

  // ---------- Event wiring ----------
  function wire() {
    $$('.tab-item').forEach(btn => {
      if (btn.dataset.post !== undefined) {
        btn.onclick = () => openPicker();
      } else {
        btn.onclick = () => showView(btn.dataset.go);
      }
    });
    $$('[data-go]').forEach(b => {
      if (!b.classList.contains('tab-item')) {
        b.addEventListener('click', () => showView(b.dataset.go));
      }
    });

    // Notify dot: 初回訪問まで表示
    if (!localStorage.getItem('ramen_notify_read')) {
      $('#notify-dot').hidden = false;
    }

    // Modal close
    $$('#review-modal [data-close]').forEach(el => {
      el.onclick = closeReviewModal;
    });
    // Star picker
    $$('#star-picker button').forEach(b => {
      b.onclick = () => {
        const v = Number(b.dataset.rate);
        $('#review-form').rating.value = v;
        updateStarPicker(v);
      };
    });
    // Photo input
    $('#photo-input').addEventListener('change', async ev => {
      const files = Array.from(ev.target.files || []);
      for (const f of files) {
        if (reviewPhotos.length >= 4) break;
        try {
          const dataUrl = await compressImage(f);
          reviewPhotos.push(dataUrl);
        } catch (e) { console.warn('compress failed', e); }
      }
      ev.target.value = '';
      renderPhotoRow();
    });
    // Review submit
    $('#review-form').addEventListener('submit', ev => {
      ev.preventDefault();
      if (!reviewShop) return;
      const fd = new FormData(ev.target);
      const review = {
        id: 'r_' + Date.now() + '_' + Math.random().toString(36).slice(2, 7),
        shopId: reviewShop.id,
        visitedAt: new Date(fd.get('visitedAt')).toISOString(),
        menu: String(fd.get('menu') || '').trim(),
        rating: Number(fd.get('rating') || 4),
        soup: Number(fd.get('soup') || 3),
        noodle: Number(fd.get('noodle') || 3),
        topping: Number(fd.get('topping') || 3),
        comment: String(fd.get('comment') || '').trim(),
        photos: reviewPhotos.slice(),
        createdAt: new Date().toISOString(),
      };
      Store.addReview(review);
      closeReviewModal();
      if (currentShopId === reviewShop.id) renderShopDetail();
      else showView('home');
    });

    // Viewer close
    $('#photo-viewer [data-close]').onclick = closeViewer;
    $('#photo-viewer').addEventListener('click', ev => {
      if (ev.target.id === 'photo-viewer') closeViewer();
    });
  }

  // ---------- Init ----------
  Store.load();
  wire();
  showView('home');
})();
