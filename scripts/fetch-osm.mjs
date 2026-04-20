#!/usr/bin/env node
// 全国の OSM ラーメン店データを取得して docs/osm-data.json に書き出す
// GitHub Actions から実行する想定（手元では `node scripts/fetch-osm.mjs`）
import fs from 'node:fs/promises';
import path from 'node:path';

const ENDPOINTS = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
];

const QUERY = `[out:json][timeout:180];
(
  nwr["cuisine"~"ramen",i](24.0,122.0,46.0,154.0);
  nwr["cuisine"="noodle"]["name"~"ラーメン|らーめん|ラー麺|麺"](24.0,122.0,46.0,154.0);
);
out center tags;`;

function inferGenre(tags) {
  const text = [tags.name, tags['name:ja'], tags.description, tags.cuisine].filter(Boolean).join(' ');
  if (/味噌|みそ|ミソ/.test(text)) return 'miso';
  if (/家系/.test(text)) return 'iekei';
  if (/二郎|ジロー/.test(text)) return 'jiro';
  if (/つけ麺|つけめん|ツケメン/.test(text)) return 'tsukemen';
  if (/担々|担担|タンタン|坦々/.test(text)) return 'tantanmen';
  if (/煮干|にぼし|ニボシ/.test(text)) return 'niboshi';
  if (/油そば|まぜそば|汁なし/.test(text)) return 'abura';
  if (/豚骨|とんこつ|トンコツ|博多/.test(text)) return 'tonkotsu';
  if (/塩|しお|シオ/.test(text)) return 'shio';
  return 'shoyu';
}

function buildAddress(tags) {
  const parts = [];
  if (tags['addr:state']) parts.push(tags['addr:state']);
  if (tags['addr:province']) parts.push(tags['addr:province']);
  if (tags['addr:city']) parts.push(tags['addr:city']);
  if (tags['addr:suburb']) parts.push(tags['addr:suburb']);
  if (tags['addr:quarter']) parts.push(tags['addr:quarter']);
  if (tags['addr:neighbourhood']) parts.push(tags['addr:neighbourhood']);
  if (tags['addr:block_number']) parts.push(tags['addr:block_number']);
  if (tags['addr:housenumber']) parts.push(tags['addr:housenumber']);
  return parts.join('') || '';
}

function elementsToShops(elements) {
  const shops = [];
  for (const el of elements) {
    const tags = el.tags || {};
    const name = tags['name:ja'] || tags.name;
    if (!name) continue;
    const lat = el.lat ?? el.center?.lat;
    const lon = el.lon ?? el.center?.lon;
    if (lat == null || lon == null) continue;
    shops.push({
      id: `osm_${el.type}_${el.id}`,
      name,
      genre: inferGenre(tags),
      lat: Number(lat.toFixed(6)),
      lon: Number(lon.toFixed(6)),
      address: buildAddress(tags),
      hours: tags.opening_hours || '',
      website: tags.website || tags['contact:website'] || '',
      phone: tags.phone || tags['contact:phone'] || '',
    });
  }
  return shops;
}

async function fetchOverpass() {
  let lastErr = null;
  for (const url of ENDPOINTS) {
    try {
      console.log(`[fetch] ${url}`);
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'data=' + encodeURIComponent(QUERY),
      });
      if (!res.ok) {
        lastErr = new Error(`HTTP ${res.status}`);
        console.warn(`[warn] ${url}: ${res.status}`);
        continue;
      }
      const data = await res.json();
      if (data.elements) return data.elements;
    } catch (e) {
      lastErr = e;
      console.warn(`[warn] ${url}: ${e.message}`);
    }
  }
  throw lastErr || new Error('All endpoints failed');
}

async function main() {
  const elements = await fetchOverpass();
  console.log(`[ok] elements: ${elements.length}`);
  const shops = elementsToShops(elements);
  console.log(`[ok] shops: ${shops.length}`);
  // 重複除去（同一座標）
  const seen = new Set();
  const unique = shops.filter(s => {
    const k = `${s.lat.toFixed(4)},${s.lon.toFixed(4)},${s.name}`;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
  console.log(`[ok] unique: ${unique.length}`);
  const out = {
    generated_at: new Date().toISOString(),
    source: 'OpenStreetMap (Overpass API)',
    license: 'ODbL 1.0',
    count: unique.length,
    shops: unique,
  };
  const outPath = path.join(process.cwd(), 'docs', 'osm-data.json');
  await fs.writeFile(outPath, JSON.stringify(out));
  console.log(`[ok] wrote ${outPath} (${(JSON.stringify(out).length / 1024).toFixed(1)} KB)`);
}

main().catch(err => {
  console.error('[fatal]', err);
  process.exit(1);
});
