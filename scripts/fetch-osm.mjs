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

// 日本全土のラーメン関連店舗を可能な限り網羅的に取得
// - cuisine=ramen / noodle / japanese
// - 店名に ラーメン/らーめん/中華そば/つけ麺/担々麺/家系/二郎/油そば/まぜそば 等を含む店
// - 全国チェーン（一蘭/一風堂/天下一品/幸楽苑/日高屋/8番らーめん 等）
const NAME_PATTERN = 'ラーメン|らーめん|らあめん|らー麺|ラー麺|中華そば|中華蕎麦|支那そば|つけ麺|つけめん|油そば|まぜそば|担々麺|担担麺|タンタン麺|家系|二郎|博多|一蘭|一風堂|天下一品|幸楽苑|日高屋|8番らーめん|来来亭|スガキヤ|くるまや|花月嵐|横綱|町田商店|魁力屋|蒙古タンメン|よってこや|くじら軒';

// Overpass 公共インスタンスは重いクエリでタイムアウトしやすいので
// cuisine タグに絞って取得（これでもラーメン店の大半がヒット）
const QUERY = `[out:json][timeout:180];
area["ISO3166-1"="JP"]->.jp;
(
  nwr(area.jp)["cuisine"~"ramen",i];
  nwr(area.jp)["cuisine"="noodle"]["name"~"${NAME_PATTERN}"];
);
out center tags;`;

function inferGenre(tags) {
  const text = [tags.name, tags['name:ja'], tags['brand'], tags.description, tags.cuisine].filter(Boolean).join(' ');
  // チェーンから推定
  if (/一蘭|一風堂|天下一品|博多|久留米|一幸舎|博多一双|長浜/.test(text)) return 'tonkotsu';
  if (/二郎|ジロー|ラーメン荘|ラーメン豚山/.test(text)) return 'jiro';
  if (/家系|町田商店|壱角家|武蔵家|魂心家|王道家|介一家/.test(text)) return 'iekei';
  if (/味噌|みそ|ミソ|蒙古タンメン|純連|すみれ/.test(text)) return 'miso';
  if (/つけ麺|つけめん|ツケメン|大勝軒/.test(text)) return 'tsukemen';
  if (/担々|担担|タンタン|坦々|175°DENO|175deno/i.test(text)) return 'tantanmen';
  if (/煮干|にぼし|ニボシ|凪|長尾中華|ラーメン凪/.test(text)) return 'niboshi';
  if (/油そば|まぜそば|汁なし|武蔵野|東京油組|歌志軒/.test(text)) return 'abura';
  if (/豚骨|とんこつ|トンコツ/.test(text)) return 'tonkotsu';
  if (/塩|しお|シオ|麺屋海神/.test(text)) return 'shio';
  return 'shoyu';
}

function buildAddress(tags) {
  const parts = [];
  const pref = tags['addr:state'] || tags['addr:province'] || '';
  if (pref) parts.push(pref);
  if (tags['addr:city']) parts.push(tags['addr:city']);
  if (tags['addr:suburb']) parts.push(tags['addr:suburb']);
  if (tags['addr:quarter']) parts.push(tags['addr:quarter']);
  if (tags['addr:neighbourhood']) parts.push(tags['addr:neighbourhood']);
  if (tags['addr:block_number']) parts.push(tags['addr:block_number']);
  if (tags['addr:housenumber']) parts.push(tags['addr:housenumber']);
  return parts.join('') || '';
}

// 緯度経度から大まかな都道府県を推定（addr:state が無い場合のフォールバック）
const PREF_BBOX = [
  ['北海道', 41.3, 45.6, 139.3, 145.9],
  ['青森県', 40.2, 41.5, 139.4, 141.7],
  ['岩手県', 38.8, 40.3, 140.6, 142.1],
  ['秋田県', 38.8, 40.5, 139.6, 141.0],
  ['宮城県', 37.7, 38.9, 140.2, 141.7],
  ['山形県', 37.7, 39.0, 139.4, 140.7],
  ['福島県', 36.8, 38.0, 139.1, 141.1],
  ['新潟県', 36.7, 38.6, 137.6, 139.9],
  ['富山県', 36.2, 36.9, 136.7, 137.8],
  ['石川県', 36.0, 37.6, 136.2, 137.4],
  ['福井県', 35.3, 36.4, 135.4, 136.8],
  ['長野県', 35.2, 37.0, 137.3, 138.8],
  ['岐阜県', 35.1, 36.5, 136.3, 137.7],
  ['群馬県', 35.9, 37.1, 138.4, 139.7],
  ['栃木県', 36.1, 37.2, 139.3, 140.3],
  ['茨城県', 35.7, 36.9, 139.7, 140.9],
  ['埼玉県', 35.7, 36.3, 138.7, 139.9],
  ['千葉県', 34.9, 36.1, 139.7, 141.0],
  ['東京都', 35.5, 35.9, 138.9, 139.9],
  ['神奈川県', 35.1, 35.7, 138.9, 139.8],
  ['山梨県', 35.1, 35.9, 138.2, 139.2],
  ['静岡県', 34.6, 35.7, 137.5, 139.2],
  ['愛知県', 34.5, 35.4, 136.6, 137.8],
  ['三重県', 33.7, 35.3, 135.8, 136.9],
  ['滋賀県', 34.7, 35.7, 135.7, 136.5],
  ['京都府', 34.7, 35.8, 134.9, 136.0],
  ['大阪府', 34.2, 35.0, 135.1, 135.7],
  ['兵庫県', 34.1, 35.7, 134.2, 135.5],
  ['奈良県', 33.8, 34.8, 135.5, 136.2],
  ['和歌山県', 33.4, 34.4, 135.0, 136.0],
  ['鳥取県', 35.1, 35.6, 133.1, 134.5],
  ['島根県', 34.3, 35.6, 131.6, 133.4],
  ['岡山県', 34.3, 35.4, 133.3, 134.4],
  ['広島県', 34.0, 35.1, 132.0, 133.5],
  ['山口県', 33.7, 34.8, 130.8, 132.4],
  ['徳島県', 33.5, 34.3, 133.6, 134.8],
  ['香川県', 34.0, 34.6, 133.4, 134.5],
  ['愛媛県', 32.9, 34.3, 132.0, 133.7],
  ['高知県', 32.7, 33.9, 132.5, 134.3],
  ['福岡県', 33.0, 34.0, 130.0, 131.2],
  ['佐賀県', 32.9, 33.6, 129.7, 130.6],
  ['長崎県', 32.6, 34.7, 128.6, 130.4],
  ['熊本県', 32.1, 33.3, 130.1, 131.3],
  ['大分県', 32.7, 33.7, 130.8, 132.1],
  ['宮崎県', 31.3, 32.9, 130.7, 131.9],
  ['鹿児島県', 30.3, 32.2, 129.5, 131.2],
  ['沖縄県', 24.0, 27.9, 122.9, 131.4],
];
function inferPref(lat, lon) {
  for (const [name, latMin, latMax, lonMin, lonMax] of PREF_BBOX) {
    if (lat >= latMin && lat <= latMax && lon >= lonMin && lon <= lonMax) return name;
  }
  return '';
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
    const pref = tags['addr:state'] || tags['addr:province'] || inferPref(lat, lon);
    shops.push({
      id: `osm_${el.type}_${el.id}`,
      name,
      genre: inferGenre(tags),
      lat: Number(lat.toFixed(6)),
      lon: Number(lon.toFixed(6)),
      pref,
      area: tags['addr:city'] || tags['addr:suburb'] || '',
      address: buildAddress(tags),
      hours: tags.opening_hours || '',
      website: tags.website || tags['contact:website'] || '',
      phone: tags.phone || tags['contact:phone'] || '',
      brand: tags.brand || '',
    });
  }
  return shops;
}

async function fetchOverpass() {
  let lastErr = null;
  for (const url of ENDPOINTS) {
    const startedAt = Date.now();
    try {
      console.log(`[fetch] ${url}`);
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'ra-men-app-refresh/1.0 (github.com/arizona1003/ra-men)',
        },
        body: 'data=' + encodeURIComponent(QUERY),
      });
      const elapsed = Date.now() - startedAt;
      console.log(`[fetch] ${url} → ${res.status} (${elapsed}ms)`);
      if (!res.ok) {
        const body = await res.text();
        console.warn(`[warn] body: ${body.slice(0, 500)}`);
        lastErr = new Error(`HTTP ${res.status}: ${body.slice(0, 200)}`);
        continue;
      }
      const data = await res.json();
      if (!data.elements) {
        console.warn(`[warn] no elements in response`);
        continue;
      }
      console.log(`[ok] ${data.elements.length} elements from ${url}`);
      return data.elements;
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
