# JURASSIC JOUST: CROWNFALL
## Game Design Document — v0.2 | Review Draft | 17 November 2026

**Platforms:** Windows PC + iOS/Android phones in LANDSCAPE mode. **Engine target:** Unity URP (proposed; Godot 4 Forward+/Mobile or Unreal possible after benchmarking). **Rendering:** genuine real-time 3D environments, characters, animation, and contact. **Core interaction:** throttle + aim/release lance. **Genre:** bite-sized action-sports jousting + roguelite draft + tournament campaign.

> **Status convention:** LOCKED = user requirement or strong implementation baseline; PROPOSED = recommendation requiring review; EXPERIMENT = must be tested in prototype. All numbers are initial balance assumptions, not final game facts.

![Opening gameplay reference](Crownfall_v02_Visual_References/01_Duel_3D_SideView.png)

## 0. Creative brief and decision register

**One-sentence pitch:** Ride a stylized dinosaur into short, spectacular medieval jousts where the knight's lance and the dinosaur's natural weapons both determine who stays in the saddle.

| Decision | Status | Implementation interpretation |
|---|---|---|
| True real-time 3D | LOCKED | 3D meshes, rigged dinosaurs/riders, physically staged arena, real shadows/lighting; not 2D sprites or cardboard layers |
| PC + mobile landscape | LOCKED | One shared game, responsive 16:9 through 20:9 landscape layouts, keyboard/mouse and touch |
| Simple, prototype-friendly, Kingshot-like visual accessibility | LOCKED | Original toy-like stylized 3D; chunky silhouettes, low detail, bright readable materials; no imitation of proprietary models/UI |
| Dinosaur fights too | LOCKED | Dinosaur-specific body contact attacks integrated into jousting; no dinosaur as passive speed stat |
| Two controls only in match | LOCKED | Throttle and lance aim/release; dinosaur techniques trigger contextually |
| Weight/division-based fair matchmaking | LOCKED | Normal tournaments enforce mass AND saddle-height limits; no baby raptor versus full T. rex |
| Terrain changes strategy | LOCKED | Grip, acceleration, recoil, and animal technique windows react to arena conditions |
| Multiple game modes | LOCKED | Campaign, Challenge, Draft, Endless, Exhibition; shared duel simulation |
| Guaranteed winning chances | PROPOSED | Each standard match has a learnable, skill-based path to win; no hidden rubber-banding |
| Deterministic combat + lively physical reactions | PROPOSED | Fixed-step outcome model, exaggerated but non-authoritative hit reactions |
| Open jousting corridor | PROPOSED | No central full-height barrier: overlapping natural weapons can contact opposing dinosaur |
| Optional Beast Stance choice | EXPERIMENT | Pre-pass stance only if the initial 2-input combat lacks decision depth |

### Non-goals for the first release

No open-world riding, free-steering combat, breeding simulation, online ranked PvP, full-body physically simulated dinosaur locomotion, gore, or dozens of species at launch. A sprawling castle hub is not required for the MVP: it is an interactive 3D diorama and menu rather than a walking simulator.

## 1. Product vision and player experience

### 1.1 Design pillars

1. **Master in a minute, improve for hours:** The first joust is playable with two controls; mastery comes from reading opponents, speed choice, aiming, and species matchup.
2. **Two fighters per team:** Knights use lances; dinosaurs use horns, jaws, shoulders, tails, and temperaments. Both are visibly relevant.
3. **Every dinosaur has a reason to exist:** Different hit geometry, movement curves, technique windows, weaknesses, and preferred terrain.
4. **Clear before clever:** A player understands a loss from visible strike lines, impact feedback, and a replayable result breakdown.
5. **Physics is the punchline, not the referee:** Dramatic knock-offs, bent lances, dust, comic stumbles, but stable simulation rules.
6. **Replayability by tactical variety:** Draft choices, arena conditions, opponents, and equipment create new decisions rather than pure numerical inflation.

### 1.2 Audience and sessions

Accessible to players aged approximately 10+ who enjoy short competitive games, 3D creature characters, slapstick physics, boss duels, and compact roguelites. **Target:** a jousting pass of about 8–18 seconds, an encounter of 30–90 seconds depending on passes, and a Draft run of about 10–20 minutes. These are playtest targets.

### 1.3 Fantasy and tone

An absurd but internally believable kingdom has turned medieval jousting into the world's grandest dinosaur sport. Competitive stakes are sincere; animation and spectators are humorous. No gore or realistic injuries. Dinosaurs are spirited athletic partners, not expendable monsters.

## 2. Game loop and contest rules

### 2.1 From menu to reward

1. Inspect opponent, division, arena, and weather; choose a legal mount and gear.
2. Enter a 3D arena. A short readable intro reveals opponent species and its visible signature technique.
3. Perform a joust pass: throttle, aim and commit lance, resolve rider strike and beast contact, witness physics reaction.
4. If neither rider falls, reset to starting lines and repeat, carrying over appropriate stability strain.
5. Resolve match after a maximum of three ordinary passes. Choose loot, improve loadout, and take the next tournament branch.

### 2.2 Victory, defeat, and scoring

**Primary win:** Knock the opposing rider out of the saddle. **Secondary win if three passes end without knock-off:** Higher accumulated tournament points wins (clean lance strike, effective beast contact, retained stability), with transparent point contributions. **Tie:** one sudden-death pass, after which the higher stability remaining wins if still tied. **Defeat:** player unseated, or opponent wins on points. No health bar combat and no dinosaur death.

### 2.3 Arena layout

Two opposing mounts run on guided, slightly offset 3D corridors. Riders have clear lance reach; the open inner space also allows snout, frill, shoulder, and post-pass tail contact. Players do not steer; they influence when and how strongly the creatures meet through speed. The arena must be wide enough for both mounts and clear silhouette overlap at mobile resolutions.

## 3. In-match controls and combat timing

### 3.1 Two control families

| Input | PC keyboard + mouse | Mobile landscape | Meaning |
|---|---|---|---|
| Throttle | Hold Space | Hold left thumb throttle pad | Accelerate; release to coast and drag down to species/terrain baseline speed |
| Aim lance | Mouse button hold, drag vertically | Touch and drag right-side lance zone | Set angle from low to high; live projected reach indicator |
| Commit lance | Release mouse button | Lift right thumb | Lock angle; brief wind-up creates contact window; recover if no hit |

**Gamepad option (post-MVP):** right trigger = throttle; right-stick vertical aims; stick-click or face-button commits. It remains the same two control systems, even if the physical mapping differs.

The player can change throttle while aiming. The lance cannot be instantly retargeted during its final commitment window (initial target 0.3–0.5 s, to tune). Aim assist is mild and communicated in accessibility settings, never hidden enough to turn a miss into a clean hit.

### 3.2 Pass state machine

| State | Length target | Player can do | Simulation/feedback |
|---|---|---|---|
| Start & read | 2–4 s | See rival, terrain, tell | Brief cinematic establishing angle then stable side camera |
| Charge | 4–10 s | Throttle, aim | Terrain grip, acceleration, opponent behavior |
| Commit | 0.3–0.5 s | Throttle continues; no re-aim | Lance contact shape extended; telegraph stays readable |
| Contact | 0.15–0.45 s | No extra input | Simultaneously evaluate rider lance and dinosaur contact |
| Recovery | 1–3 s | Watch feedback | Stability update, rider stumble, dinosaur recoil, particles |
| Reset / result | 1–3 s | Next pass or reward | Simple scoreboard, no excessive animation wait |

### 3.3 Three strike grades

- **Clean:** contact near the valid saddle/rider zone with favorable angle and timing; visible gold spark and stronger stability damage.
- **Glancing:** lance catches armor/shield or leverage is poor; scrape sound and smaller stagger.
- **Miss:** lance does not connect; clear whiff sound, no arbitrary damage. The dinosaur may still make a legitimate body contact independently.

The rider never has to control the dinosaur's jaw, horns, or tail with another button. The creature's techniques come from its position, speed, and behavior.

## 4. Dinosaurs are combatants: evaluated design options

| Approach | Mechanic | Benefit | Cost / risk | Verdict |
|---|---|---|---|---|
| Natural-weapon contacts | Species-specific horn, bite, shoulder, tail collision windows | Clear identity; intuitively physical | Needs hit geometry and anim timing | MVP YES |
| Contextual triggered techniques | Auto trigger when distance/speed/stance condition met | Preserves two controls; feels responsive | Can feel random without readable tells | MVP YES |
| Combat temperament | Aggressive, wary, stubborn responses alter trigger thresholds and stability tendencies | Personality and draft variety | Must not introduce hidden hit chance | MVP LIGHT |
| Pre-pass Beast Stance | Choose Charge / Brace / Counter before each pass | Adds tactics without match-time controls | More menu friction and AI tuning | LATER TEST |
| Beast Clash interlude | Short shove/grapple when creatures meet | Spectacle; differentiates the IP | Can obscure a clean jousting result | MVP SHORT REACTION |
| Post-dismount rescue | Dino can temporarily keep fighting after rider falls | Comic comeback opportunity | Undermines clear win condition | EXHIBITION ONLY / MAYBE |

### 4.1 Recommended MVP: Contact Instinct

Every species has **one innate technique** with: explicit activation geometry, a minimum/maximum useful closing speed, a telegraph, one attempt per pass or defined cooldown, a primary stability effect, and a weakness. It activates automatically when conditions are met. The player's throttle changes contact speed and timing; lance aim and commitment can leave the rider more or less well braced when the creatures clash.

**Examples:**

- **Raptor Snap (close pass):** The raptor can briefly nip at the opponent's shoulder after a low-speed near-pass. More reliable at moderate speed; loses to horn-first contact and wide spacing.
- **Triceratops Horn Check (front contact):** At controlled medium speed, horn/frill contact briefly shoves the opposing mount and destabilizes its rider. Vulnerable to precise high lance strikes and aggressive over-speeding.
- **Ankylosaurus Tail Rebuttal (post-pass):** After surviving a close pass, a short follow-through tail swing can create a secondary stagger if the opponent remains within the rear-side arc. Cannot initiate before crossing.
- **Carnotaurus Shoulder Rush (crossing):** Higher-speed shoulder contact pushes the rival laterally, but a miss increases its own recoil.
- **Pachycephalosaurus Headbutt (front contact):** Short-range head strike in the appropriate height zone; strong on narrow targets, risky against longer horns.

### 4.2 Beast Clash camera and limits

Beast Clash occurs within the same jousting pass, **not** a new minigame. When bodies touch, play a <=0.75-second contextual pair animation (horn lock, shoulder bounce, snap, tail follow-through), possibly a very brief hit-stop. The visual must match the already computed outcome. No additional QTE, surprise attack button, or untelegraphed free damage. If both dinosaur attacks connect, both can suffer recoil and stability effects.

### 4.3 Signaling and counterplay

A creature lifts its head, braces feet, lowers horns, or winds its tail before the active window. Distinct audio cues and a subtle species icon reinforce the cue. Counterplay includes changing speed, using lance height to target exposed rider regions, and choosing a dinosaur whose body profile avoids the opponent's strongest contact range. Arena terrain can disrupt or strengthen specific techniques through traction, never through invisible dice rolls.

![Dinosaur combat concept reference](Crownfall_v02_Visual_References/05_Dinosaur_Attack_Concepts.png)

## 5. Collision, stability, and fun physics

### 5.1 Authoritative 3D collision model

Use simplified 3D collision proxies (capsules/boxes/convexes) attached to bone transforms: lance head/shaft, rider torso, shield, saddle, dinosaur head/horns, shoulder, flanks, and tail segment when relevant. At a **fixed simulation timestep**, sample position, velocity, stance, and hit normal. The scoring system uses these stable proxies rather than GPU particle systems or ragdoll joint luck.

**Suggested model (placeholder, tunable):**

- Closing speed = relative approach velocity along jousting axis.
- Impact impulse estimate = reduced mass x closing speed x contact alignment; clamp to division-specific safe scale.
- Rider destabilization = lance contact quality x leverage x impulse + innate beast contact contribution - shield/saddle/brace mitigation.
- Grip and terrain determine acceleration and resistance to slip; body recoil also feeds into rider stability.
- Rider is unseated when accumulated destabilization exceeds the stability reserve; partial strain may persist between passes.
- Resolve simultaneous lance and beast contact using the same timestamp/contact window before awarding a result. One animation cannot erase a valid simultaneous strike.

All multipliers and thresholds live in data assets, not hard-coded species branches.

### 5.2 Fun-physics layer (visual only)

Once the win/score result is decided, launch stylized ragdoll rider reactions, bend/break lance props, nudge dinosaur rigs, kick up chunky dust decals, and bounce harmless armor pieces. Small mounts visibly skid; heavy ones do an exaggerated shoulder roll. Snap back to a stable pose before another pass. Physics random seeds may vary tumble direction, **not who wins**. The creature should not ragdoll into impossible anatomical shapes.

### 5.3 Readable replay

Decisive hits may trigger a 0.5–1.2-second replay with slight zoom, short hit-stop (30–80 ms), and the two causes labelled **Lance / Beast**. Replay is skippable and can be disabled on mobile. No camera shake that obscures precision during active aim.

### 5.4 Fairness and anti-frustration

Normal matchmaking must pass both mass and rider-seat-height bounds. In ordinary encounters, every legal mount/opponent matchup must have at least one practical tactical counter supported by collision geometry. No secret catch-up damage, invisible invulnerability, or scripted miss. Some matchups are harder by design; Campaign can grant retries and practice. Exhibition can ignore class limits with an explicit warning that balance is not guaranteed.

## 6. Dinosaur roster and divisions

### 6.1 Tournament sizing

These are **fantasy, tournament-bred, rideable interpretations** of recognizable species, not literal paleontological scale. To preserve species identity: retain distinctive head shapes, body posture, tail length, plates/frill, and characteristic gait. Do not turn every dinosaur into a similar stocky lizard. Internal mass values are gameplay normalized, but visible body footprint still matches expected class.

**Division eligibility proposal:** every creature carries `(mass_index, saddle_height_index, length_index)` and a registered division. A normal matchup requires the same registered division and a maximum pre-tune mass ratio about 1.35 plus saddle-height ratio about 1.30. An adjacent-class exhibition or special event requires explicit rule overrides. No ordinary raptor-versus-T. rex.

| Division | Recognizable example species | Common combat identity |
|---|---|---|
| LIGHT | Enlarged Velociraptor, Protoceratops, Pachycephalosaurus, Gallimimus | Acceleration, low profile, narrow contact timing |
| MIDDLE | Utahraptor, Carnotaurus, Parasaurolophus, Corythosaurus | Burst speed, versatility, shoulder/body counterplay |
| HEAVY | Triceratops, Ankylosaurus, Stegosaurus, T. rex | Mass, bracing, wide body weapons, slower turns of momentum |

Species assignments are provisional; silhouette and usable mass bands take precedence over literal real-world weights. T. rex and Ankylosaurus are separate playstyles despite sharing a tournament division.

### 6.2 Core dinosaur data schema

`species_id`, `division`, `mass_index`, `saddle_height`, `body_length`, `accelerate_curve`, `top_speed`, `traction`, `balance`, `recoil_resist`, `temperament`, `signature_contact`, `valid_contact_geometry`, `telegraph_anim`, `cooldown_passes`, `favored_terrain`, `weak_terrain`, `lod_meshes`, `anim_set`, `audio_set`.

### 6.3 Identity and matchup examples

| Species | Strength | Weakness | Unique natural attack |
|---|---|---|---|
| Velociraptor (Light) | Quick speed changes, low rider profile | Low mass and contact tolerance | Raptor Snap after near-pass |
| Protoceratops (Light) | Strong brace and short-horn interception | Limited sprint | Frill Guard + Nose Nudge |
| Pachycephalosaurus (Light) | Strong burst at short contact gap | Very narrow attack window | Dome Headbutt |
| Carnotaurus (Middle) | Late sprint and shoulder reach | Overrun/recoil risk | Shoulder Rush |
| Parasaurolophus (Middle) | Stable speed, long gait, sustained momentum | Weak direct head weapon | Body Feint/Lean |
| Triceratops (Heavy) | Front stability, head-on counter | Large target, modest acceleration | Horn Check |
| Ankylosaurus (Heavy) | Defensive recovery, low center of mass | Low top speed, tail timing | Tail Rebuttal |
| T. rex (Heavy) | Intimidating bite and high impact mass | High saddle profile and slower control response | Powerful short-range Bite Check |

The MVP implements **three Light mounts** and their authentic-looking silhouettes; larger classes are roadmap content, not required to validate the core duel.

![Dinosaur roster visual reference](Crownfall_v02_Visual_References/03_Dinosaur_Roster_Stylized_Models.png)

## 7. Arenas, terrain, and conditions

Terrain affects actual motion and collision, not arbitrary damage bonuses. Each arena has **one dominant property**, and optionally **one clearly signaled weather condition**. Players can scout the arena before locking their mount.

| Arena | Dominant physics behavior | Tactical expression | Readable visual treatment |
|---|---|---|---|
| Royal Stone Court | High grip and strong hard-surface recoil | Powerful late attacks; overcommit is dangerous | Clean tan stones, gold/red banners |
| Mud Pit | Heavy mounts accelerate slowly and slide less predictably | Establish speed early; grip specialists gain value | Brown mud strips, soft chunky splashes |
| Sunscorched Sands | Low traction during rapid speed changes | Smooth throttle management beats late sprint | Yellow-orange dunes, heat tint |
| Frozen Grounds | Poor lateral grip and slower recovery after stumble | Controlled approach, avoid wild commitments | Blue ice patches, clean slide streaks |
| Tall Grass Field (post-MVP) | Low visual body cues in grass; no hidden lance target | Read opponent posture rather than feet | Green swaying grass, strong silhouette contrast |

**Weather:** rain amplifies wet traction penalties; wind minimally shifts the lance's cosmetic sway but must never make aiming random; snowfall changes visual atmosphere before introducing new physics. Never stack more than two impactful modifiers in an ordinary duel.

![Arena concepts](Crownfall_v02_Visual_References/06_Arena_Terrain_Concepts.png)

## 8. Modes: structure and camera rules

### 8.1 Shared fundamental rule

**Every actual duel in every mode uses the same 3D jousting camera and combat mechanics.** Modes change stakes, opponents, rewards, and pre-/post-match presentation, not controls or hit physics. This prevents five divergent combat implementations.

| Mode | Player experience | Pre/post match camera | Actual duel camera |
|---|---|---|---|
| CAMPAIGN | Unlock regional leagues, rivals, weight divisions, narrative championships; retry losses | Fixed high three-quarter **interactive 3D courtyard diorama**; select Stable, Tournament Gate, Workshop via clicks/taps | Shared 3D sideline broadcast camera |
| CHALLENGE | Hand-authored skill puzzles: low-speed win, survive horn check, precision timing | 3D miniature **challenge podium** with animated opponent and arena preview, fixed orbit | Shared camera; optional training overlays |
| DRAFT | 6–10 encounters; choose mount, gear and route, gain build cards; a lost run ends | **3D model turntable** behind 2D cards; route/map in stylized panels | Shared camera; intensity increases with elites/boss |
| ENDLESS | Continuous opponents, scaling AI and terrain variety; highest streak | 3D arena **wide establishing shot** between waves; compact streak HUD | Shared camera, alternate lighting/weather only |
| EXHIBITION | Select any species, class override, arena, weather, AI for experiments/fun | **3D showroom turntable** side-by-side of mounted riders, player-adjustable slow orbit | Shared camera, optional spectator camera on replay |

**Camera in motion:** sideline 3/4 at slightly elevated height, mostly side-on so silhouettes and lance heights are clear. Smoothly tracks the midpoint between animals, briefly widens to keep both in frame, and never swings behind a rider during a live attack. Cinematic close-ups only after contact is resolved or in pre-pass sequences.

### 8.2 Campaign details

Progress through three regions with themed arenas and rising opponent mastery. The main courtyard is a **true 3D menu hub**, not free-roaming gameplay; camera at about 25–35 degrees above ground, fixed yaw with subtle background parallax. Click or tap destinations. Open stable to see rigged dinosaur idle animations on plinths. Story delivered through brief character encounters and tournament cards. Region bosses teach one counterplay rule each.

![3D campaign hub concept](Crownfall_v02_Visual_References/02_Campaign_Hub_3D_Diorama.png)

### 8.3 Challenge details

Three objective families: aiming (clean high/low strike), throttle (specific speed control), and species mastery (land or defend a beast contact). Challenges show an intro miniature 3D scene in the right-side preview, medals, and conditions. One arena loads when the player starts.

### 8.4 Draft details

Pick a registered weight class and one of three offered dinosaurs. Choose a starting lance, saddle, and one perk. Route selection presents opponent, terrain, and potential reward; choose one branch. Rewards: one of three upgrades. A run contains normal, elite, and boss encounters. Re-roll budget limited. To keep identity, do **not** switch registered division mid-run. Meta unlocks expand item availability but avoid persistent base power overwhelming early rivals.

![Draft and reward concept](Crownfall_v02_Visual_References/04_Draft_Reward_and_Loadout.png)

### 8.5 Endless and Exhibition details

Endless preserves build and mount and ramps opponent strategy, modifiers, and opponent variety rather than multiplying mass without limit. Exhibition permits classic match-ups and imbalance warnings; normal leaderboard submissions require legal divisions. Both return to a stable same-camera duel for matches.

## 9. Art bible: simple, original, truly 3D

### 9.1 Target art direction

A **Kingshot-like readability and friendliness** reference, not a direct copy. Crownfall's own visual brand is medieval sports pageantry plus dinosaur personality. Avoid semi-realistic scaly microtexture, hyper-detailed armor, photogrammetry, physically accurate injuries, and dark noisy scenes. Shapes should be broad, slightly beveled, and pleasantly exaggerated. Heads and eyes express personality. Large clear crest motifs tell teams apart. Saturated but controlled colors.

**Keywords:** toy-like 3D, sculpted rounded polygons, soft sunlight, simple shadows, chunky proportions, clean silhouette, appealing action, gentle exaggerated physics, brightly colored banners, friendly competition.

### 9.2 Character model guidance

- Dinosaurs: 3D deforming rigged meshes, not cubes. Species silhouette must read at thumbnail size: raptor bent legs/tail/elongated skull; triceratops frill and three horns; ankylosaur broad armored back and club; stegosaur plates; T. rex broad jaw and small arms.
- Riders: slightly chibi knights, around 2.5–3.5 heads tall, oversized helmets, simple gauntlets and capes, large emotions; physically sit on an actual saddle attached to dinosaur rig.
- Gear: 3D interchangeable lance tips, shaft and guard; saddle, banners, helmet crest, shields. Recolor with material palette swaps. Never make equipment obscure a dinosaur's species identity.
- Animation: separate skeletons for mount/rider, reusable cycles for 3 size-based rigs, species-specific additive head/tail techniques, exaggeration on impact. Animation retargeting reduces bespoke asset cost.

### 9.3 Rendering/materials

Base colors and gradients rather than detailed textures; 1–2 trim colors for faction heraldry, simple roughness, limited metallic armor highlights. One main directional light + baked ambient/SH where feasible. Small contact shadow under feet. Fake dust puffs, cartoon spark bursts, controlled bloom only on decisive hits. Fog low and never obscures an aim line. Use texture atlases and shared materials for mobile.

### 9.4 Target content budgets (provisional)

| Asset | Mobile LOD0 modeling target | Notes |
|---|---|---|
| Small mount | approximately 3k–8k triangles | Two or three LOD levels; silhouette first |
| Knight + saddle | approximately 1.5k–3k triangles | Clothing/armor mostly shared parts |
| Large mount | approximately 6k–12k triangles | Use same screen-pixel budget logic |
| Arena visible set | approximately 25k–60k triangles | Instanced crowds and modular props |
| Textures | 512–1024 for hero assets | Shared atlases, limited unique textures |

Numbers are starting production budgets and must be verified on actual target phones. Do not compromise dinosaur silhouettes just to hit an arbitrary triangle target.

### 9.5 Environment production kit

One modular castle wall kit, grandstand blocks, 3 banner variations, fences, tents, props, terrain material library, fake crowd cards/instanced low-detail characters, and lighting/weather presets. Four arenas should reuse most geometry but vary floor, background and sky. Budget production for character rigs and combat readability, not four entirely unrelated levels.

## 10. Exact camera and presentation specifications

### 10.1 Shared duel camera (all modes)

**Type:** real 3D orthographic or long-focal-length perspective after A/B test. **Composition:** camera stationed at side of paired lanes, with about 8–15° of downward pitch and about 5–12° horizontal yaw; framing shows full mounts, riders, lance points, and floor contact. **Behavior:** follow midpoint, keep projected action within central safe 70% width, avoid aggressive zoom during last 1 second before contact. **Hero scale:** player and rival each occupy roughly 20–30% of horizontal view at approach, automatically zooming out only when animals approach framing edges. **Collision close-up:** optional slow-motion after hit verdict; 3D orbit limited to 15–25° and reframe to avoid hiding horns or lance tip. **Mobile:** reserve screen corners for controls; contact occurs near center, UI must not cover heads.

### 10.2 Other views by mode/screen

| Screen / moment | Real-time 3D camera | Player controls / allowed motion |
|---|---|---|
| Main Menu | 3/4 hero view of idle knight and dinosaur; shallow dolly and slow parallax | Click/tap menu |
| Campaign Hub | Fixed high 3/4 isometric-like perspective looking down 25–35° into castle courtyard | Click/tap hotspots; no manual walking |
| Stable / Roster | 3D turntable at mount chest height, slight orbit and gentle zoom | Mouse drag or swipe rotates 3D model |
| Loadout / Draft | 3D character plinth on left/middle plus 2D choice cards on right; static cam with slow auto-rotation | Click/tap cards, drag rotate mannequin |
| Challenge Select | Diorama mock combat scene at 3/4 front angle; arena and target pose visible | Browse challenges; start loads shared camera |
| Endless Intermission | Wide elevated sweep across current arena and the incoming rival | Continue/upgrade; returns to shared camera |
| Exhibition Setup | Two 3D turntables front 3/4; selected mounts shown in comparable scale | Choose division, weather, gear, opponent |
| Win/Loss | Skippable slow-motion 3D sideline close-up; short orbit only after hit result | Skip, retry, next |

### 10.3 Camera rules that protect gameplay

Don't place the camera directly behind one dinosaur for live jousting. Do not use first-person aiming, manual free camera, depth-of-field that blurs combat, or fully rotating live cameras. A clear fixed-stage camera is more important than showing off the 3D technology. Depth exists through geometry, parallax, ground contact, shadows, rigging, and cinematic replays.

## 11. Platform UX, mobile landscape, and accessibility

### 11.1 Single design, responsive landscape

Primary layout designed at 1920x1080 logical reference (16:9), adapting down to 1280x720 and wider landscape phones (up to roughly 20:9). No portrait gameplay. Mobile uses responsive UI anchors and safe-area insets for notches/cutouts. The play field maintains a central contact-safe rectangle; decorative crowds/backgrounds crop first at wide aspect ratios.

### 11.2 Input zones

- **PC:** Space throttle, mouse hold/vertical drag/release for lance. Mouse wheel does not change the live camera. ESC pauses. Optional hold-to-aim preview can be remapped.
- **Mobile:** left lower corner a large throttle hold area; right lower corner a large vertical drag/aim region with a visible lance height indicator. Controls partially transparent and at least ~64–80 logical px equivalent minimum touch target, adjusted to actual mobile DPI.
- **Menu:** obvious large 3D hotspots backed by flat interface labels. No text tiny enough to require zooming. Pause and accessibility accessible outside thumb zones.
- **Feedback:** haptic pulse on hit where supported, subtle screen shake toggle, colorblind-friendly faction silhouettes/symbols, text size scaling, reduced-motion option, 30 FPS performance mode.

### 11.3 Onscreen information hierarchy

Top left player rider stability; top right opponent stability; center top pass counter and score; lower left speed gauge; lower right lance height/release feedback; short telegraph icon near enemy for active species technique. Camera must reveal both riders' upper bodies and most dinosaur silhouettes at all times. Avoid bloated HUDs or covering the jousting corridor.

## 12. Upgrades, economy, and progression

### 12.1 Three loadout slots in a run

**Lance** controls angle/speed/contact behavior (long reach, heavy impact, spring rebound). **Saddle/Armor** controls survival and recovery (brace, recoil absorption). **Perk** changes playstyle (low-profile specialist, last-second sprint, beast-contact focus). Dinosaurs have innate techniques that are never replaced by generic weapons. Items may modify trigger thresholds, not erase species identity.

| Sample item | Rules-level effect | Player-facing change |
|---|---|---|
| Spring Lance | Converts a fraction of clean hit impulse into extra unseat leverage; weaker on glance | Precise strikes pop riders upward |
| Reinforced Saddle | Reduces first major stagger per match; slightly lowers acceleration | Defensive, patient play |
| Quickstep Harness | Better deceleration and re-acceleration; less recoil protection | Responsive timing |
| Beast Handler | Shows the innate-contact window earlier; modest consistency boost | Learn dinosaur-specific technique |
| Splinter Lance | Breaks on strong clean contact for bonus score, cannot score again this pass | High commitment big hit |
| Underdog Crest | Bonus leverage versus taller **legal same-division** mount | Rewards low-profile matchups |

### 12.2 Campaign and Draft unlocks

Campaign unlocks regions, species, gear families, arenas, and challenges. Draft is replayable with randomized choices from the current legal unlock pool. Meta progression is breadth-first: unlocking more options, cosmetic crests, tournament history, and characters; minimal permanent combat power. Cosmetic purchases, if ever considered, must not introduce pay-to-win progression.

## 13. AI opponents and match readability

AI uses five readable approaches: **Sprinter** (late acceleration), **Sniper** (precise high lane), **Counterpuncher** (controlled speed, beast contact), **Brawler** (leans on body impact), and **Feinter** (variable throttle). Bosses combine two behaviors and one visible signature, but obey the same controls and collision rules. AI gets no forbidden mass, invisible shield, or hidden aim bonus. Telegraphed mistakes are acceptable at beginner level; expert opponents respond to player habits with fair cues.

**Match result overlay:** show `Lance: Clean / Glance / Miss`, `Beast: Horn Check / Bite / No Contact`, `Momentum: Low / Optimal / Overcommitted`, and `Stability: +/-`. This is a learning tool as well as feedback.

## 14. Implementation architecture

### 14.1 Gameplay modules

- `MatchFlow`: divisions, AI setup, duel-pass state machine, scoreboard, retries, win condition.
- `DinoMotion`: 1D guided lane locomotion in a 3D environment, per-species acceleration/traction curve, terrain modifier.
- `LanceAim`: input mapping, world-space angle constraints, aim line and commitment window.
- `ContactResolver`: physics proxy overlap/timing, lance contact quality, natural-weapon trigger, simultaneous contact, deterministic stability damage.
- `RiderStability`: accumulated strain, mount/rider knock-off threshold, saddle mitigation.
- `DinoInstinct`: per-species state machine, tells, attack window, cooldown/behavior.
- `ReactionDirector`: non-authoritative rider ragdoll, procedural recoil, lance fracture VFX, replay.
- `CameraDirector`: shared live camera, pre/post mode cameras, mobile-safe composition.
- `ContentData`: dinosaur, arena, equipment, AI, mode, difficulty, localization config.
- `Telemetry`: capture per-pass velocity, aim, contact pairs, stability delta, result and replay seed.

### 14.2 Determinism and tooling

Use a fixed 60 Hz gameplay step where feasible. Offline single-player scoring should be stable independent of render frame rate. Serialize a duel record `(seed, species, modifiers, input sample stream, contact data)` to reproduce suspicious matches. Build an in-editor collision gizmo to display valid horn/jaw/lance/saddle windows and a balance simulator to batch-check matchups.

### 14.3 PC and mobile performance targets

**PC:** 60 FPS target at 1080p on mainstream hardware. **Mobile:** stable 30 FPS baseline and optional 60 FPS on stronger devices at native landscape orientation; lower particle count/shadow quality/crowds as required. Hard cap active ragdolls and debris. Pool VFX, bake static environment lighting where practical, use LOD and occlusion culling only where safe, and profile on real low-to-mid-range Android hardware. No promise that every phone supports the same visual preset.

## 15. First playable MVP and success criteria

### 15.1 MVP content (one vertical slice)

| Element | MVP scope |
|---|---|
| Tech | Real-time 3D Unity URP or equivalent with PC + Android landscape build |
| Combat inputs | Throttle + lance drag/release; keyboard/mouse and touch |
| Dinosaurs | 3 Light mounts: Velociraptor, Protoceratops, Pachycephalosaurus |
| Innate attack | 1 distinct contextual natural weapon action per mount |
| Arenas | Royal Stone Court and Mud Pit |
| Opponents | 4 standard behaviors, 1 elite, 1 boss |
| Equipment | 8 items across lance, saddle, and perk |
| Modes | One 6-encounter mini Draft; basic Exhibition for testing |
| Physics | 3D hit zones, stable contact scoring, dismount ragdoll, short beast clash reactions |
| Cameras | Shared side camera, simple 3D roster turntable, Draft choice plinth |
| UI | PC + mobile landscape HUD, pause, result breakdown, quality toggle |

### 15.2 Playtest gates

1. New player can perform one legitimate clean lance hit after a short tutorial without reading a manual.
2. Players can consistently explain *why* they won or lost using visual feedback and results.
3. Every MVP species has a statistically meaningful tactical strength in at least one opponent/arena pairing and no automatic universal dominance.
4. Each arena causes observable throttle strategy changes in tester sessions.
5. Natural weapon contact is readable, avoidable/counterable, and does not feel like random damage.
6. Mobile control zones do not cover the impact moment in 16:9 or wide landscape.
7. Combat scoring matches offline replay logs despite inconsistent graphics FPS.
8. Users voluntarily replay matches after experiencing their first loss; a qualitative desirability gate rather than a made-up guaranteed retention metric.

### 15.3 Build roadmap (order, not dates)

**Milestone A – Graybox physics:** 3D capsule dinos; full throttle, aim, encounter, collision, outcome log; single flat arena. **Milestone B – Combat identity:** 3 original species meshes/rigs, natural weapon windows and telegraphs, impact reactions. **Milestone C – Mobile:** landscape HUD, touch input, camera safe areas, FPS profiling on actual device. **Milestone D – Content slice:** mud arena, 6-opponent Draft bracket, 8 items, boss, basic upgrade screens. **Milestone E – Feel/polish:** sound, spectator VFX, art kit, accessibility, telemetry, onboarding. **Milestone F – Expanded modes:** campaign hub and world structure, challenge packs, endless, exhibition options, remaining weight classes.

## 16. Risks, unresolved questions, and review checklist

### 16.1 Risks to watch

- **Automatic dinosaur attack feels unfair:** Require tells, cooldown, defined ranges, and a result breakdown.
- **Too much animation hides the joust:** Freeze live camera movement in final contact window; shorten beast reactions.
- **Simplified 3D makes all dinosaurs look alike:** Approve silhouette sheets before texturing or equipment art.
- **Big dinosaurs mismatch smaller mobile framing:** Strict class sizes; per-class framing presets; avoid cross-division normal play.
- **Mobile touch imprecision:** Adjustable drag sensitivity, forgiving preview, clearly visible aim lane.
- **Feature sprawl:** Keep Campaign hub as diorama; launch with Draft + Exhibition mechanics first.

### 16.2 Decisions for review

1. Is a joust won immediately on any clean knock-off, or should the player still complete a three-pass set for tournament scoring? **Recommendation:** immediate knock-off wins.
2. Should a successful beast attack count as an independent point even when the lance misses? **Recommendation:** yes, but lower ceiling than a perfect lance strike, and only on legitimate contact.
3. Should `Beast Stance` appear after MVP? **Recommendation:** only if playtesting shows insufficient meaningful choice.
4. Do you prefer orthographic broadcast camera or high-focal-length perspective? **Recommendation:** benchmark both for large dinosaur size and mobile clarity before locking.
5. Do we want a tiny direct-control campaign hub? **Recommendation:** no, stay with a static 3D diorama to preserve scope.
6. Do we ship all divisions in version 1? **Recommendation:** first ship one polished division, expand only after combat validation.

## 17. Visual reference inventory

These images are **AI-generated mood and UI concepts**, not proof of working gameplay or ready-made 3D assets. They illustrate character proportions, palette, camera, interface, and screen composition. Some text in the generated panels is decorative and is superseded by the specifications in this document.

| Ref | Intended use | What to reproduce / avoid |
|---|---|---|
| 01 Duel | Core game visual | Full 3D animals, stable side-on readable duel, bold simple HUD; adjust oversized buttons on PC |
| 02 Hub | Campaign camera | 3D diorama courtyard, clear clickable buildings, no free-roam requirement |
| 03 Roster | Species look | Recognizable shapes and simple color coding, not exact anatomy or inaccurate weight assignments |
| 04 Draft | Roguelite reward | Short 3D plinth scene plus large readable upgrade cards |
| 05 Natural attacks | Creature agency | Different visible body moves, no extra attack button |
| 06 Arenas | Terrain language | Distinct ground and lighting with consistent modular castle kit |

**END — v0.2 REVIEW DRAFT**
