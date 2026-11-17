#!/usr/bin/env python3
"""Validate Crownfall example data and canonical Markdown references.

Uses only Python stdlib. This is *structural* validation, not gameplay validation.
"""
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'data'
ALLOWED_DIVISIONS = {'LIGHT', 'MIDDLE', 'HEAVY'}
ALLOWED_SLOTS = {'LANCE', 'SADDLE', 'PERK'}
EXPECTED_MODES = {'campaign', 'challenge', 'draft', 'endless', 'exhibition'}


def read_json(name):
    with open(DATA / name, encoding='utf-8') as f:
        return json.load(f)


def check(condition, message):
    if not condition:
        raise ValueError(message)


def validate():
    dinos = read_json('dinosaurs.example.json')['dinosaurs']
    arenas = read_json('arenas.example.json')['arenas']
    gear = read_json('equipment.example.json')['equipment']
    modes = read_json('modes.example.json')['modes']
    rules = read_json('duel_rules.example.json')
    example = read_json('sample_encounter.example.json')

    check(len(dinos) >= 2, 'Need at least 2 sample dinosaurs')
    d_ids = [d['id'] for d in dinos]
    a_ids = [a['id'] for a in arenas]
    g_ids = [g['id'] for g in gear]
    m_ids = [m['id'] for m in modes]
    for noun, ids in [('dinosaur', d_ids), ('arena', a_ids), ('gear', g_ids), ('mode', m_ids)]:
        check(len(ids) == len(set(ids)), f'Duplicate {noun} ids')
    for d in dinos:
        check(d['division'] in ALLOWED_DIVISIONS, f'Unknown division: {d["id"]}')
        for k in ['normalized_mass', 'saddle_height_index', 'max_speed_index', 'acceleration_index', 'grip_index', 'balance_index']:
            check(isinstance(d[k], (int, float)) and d[k] > 0, f'Bad stat {d["id"]}.{k}')
        a = d['signature']
        lo, hi = a['eligible_speed_index_range']
        check(0 <= lo <= hi <= 1, f'Invalid action speed window: {d["id"]}')
        check(a['telegraph_id'], f'Missing telegraph: {d["id"]}')
    for a in arenas:
        for k in ['grip_multiplier', 'accel_multiplier', 'recoil_multiplier']:
            check(a[k] > 0, f'Bad terrain stat {a["id"]}.{k}')
    for g in gear:
        check(g['slot'] in ALLOWED_SLOTS, f'Invalid gear slot: {g["id"]}')
    check(set(m_ids) == EXPECTED_MODES, f'Unexpected modes: {m_ids}')
    check(all(m.get('pre_match_camera') for m in modes), 'Mode missing pre-match camera')
    check(rules['camera_live'] == 'rear_chase_over_rider', 'Current camera lock violated')
    check(rules['simulation_hz'] > 0, 'Invalid simulation step')
    check(example['arena'] in a_ids, 'Sample references missing arena')
    check(example['mode'] in m_ids, 'Sample references missing mode')
    check(example['player_dinosaur'] in d_ids, 'Sample references missing player dinosaur')
    check(example['enemy_dinosaur'] in d_ids, 'Sample references missing opponent dinosaur')
    check(all(x in g_ids for x in example['player_gear']), 'Sample references missing gear')
    check(rules['enforce_same_division'] and (next(d for d in dinos if d['id'] == example['player_dinosaur'])['division'] == next(d for d in dinos if d['id'] == example['enemy_dinosaur'])['division']), 'Sample normal match illegal division')

    # Check relative local links in *canonical* docs and README, not historical/archived ones.
    docs = list((ROOT/'docs/design').rglob('*.md')) + list((ROOT/'docs/production').rglob('*.md')) + list((ROOT/'docs/handoff').rglob('*.md')) + list((ROOT/'docs/ideas').rglob('*.md')) + list((ROOT/'docs/prompts').rglob('*.md')) + [ROOT/'README.md', ROOT/'AGENTS.md']
    missing = []
    for p in docs:
        content = p.read_text(encoding='utf-8')
        for candidate in re.findall(r'(?<!!)\[[^\]]*\]\(([^)]+)\)|!\[[^\]]*\]\(([^)]+)\)', content):
            link = (candidate[0] or candidate[1]).strip().split('#')[0]
            if not link or link.startswith(('https://', 'http://', 'mailto:')):
                continue
            if not (p.parent / link).resolve().exists():
                missing.append(f'{p.relative_to(ROOT)} -> {link}')
    check(not missing, 'Broken local links:\n  ' + '\n  '.join(missing))
    print(f'OK: {len(dinos)} dinos, {len(arenas)} arenas, {len(gear)} items, {len(modes)} modes, {len(docs)} canonical markdown documents; all local links found.')

if __name__ == '__main__':
    try:
        validate()
    except (ValueError, KeyError, TypeError, FileNotFoundError, json.JSONDecodeError) as e:
        print(f'FAIL: {e}', file=sys.stderr)
        sys.exit(1)
