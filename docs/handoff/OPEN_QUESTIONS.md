# Open questions before implementation

These have **not** been decided by the user, so Codex should not quietly lock them in.

| Question | Current working recommendation | Decision timing |
|---|---|---|
| Engine selection | Unity URP candidate; Godot or Unreal allowed | Before P0 |
| Target mobile floor | Profile a real mid-range Android first and iOS later | Before P1 production commitments |
| Mobile orientation | Landscape is locked, but precise aspect ratios/safe areas require devices | P1/P4 |
| Combat pass duration | Roughly 8–18 seconds, test for tension | P1 playtest |
| Standard joust score | Clean +2, glance +1, beast stability only | P1/P2 playtest |
| Is every legal species pairing practically winnable? | Require learnable counters, don't promise 50/50 odds | P2 balance test |
| Beast action strength | Try cap around 15–20% stability per pass | P2 test |
| Dino instinct trigger conditions | Speed+distance+direction, visible tell, one action/pass | P2 test |
| Mass/height matchup ratios | Initial ratios 1.35/1.30 as placeholders | P2 matchup validation |
| Chase-camera over-shoulder offsets | Tune with actual dinosaurs and 16:9/20:9 display | P1 camera prototype |
| Impact camera cut timing | Only after aim commit/outcome; small hit-stop | P1/P3 test |
| Blend of ragdoll and detachable gear | Visual-only initially | P3 |
| Should heads/limbs detach in slapstick way? | Not approved, non-gory only if later evaluated | After core fun proven |
| Primary shipping mode | Draft slice first, then Campaign | After P5 review |
| 3D world hub movement | Clickable fixed diorama to control scope | Campaign design phase |
| Visual target/head proportion | 2.5–3.5 chibi heads proposed; test in chase cam | P3 art proof |
| Source model pipeline | Blender modular rigs; AI used for concept/blockout | P3 art proof |
| Monetization/online services | No current decision; avoid implementing | Long term |
