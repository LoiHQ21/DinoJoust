# Design decision register (as of 2026-11-18)

**LOCKED** = user direction; **PROPOSED** = recommendation; **EXPERIMENT** = unvalidated hypothesis; **BACKLOG** = unapproved idea. Do not silently promote a backlog note to implementation.

| ID | Status | Decision | Why / provenance |
|---|---|---|---|
| D001 | LOCKED | Medieval knights mounted on dinosaurs in short tournament jousts | Original user pitch |
| D002 | LOCKED | Target Windows PC and iOS/Android in **landscape**, one real-time **true-3D** game | Cross-platform request |
| D003 | LOCKED | Two intuitive control families: dinosaur speed (throttle) and lance aim/timing | Original premise, reinforced repeatedly |
| D004 | LOCKED | Dinosaurs also actively participate with natural-weapon contacts, influencing the rider joust | Explicit new feature request |
| D005 | LOCKED | Different species have meaningful stats, strengths, weaknesses, temperament, size and terrain advantages | Explicit feature request |
| D006 | LOCKED | Standard matchmaking is weight/size-divided, avoiding absurd raptor–T. rex normals | Explicit feature request |
| D007 | LOCKED | Battlefield surface/weather affects dinosaur performance and strategy | Explicit feature request |
| D008 | LOCKED | Target Campaign, Challenge, Draft, Endless and Exhibition modes with shared core jousting | Multiple mode request; Exhibition recommended for testing |
| D009 | LOCKED | Fun ragdoll-like physical impact and comedic motion is part of feel | Repeated user request |
| D010 | LOCKED | Live combat camera **behind and above the rider** facing into the oncoming lane; impact is visually emphasized | User supplied two portrait joust screenshots and requested this view |
| D011 | LOCKED | Current visual direction: **faceted chibi-anime fantasy 3D**, low-to-mid poly, simple materials, strong species silhouettes and readable heroic color blocks | Later user supplied fantasy roster screenshot and asked to move away from Kingshot |
| D012 | LOCKED | Dinosaur silhouettes must remain biologically recognizable, not cuboid/voxel toys | User art direction constraint |
| D013 | PROPOSED | Contextual natural weapon attacks controlled via speed/position, no required third active button | Recommended solution to two-control problem |
| D014 | PROPOSED | Deterministic-ish fixed-step collision score separated from non-authoritative ragdoll animation | Fairness and reproducibility recommendation |
| D015 | PROPOSED | Ordinary matches have up to three passes; dismount wins immediately, glancing/clean lance score otherwise | Gameplay suggestion awaiting test |
| D016 | PROPOSED | Beast contact changes stability but does not automatically earn points | Latest narrative suggested this; v0.2 had a contradictory proposed point option |
| D017 | PROPOSED | All legal matchups have discoverable counters; no secret rubber-band or fake equal win rate | Fairness recommendation |
| D018 | PROPOSED | Division thresholds ~1.35 mass ratio / ~1.30 saddle height ratio | v0.2 placeholder; test with silhouettes and mechanics |
| D019 | PROPOSED | 3 lightweight dinosaurs, 2 terrains, 6-encounter Draft and simple Exhibition for MVP | Vertical-slice scope |
| D020 | PROPOSED | Unity URP as engine; Godot or Unreal are alternatives | Earlier GDD suggestion; owner has not approved engine |
| D021 | PROPOSED | Campaign hub is a click/tap 3D diorama, not open-world exploration | Scope control |
| D022 | EXPERIMENT | Brief hit-stop, micro camera reframing, post-impact close-ups and skippable replay | Camera polish requiring playtesting |
| D023 | EXPERIMENT | Beast stance selection before a pass if contextual instincts lack depth | Deferred feature concept |
| D024 | EXPERIMENT | Ragdoll armor, helmet, lance fragments may affect subsequent pass equipment statistics | Not yet tested, would complicate balance |
| D025 | BACKLOG | Detachable heads, limbs, weapons, shields and armor plus physical chain reactions | User volunteered an idea for later brainstorming, not a mandatory feature |
| D026 | BACKLOG | Exhibition mismatch fights, opponent grapple sequences and post-dismount dinosaur actions | Optional experiments, avoid early scope creep |

## Supersession history

1. **Original**: 2D-side-view / semi-realistic or cartoon 3D concepts while game evolved.
2. **2026-11-17 first lock**: bright rounded Kingshot-inspired stylized true 3D for easy production and playful feel.
3. **Later user screenshot**: primary duel camera changed from side-view to **forward over-rider chase**. Side view can still be used *after* impact, not while active timing is critical.
4. **Later reference screenshot**: art moved to **faceted/angular, chibi-anime fantasy 3D**, retaining accessible low-poly production discipline. This supersedes the rounder Kingshot-like look.
5. **Still open**: engine choice, numbers, detailed scoring, actual family rig count and whether rear-chase can show both lance + beast reactions clearly without losing aim readability.

## Change procedure

Any implementation change to LOCKED entries must explicitly call out the deviation and ask owner to decide. For PROPOSED/EXPERIMENT details, create a test and document the result before promotion. Never treat reference-art text as authoritative numerical balance.
