# Gameplay, camera, platform and balance tests

**Status: none of these engine tests have run.** This file specifies future acceptance tests. Keep `verified`, `unverified`, and `environment-blocked` distinct in any Codex report.

| ID | Scenario | Expected observable result | Layer |
|---|---|---|---|
| T01 | Press throttle for 2s at constant ground | Speed increases using mount curve, independent of render FPS | Unit/Play |
| T02 | Release throttle before contact | Mount coasts/slows; movement remains within guided lane | Unit/Play |
| T03 | Commit lance too early/high | Valid MISS (0 lance points), no invisible aim correction | Collision |
| T04 | Hit valid rider zone at favorable angle | CLEAN; stability loss with diagnostics and contact point | Collision |
| T05 | Lance glances shield/armor | GLANCE; smaller stability change than equivalent clean hit | Collision |
| T06 | Raptor moderate-speed snap in range | Telegraph, one contextual contact, enemy stability adjustment | Dino state |
| T07 | Raptor at overly high speed | Snap inactive/less effective per defined speed window | Dino state |
| T08 | Defender brace vs direct shoulder/horn contact | Defensive response reduces loss with cause shown | Dino state |
| T09 | Rider lance and dino action on same pass | Simultaneous deterministic contribution, no arbitrary ordering | Combat |
| T10 | Same seed + sampled actions at 30/60/120 graphics FPS | Same match winner and scoring/contact log, within documented tolerance | Replay |
| T11 | Same two mounts on Stone vs Mud | Meaningful speed/grip delta without hidden damage bonus | Terrain |
| T12 | Match legal vs illegal weight/height | Illegal normal pairing refused, Exhibition override labeled | Rules |
| T13 | Opponent remains ahead until convergence | Rear-chase camera maintains target/lance visibility | Camera |
| T14 | Contact after commit triggers camera emphasis | No loss of control before lock, readable strike and beast cues | Camera |
| T15 | Large frill or long raptor neck occludes lance target | Shoulder camera offset/marker preserves target visibility | Camera |
| T16 | Same encounter on 16:9, 18:9, 20:9 landscape | Main target visible, touch buttons outside contact safe area | UI |
| T17 | Touch throttle and right drag concurrently | No pointer conflict; aim commit occurs on correct finger release | Mobile |
| T18 | Full dismount and replay | Physics props/ragdolls do not change already computed verdict | Physics |
| T19 | Rapid retry / skip replay | No stale impulses or lost input; game state resets | State |
| T20 | Camera shake reduced-motion setting | Stable camera and preserved aiming with reduced VFX | Accessibility |

## Human playtests

- Can novice land one genuine clean hit after brief onboarding?
- Can player describe why they lost (lance miss, beast counter, terrain, poor momentum)?
- Does a raptor feel different from a ceratopsian with same equipment?
- Do mud and stone cause different throttle choices without requiring a manual?
- Is chase perspective more thrilling **and** sufficiently precise compared with old sideline mockups?
- Do players request immediate rematch after losing?
- Does visible beast engagement complement rather than overwhelm lance play?

## Mobile performance evidence

Record actual device class, GPU/CPU, RAM, OS, engine build, resolution, graphics profile, average/1% low FPS, frame time, draw calls, animation skinning cost, physics step cost, peak spawned debris, thermal condition. No claims of 60 FPS without device measurements.

## Reproduction/debug format

```text
seed: 1234
scene: training_arena
player: velociraptor | opponent: protoceratops
surface: royal_stone | pass: 2
input_trace: saved replay path
commit_time: frame N
lance_grade: CLEAN | beast: PREDATOR_SNAP
stability: 72 -> 40 | result: STILL_MOUNTED
engine_commit: <git sha> | fps_preset: 30
```
