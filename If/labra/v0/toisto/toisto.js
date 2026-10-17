const $ = id => document.getElementById(id);
const image = new Image();
const a = D.area;
const scale = 1000 / (a.xmax - a.xmin);
const px = x => (x - a.xmin) * scale;
const py = y => (a.ymax - y) * scale;
const counts = [0, 1, 2, 4, 8];
const colors = ['transparent', '#ffdc8c', '#ffa348', '#e6532e', '#9a1515'];
let timer = null;
let selected = null;
const totals = [[], []];
for (let s = 0; s < 2; s++) {
  let falls = 0, actions = 0, expected = 0;
  for (let t = 0; t < D.times.length; t++) {
    const row = D.summary[t * 2 + s];
    falls += row.falls; actions += row.maintenance_actions; expected += row.expected_falls;
    totals[s].push({falls, actions, expected});
  }
}
$('slider').max = D.times.length - 1;
$('policy').textContent = `Molemmissa ${D.params.huoltokohteita} huoltokohdetta ${D.params.huoltovali_h} tunnin välein. Kohde ${D.blockSize} × ${D.blockSize} m. Vihreä rajaus: voimassa oleva simuloitu hiekoitus; H: uusi huoltotoimi.`;
$('legend').textContent = `Ruutuväri: havaintoja viimeisten ${D.window} tunnin aikana. Väritön 0, keltainen 1, oranssi 2–3, punainen 4–7, tummanpunainen vähintään 8. Sama asteikko molemmissa.`;
$('mapdate').textContent = `Haettu ${D.mapDate}.`;
$('assumptions').textContent = `Ruutu ${D.cellSize} m. Sovellusotos ${D.params.sovelluksen_osuus * 100} %. Liukastumisen lähtötodennäköisyys ${D.params.liukastuminen_p}; kaatuminen liukastumisesta ${D.params.kaatuminen_liukastumisesta_p * 100} %. Hiekoitus pienentää liukastumisen todennäköisyyttä ${D.params.huollon_teho * 100} % ajaksi ${D.params.huollon_kesto_h} h. Siemen ${D.params.seed}.`;

function draw(s, t) {
  const ctx = $('map' + s).getContext('2d');
  ctx.clearRect(0, 0, 1000, 1000);
  ctx.drawImage(image, 0, 0, 1000, 1000);
  const frame = D.frames[t][s];
  const size = D.cellSize * scale;
  for (let i = 0; i < D.cells.length; i++) {
    const c = D.cells[i], value = frame.havainnot[i];
    const x = px(c.x) - size / 2, y = py(c.y) - size / 2;
    if (value > 0) {
      const level = counts.reduce((level, edge, j) => value >= edge ? j : level, 0);
      ctx.globalAlpha = .72;
      ctx.fillStyle = colors[level];
      ctx.fillRect(x, y, size, size);
      ctx.globalAlpha = 1;
    }
  }
  ctx.strokeStyle = 'rgba(50,50,50,.10)'; ctx.lineWidth = 1;
  for (let v = 0; v <= 1000; v += size) {
    ctx.beginPath(); ctx.moveTo(v, 0); ctx.lineTo(v, 1000); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(0, v); ctx.lineTo(1000, v); ctx.stroke();
  }
  for (const zone of D.zones) {
    if (!frame.huoltoalueet.includes(zone.zone_id)) continue;
    const x = px(zone.zone_xmin), y = py(zone.zone_ymin + D.blockSize);
    ctx.strokeStyle = '#087f5b'; ctx.lineWidth = 3;
    ctx.strokeRect(x + 1, y + 1, D.blockSize * scale - 2, D.blockSize * scale - 2);
    if (frame.uudet.includes(zone.zone_id)) {
      ctx.fillStyle = '#087f5b'; ctx.font = 'bold 24px system-ui';
      ctx.fillText('H', x + 7, y + 27);
    }
  }
  if (selected) {
    ctx.strokeStyle = '#102b48'; ctx.lineWidth = 4;
    ctx.strokeRect(px(selected.x) - size / 2, py(selected.y) - size / 2, size, size);
  }
  const q = totals[s][t];
  $('stats' + s).textContent = `Kaatumisia kertynyt ${q.falls} · huoltotoimia ${q.actions}`;
}
function render() {
  const t = Number($('slider').value);
  $('time').textContent = D.times[t] + ' (Suomen aika)';
  const w = D.weather[t];
  $('weather').textContent = `${w.temp_c.toFixed(1)} °C · ${w.filled ? 'sääarvo täytetty aiemmasta tunnista' : w.valid_10min < 6 ? 'tunnin säässä puuttuvia mittauksia' : 'mitattu tuntikeskiarvo'}`;
  draw(0, t); draw(1, t);
  const diff = totals[0][t].falls - totals[1][t].falls;
  const expected = totals[0][t].expected - totals[1][t].expected;
  $('difference').textContent = `Kohdistetussa vaihtoehdossa ${Math.abs(diff)} kaatumista ${diff >= 0 ? 'vähemmän' : 'enemmän'}. Simulaatiomallin odotusarvojen erotus: ${expected.toFixed(1)}. Tämä on yksi simulaatioajo.`;
  if (selected) {
    const i = D.cells.findIndex(c => c.cell_id === selected.cell_id);
    const v = s => i < 0 ? 0 : D.frames[t][s].havainnot[i];
    $('cell').textContent = `Ruutu ${selected.cell_id}, keskipiste (${selected.x}, ${selected.y}). Havaintoja ${D.window} h: aikataulu ${v(0)}, kohdistettu ${v(1)}.`;
  }
}
function pause() { clearInterval(timer); timer = null; $('play').textContent = 'Toista'; }
function play() {
  if (+$('slider').value === D.times.length - 1) $('slider').value = 0;
  timer = setInterval(() => {
    if (+$('slider').value === D.times.length - 1) return pause();
    $('slider').value = +$('slider').value + 1; render();
  }, +$('speed').value);
  $('play').textContent = 'Pysäytä';
}
$('play').onclick = () => timer ? pause() : play();
$('speed').onchange = () => { if (timer) { pause(); play(); } };
$('slider').oninput = () => { pause(); render(); };
for (let s = 0; s < 2; s++) $('map' + s).onclick = event => {
  const rect = event.currentTarget.getBoundingClientRect();
  const x = a.xmin + (event.clientX - rect.left) / rect.width * (a.xmax - a.xmin);
  const y = a.ymax - (event.clientY - rect.top) / rect.height * (a.ymax - a.ymin);
  if (x < a.xmin || x >= a.xmax || y < a.ymin || y >= a.ymax) return;
  const ix = Math.floor((x - a.xmin) / D.cellSize), iy = Math.floor((y - a.ymin) / D.cellSize);
  selected = {cell_id: iy * Math.round((a.xmax - a.xmin) / D.cellSize) + ix + 1,
              x: a.xmin + (ix + .5) * D.cellSize, y: a.ymin + (iy + .5) * D.cellSize};
  render();
};
image.onload = render;
image.src = 'data:image/png;base64,' + D.map;
