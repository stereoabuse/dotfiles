#!/usr/bin/env node
let raw = '';
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  let d = {};
  try { d = JSON.parse(raw); } catch { process.stdout.write('Claude Code'); return; }

  const parts = [];
  const model = d?.model?.display_name;
  if (model) parts.push(model);

  const used = d?.context_window?.used_percentage;
  if (used != null) {
    const filled = Math.round(used / 10);
    const empty = 10 - filled;
    const bar = '#'.repeat(filled) + '-'.repeat(empty);
    parts.push(`ctx [${bar}]`);
  }

  const fmtTime12 = ts => {
    if (!ts) return '';
    const n = typeof ts === 'number' ? ts * 1000 : Date.parse(ts);
    if (!Number.isFinite(n)) return '';
    const dt = new Date(n);
    return dt.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', hour12: true });
  };
  const fmtWeekday = ts => {
    if (!ts) return '';
    const n = typeof ts === 'number' ? ts * 1000 : Date.parse(ts);
    if (!Number.isFinite(n)) return '';
    const dt = new Date(n);
    return dt.toLocaleDateString([], { weekday: 'long' });
  };

  const five = d?.rate_limits?.five_hour;
  if (five?.used_percentage != null) {
    const t = fmtTime12(five.resets_at);
    parts.push(`5h: ${Math.round(five.used_percentage)}%${t ? ` (resets ${t})` : ''}`);
  }

  const week = d?.rate_limits?.seven_day;
  if (week?.used_percentage != null) {
    const t = fmtWeekday(week.resets_at);
    parts.push(`7d: ${Math.round(week.used_percentage)}%${t ? ` resets ${t}` : ''}`);
  }

  process.stdout.write(parts.join(' | '));
});
