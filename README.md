# Jurassic Joust: Crownfall

**Repository handoff / documentation-first starter** · consolidated 18 November 2026 · **not a playable game yet**

> **Pitch:** Ride a stylized dinosaur into compact medieval jousting tournaments. Win with a combination of rider lance skill, your dinosaur's natural combat instincts, terrain reading, and momentum. Dramatic ragdoll reactions are the reward, not the scoring engine.

## Start here

1. Read [`AGENTS.md`](AGENTS.md) before running Codex. It establishes project rules and prevents accidental scope creep.
2. Read [`docs/handoff/START_HERE.md`](docs/handoff/START_HERE.md) for current status and the next task.
3. Use [`docs/design/GDD_v0.3.md`](docs/design/GDD_v0.3.md) as the **canonical living GDD**. It supersedes the archived v0.2 draft where they conflict.
4. Verify the latest visual look using the four concepts below and [`docs/design/ART_BIBLE.md`](docs/design/ART_BIBLE.md).
5. Start with the first task in [`docs/production/ROADMAP.md`](docs/production/ROADMAP.md); do not implement everything simultaneously.

## Canonical visual references (AI concept art, not 3D model files)

| Live chase camera | Rider + dinosaur impact | 3D hub | Riders + mounts |
|---|---|---|---|
| ![Chase duel](assets/concepts/current/01_joust_chase_camera.png) | ![Collision](assets/concepts/current/02_rider_dino_impact.png) | ![Hub](assets/concepts/current/03_tournament_hub.png) | ![Roster](assets/concepts/current/04_mount_rider_roster.png) |

The current visual target is **original faceted chibi-anime fantasy 3D**: readable low-to-mid-poly meshes, angular/beveled armor, bold color blocking, expressive riders, dinosaur anatomy that still reads instantly, friendly tournament pageantry. It **replaces** earlier rounded Kingshot-inspired art direction, while retaining accessibility and asset economy.

**Camera:** live jousting uses a rear three-quarter **chase view** looking down the lane (not the former side-on view). A very brief impact emphasis and skippable follow-through/replay can use other angles **after input commit or after resolution**. This must work on PC and mobile in **landscape**.

## Deliverables already in this repo

- [Six rigged art prototypes](assets/roster/README.md): three knights and three dinosaur species, Blender sources, GLBs, an [offline preview gallery](assets/roster/index.html), and validation reports
- Canonical design docs, decision register, systems/specs, constraints, open questions
- Codex instructions and concrete first implementation task
- Structured *illustrative* JSON data with schema validation script
- User-confirmed art/camera references plus earlier concept generations preserved in archive
- An earlier GIF **concept only**, not real-time game-engine footage
- Archived original GDD v0.2 (Markdown and Word) for traceability
- Task backlog and GitHub issue templates

## What's not present

No Unity/Godot/Unreal project, game build, playable prototype, gameplay telemetry, or tested balance values. The new rigged art prototypes have interchange-file checks, but no engine/gameplay validation. Reference pictures are not production assets. **Do not claim the game is implemented or tested.**

## Recommended immediate next step

Make a graybox true-3D joust in a chosen engine with two rigs or primitive stand-ins, guided lanes, throttle and lance controls, a stable chase camera, fixed-step contact outcome logging, and an obvious result screen. **Do not start with the campaign hub or full character roster.**

## Engine and tooling

**Unity URP is a proposal**, not a user-approved lock. Confirm the engine in a project decision before creating engine-specific folders. Codex should default to a self-contained vertical slice and document any assumptions. Candidate alternatives are Godot 4 or Unreal, provided realistic mobile performance testing is planned.

## Repository usage

This folder can be extracted and pushed to a new GitHub repository. See [`docs/handoff/GITHUB_SETUP.md`](docs/handoff/GITHUB_SETUP.md). Source art supplied as screenshots of other games/ads is intentionally **not bundled**. Generated concepts and [documented Quaternius CC0 base models](assets/third_party/quaternius/README.md) are included.

No repository-wide license is selected. The bundled third-party model sources retain their documented CC0 terms; this does not set the license for project code or newly authored adaptations.
