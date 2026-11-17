# Ordered implementation plan (NOT a delivery schedule)

**Goal:** maximize validated game feel before content. This is a solo/very small-team plan. Source files are documentation; no engine project is currently present.

## P0 — Project/engine choice and setup

- Decide Unity URP vs Godot/Unreal against target platforms, development skill, profiling and asset workflow.
- Create reproducible engine project, lock version in `README`, create export/build targets, one CI smoke build if feasible.
- Establish folder layout: `Runtime/Combat`, `Runtime/Camera`, `Runtime/Input`, `Data`, `Scenes`, `Art`, `Tests` (adapt per engine).
- **Exit gate:** editor opens clean, a true-3D scene plays, repo has setup instructions, basic desktop build runs.

## P1 — Graybox joust (highest priority)

- Pair of guided lanes in a simple 3D courtyard; placeholder dinosaurs and riders with distinct collision proxies.
- Acceleration, coast, terrain traction and stability; Space/left-touch throttle.
- Lance vertical aim and commit; mouse/right-touch input mapping shared in gameplay state.
- Locked rear-chase camera with readable oncoming rival and unobscured impact point.
- Contact resolver grades miss/glance/clean; deterministic stability loss and dismount verdict.
- Debug HUD/log explains velocity, aim, contact grade, stability before/after.
- **Exit gate:** can deliberately miss, glance and clean-hit, repeat outcome from a seed/input trace, win/lose with clear feedback.

## P2 — Dinosaur participation and fairness

- 2 lightweight competitors first (e.g., Velociraptor and Protoceratops), then a third when rig/content pipeline works.
- Distinct speed/traction/height profiles and one contextual body action per species.
- Visible preparation tell and counterplay, shared contact window with lance event.
- One hard/soft arena contrast (Stone and Mud).
- Test at least 20 repeated encounter seeds and both rider positions; no invisible wins.
- **Exit gate:** changing species or terrain changes optimal approach, not just color and stat bars.

## P3 — First art/feel slice

- Faceted chibi knight rig + one biped dinosaur and one low ceratopsian model.
- Readable head/horn/bite tells from chase camera, clipped geometry fixed, modular lance/saddle.
- Convert rider to ragdoll after valid knock-off; optional helmet/lance drops visual-only.
- Clean hit spark/dust/audio and short skippable after-impact replay camera.
- **Exit gate:** actual gameplay at landscape 1280×720 still has legible aim and contact, art matches style bible.

## P4 — Mobile landscape and performance

- Touch controls, safe-area insets, support 16:9 through 20:9 landscape and varying aspect ratios.
- Camera and HUD on a physical mid-range Android and iOS target if available.
- Profile draw calls, CPU physics, GPU, UI overdraw, animation skinning, VFX/ragdolls.
- **Exit gate:** comfortable touch aiming without UI occlusion and stable device FPS goal (baseline 30, aspirational 60).

## P5 — Mini Draft + Exhibition vertical slice

- 6-encounter branching run, three equip slots, eight meaningful items, 4 AI archetypes and boss.
- Rewards/menus use 3D showroom turntable not a new game mode renderer.
- Simple Exhibition test screen with legal and unbalanced match rules.
- **Exit gate:** complete one 10–20 minute test run; logs show meaningful upgrade/species/arena differences.

## P6 — Only after proven fun

- Campaign story/regional cups and diorama; Challenge medal puzzles; Endless streak logic.
- Additional classes/species, more equipment synergies and environments.
- Ragdoll gear persistence or more elaborate Beast Clash only if testing supports it.
- Online play, open-world riding and limb/head detachment are not scheduled MVP scope.

## Suggested GitHub issues for first sprint

1. `[Decision] Pick engine and target mobile baseline` — architectural blocker.
2. `[P1] Graybox two-lane arena and match state machine` — basic scene moves through phases.
3. `[P1] Throttle control + shared PC/mobile action layer` — measured speed curves.
4. `[P1] Rear-chase camera and aim-safe framing` — target remains visible at 16:9/20:9.
5. `[P1] Lance aim/commit and contact grades` — reproducible clean/miss/glance.
6. `[P1] Stability and dismount + match result reason` — fixed-step deterministic score.
7. `[P2] Raptor instinct and Protoceratops brace` — tell + mutual counterplay.
8. `[P2] Stone/Mud grip contrast` — changes actual speed and stability log.
9. `[P3] First faceted rigged knight and dinosaur` — art pipeline proof.
10. `[P4] Landscape touch controls and on-device measurement` — actual evidence.

Assign these incrementally to Codex rather than requesting them all at once.
