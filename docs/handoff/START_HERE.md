# Read this first — Crownfall handoff

## What has been agreed

- Title: **Jurassic Joust: Crownfall**; medieval knights joust on rideable dinosaurs.
- **True 3D**, shared PC + mobile game with **landscape mobile orientation**.
- **Two input families** in the duel: throttle and aim/release lance; no manual steering required in jousting lanes.
- Dinosaurs aren't transport. Distinct species and their body actions interact with the rider's lance timing and stability.
- Weight divisions, meaningful terrain, multiple modes (Campaign / Challenge / Draft / Endless / Exhibition).
- Skill-based chance in legal matchups; physics may be comedic but scoring must remain explainable.
- Current art: **stylized faceted chibi-anime fantasy 3D**, simpler low-mid poly, modular gear, recognizable dinosaur anatomy, vibrant fantasy tournament colors.
- Current live combat camera: **rear/above rider chase camera**, lane and enemy visible ahead, impact emphasis with post-contact camera sequence.

## What's only recommended / still open

- Engine: **Unity URP proposed**, not approved.
- Exact stability formula, mass ratios, timings, scoring values, pass count, AI thresholds, and special moves are prototypes, not finalized.
- Physics detachable limbs/head, armor/weapon loss and chain reactions remain an **idea backlog**, not mandatory for the MVP.
- Draft first as test mode, Campaign later; implementation order, not a canceled feature.

## Current repo state

- Full documentation and reference art packed.
- No playable code; no existing Unity/Godot project.
- Legacy v0.2 camera/art in `docs/archive/` is superseded by more recent conversation decisions.

## First practical sprint

1. Confirm engine choice, minimum supported mobile device class, project format, and a target test phone.
2. Create minimal actual 3D arena + **two guided lanes** with placeholder rider and mount geometry.
3. Implement fixed-step charge state machine and 2 controls on desktop; camera behind/above rider with opponent in central targeting window.
4. Implement one contact proxy + lance contact grade, stable dismount threshold and debug reason text.
5. Add simplest contextual dinosaur body attack (telegraph → conditional activation → contribution), no extra button.
6. Apply one terrain grip modifier, re-run the same tests, then add mobile landscape touch layout.
7. Only then replace graybox with first stylized models and ragdoll/gear detach VFX.

## Handoff checklist

- [x] Canonical Markdown GDD and decision table
- [x] Art bible and latest images
- [x] Camera, combat, asset pipeline, balance assumptions
- [x] Roadmap, backlog, test plan, Codex instructions
- [x] Example content JSON + validator
- [x] Historical draft preserved
- [ ] Engine approved
- [ ] Playable scene/code created
- [ ] Controls tested on real mobile device
- [ ] 3D models / rigs generated and integrated
- [ ] Matchup fairness validated with data
