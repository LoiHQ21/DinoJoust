# Content modes and progression

All modes share ONE 3D duel system with the same rear-chase combat camera and input rules; they change match context, meta progression and pre/post screens. Do not reimplement collision or camera separately for each mode.

| Mode | Player reason to play | Outside-duel camera | Progression | MVP? |
|---|---|---|---|---|
| Campaign | Rookie to royal champion, rival knight arcs, region divisions and arena unlocks | Elevated 3D tournament courtyard diorama | Persistent chapter/cup advancement | Later |
| Challenge | Solve hand-made timing, species and terrain puzzles | 3D animated miniature podium / arena preview | Medals, unlock milestones | Later |
| Draft | Build unique short-run lance/saddle/perk synergies from randomized rewards | Rotating 3D mount+rider on a plinth; route map | Temporary run perks; unlock breadth, not raw grinding | FIRST MINI RUN |
| Endless | Survival record and escalating AI tactics | Arena sweep between bouts and streak overlay | Score/streak, no infinite mass inflation | Later |
| Exhibition | Custom matchups, gear and terrain tests, funny unbalanced matches | Dual 3D showroom turntables, config cards | No forced permanent progression | BASIC DEBUG MODE |

## Draft run proposal

Choose registered weight class -> choose from three legal mounts -> equip basic lance/saddle/perk -> inspect 2–3 next route encounters -> joust (1–3 passes) -> select one of three rewards -> loop 6 encounters for MVP (later 8–12) -> boss -> victory or run ends. Stable progression is *choice expansion*, not +9999 strength overpowering early rivals.

## Equipment identity

- **Lance slot:** length/reach, strike grade conditions, spring, splinter, heavy lance; creates aiming decisions.
- **Saddle/armor slot:** rider stability and recoil tradeoffs; e.g., Reinforced Saddle trades acceleration for brace.
- **Perk slot:** enhances a species/terrain/speed playstyle; e.g., Underdog Crest favors low-profile legal mount matchups.
- **Dinosaur innate action:** signature persists and cannot be replaced by generic gear; gear can accentuate its trigger/readability.

## Arena strategy

Arena surface changes *actual physics* and body contact triggers. Proposal: Royal Stone Court (grip/hard recoil), Mud Pit (slower acceleration), Sunscorched Sand (low traction sudden changes), Frozen Grounds (sliding/slow recovery). Keep one main effect per arena plus at most one meaningful weather modifier. Avoid environmental visual chaos during the impact moment.

## Division fairness

Light / Middle / Heavy classes with mass and saddle-height checks. The roster is fantasy scaled for rideability but dinosaur species silhouettes remain recognizable. No normal full-size T. rex versus little raptor duel. Exhibition may explicitly override with an imbalance warning. Exact thresholds require test, current GDD numbers are placeholders.

## AI archetypes

Sprinter, Sniper, Counterpuncher, Brawler, Feinter. For MVP implement at most four standard profiles and one boss combining clearly communicated tells. AI must respect same lance collision, mass and dinosaur instinct rules.
