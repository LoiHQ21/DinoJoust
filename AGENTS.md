# Codex repository instructions: Jurassic Joust: Crownfall

## Source-of-truth precedence

1. Explicit instructions from the repo owner in the active task or PR.
2. `docs/design/DECISIONS.md` for LOCKED requirements.
3. `docs/design/GDD_v0.3.md` and linked current design pages.
4. `docs/production/TEST_PLAN.md` and roadmap acceptance criteria.
5. Archived v0.2 GDD and archived images: **historical only**, never override newer art/camera decisions.

## Project purpose

Build a **true-3D**, third-person dinosaur-mounted jousting action game for **Windows PC and mobile landscape**. A duel is about rider lance accuracy plus species-specific dinosaur contact, with stable physics resolution and entertaining post-impact reactions.

## Non-negotiable product rules

- Gameplay has two control families: **throttle** and **aim/commit lance**. Dinosaur attacks are contextual. Do **not** add mandatory bite/steer/dodge buttons without owner approval.
- Live joust camera is **behind/above the rider looking down the lane**, adapting to landscape/mobile safe areas. This is a later lock superseding the v0.2 sideline camera. Keep aiming readable; no camera cut during the active timing window.
- Look: original **faceted chibi-anime fantasy 3D**, not semi-realistic and not block/voxel dinosaurs. The latest concept refs live in `assets/concepts/current/`.
- Mounted dinosaurs keep distinctive species silhouette, movement, stats, and legible contextual actions.
- Normal matchmaking enforces division and practical mass/height limits. Extreme size mismatches only in clearly marked Exhibition experiments.
- Terrain must affect meaningful motion such as acceleration and grip; it cannot just change background colors.
- Combat outcomes must be determined by stable game state, **not** by random ragdoll outcomes or animation glitches.
- No hidden rubber-band victory. A legal matchup needs a viable skill-based counter, not guaranteed player success.
- Scope discipline: build **one** excellent joust before any full campaign, online multiplayer, open-world exploration, or dozens of dinosaurs.

## Status labels

- **LOCKED**: confirmed creative/technical requirement from conversation; changing it needs owner's decision.
- **PROPOSED**: working implementation recommendation; validate via prototype.
- **EXPERIMENT**: cheap hypothesis or test; do not add to baseline without evidence.
- **BACKLOG**: creative ideas not approved for implementation.

## First Codex task

Read `docs/prompts/CODEX_FIRST_TASK.md`, implement or propose the smallest graybox vertical slice, and present a short change list plus explicit `verified / unverified / environment-blocked` checks. If engine/project has not been chosen, first propose the engine choice and minimal folder layout; **do not pretend the game project already exists**.

## Implementation standards

- Separate fixed-step scoring/contact from animation, VFX, camera and UI layers.
- Favor data-driven configuration over hard-coded species/arena special cases.
- Record deterministic encounter inputs and diagnostic contact events; expose debug visualizations.
- Separate input mapping from gameplay state so PC and mobile drive the same actions.
- Use accessible UI size, safe areas, and performance tiers for landscape phones.
- Preserve human-readable documentation when implementing a rule; update GDD and decision status when changes are approved.
- Include a minimal reproducible test for every core system and a clear local run/build command when a codebase exists.
- Do not use artwork from third-party screenshots as game assets. Do not claim AI concept images are rigged meshes.

## Boundaries

The example JSON in `data/` is *illustrative proposal data*, not validated gameplay balance. Old references may depict out-of-date camera and art style; leave them archived for traceability. Head/limb detachment is backlog, **not** an approved gore feature or MVP mechanic.
