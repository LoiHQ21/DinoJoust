# Duel combat system: implementation reference

Full game context: [`GDD_v0.3.md`](GDD_v0.3.md). This document specifies the intended causal order and diagnostic interface; numeric balance is illustrative.

## The central proposition

**Knight attacks create the definitive point/unseat strike; the dinosaur creates or removes stability and aim opportunities.** The rider and mount act inside a single collision encounter, not separate minigames. Dinosaur actions can also reduce incoming damage or punish overcommitted charge profiles. Natural weapons should not make the lance irrelevant.

## Standard duel lifecycle (proposed)

`Preview -> Ready -> Charge -> LanceCommit -> ContactWindow -> Resolve -> FollowThrough -> PassSummary -> [NextPass | MatchResult]`.

- **Preview:** announce dinosaur, terrain, signature tell. AI is bound by the same contact rules as player.
- **Charge:** throttle drives along a guided lane; launch state determines acceleration, traction, recoil exposure, and which dinosaur technique can happen.
- **LanceCommit:** mouse/touch release locks the height/angle and begins a short wind-up. A miss must be real.
- **ContactWindow:** resolve rider lance and beast contact at fixed timesteps in a single coherent world-space sequence; if both contacts overlap, both contribute to outcome.
- **Resolve:** stability deltas, score grade, dismount flag; order independent from replay cameras/ragdoll impulses.
- **FollowThrough:** play the short horn/shove/snap reaction and airborne gear/rider effects that correspond to the actual result.
- **Summary:** show `lance_grade`, `dino_action`, `momentum_quality`, `terrain_effect`, `stability_delta`, and `reason`, not just a victory banner.

## Inputs

- Hold/release Space / hold/release mobile left throttle area: accelerate/coast.
- Mouse drag + release / mobile right vertical drag + release: change lance angle then commit.
- No active movement stick or mandatory dinosaur attack input.
- Optional pre-match roster / gear choices are not part of live duel control count.

## Suggested stat model (not final)

- Mount: `mass_index`, `saddle_height`, `max_speed`, `accel_curve`, `traction`, `balance`, `recoil_resistance`, `body_contact_window`, `temperament`.
- Rider: `seat_stability`, `lance_angle`, `commit_time`, `rider_target_volume`, `shield_coverage`, `gear`.
- Arena: `surface_grip_multiplier`, `accel_modifier`, `recoil_modifier`, optional wind/rain visibility cue.
- AI: transparent acceleration and aiming behavior with visible telegraph stages.

## Candidate resolution mechanics (formula is a starting abstraction)

```text
closingSpeed = dot(playerVelocity - enemyVelocity, joustAxis)
impulseProxy = reducedMass(playerMass, enemyMass) * abs(closingSpeed) * alignmentFactor
lanceQuality = grade(lanceTipContact, targetZone, commitTiming, leverage)
beastEffect = contextualAttack(geometry, speedWindow, telegraph, armor, counter)
stabilityChange = K_lance * lanceQuality * impulseProxy
                + beastEffect.destabilize
                - saddleDefense - beastEffect.defend
unseated = stabilityRemaining <= 0
```

All quantities need normalization and clamping by division; a raw Newtonian impulse should not randomly overpower the scoring rules. Use consistent collision proxy coordinate systems and scripted tests for simultaneous contact. Never let particle effects or ragdoll joint instability change the already-resolved winner.

## Dino-on-dino behavior architecture

Each species should have **one main readable contextual action per pass** in the MVP. Signature requires: (a) pre-contact tell, (b) valid speed range, (c) active contact geometry/time window, (d) reproducible primary effect, (e) counterplay, (f) follow-through animation.

| Mount | Behavior | Trigger idea | Knight benefit | Counter |
|---|---|---|---|---|
| Raptor | Predator Snap | Controlled approach, head/shoulder close pass | Brief enemy wobble / rider target shifts | Braced frill / high closing speed / greater gap |
| Protoceratops | Frill Guard / Nose Nudge | Low-to-medium braced contact | Reduces own lance-stability loss; nudges rival | High precision lance angle, avoid head-on contact |
| Pachycephalosaurus | Dome Headbutt | Tight front contact window | Short destabilization if alignment right | Sidestep corridor mismatch / long horns |
| Carnotaurus (later) | Shoulder Rush | Late fast charge | Adds force to rider strike | Overcommits, poor recovery |
| Triceratops (later) | Horn Check | Controlled front contact | Reduces enemy aim/stability | Low-profile species / avoid horn zone |
| Ankylosaurus (later) | Tail Rebuttal | Only after near pass | Punishes reckless opponent | Stay outside tail arc |

### Two actor outcomes

- **Lance clean + dino clean:** powerful combined knock-off is possible. Both events appear in result breakdown.
- **Lance clean + dino miss:** still a valid strong rider attack.
- **Lance miss + dino clean:** can reduce enemy stability but should not automatically score lance points under the current PROPOSED rules.
- **Both lance miss + both dino miss:** legitimate no-hit pass; allow rebound or scoring stalemate.
- **Simultaneous knock-offs:** results may tie; document a fair tie-breaker, do not randomly choose a winner.

## Camera-collision conflict to prototype early

The **LOCKED** rear-chase camera can hide close dinosaur interactions behind the player mount, opposing frill or lance. Solutions to test: modest over-shoulder offset, contact-pair anticipation anim, highlights at impact corridor, clear event overlay, and **post-resolution** side replay. Do not revert to live side camera without owner approval.

## Scoring and win conditions (proposed only)

- Standard match: up to three passes; unseat opponent = immediate win.
- Clean lance = 2 points, glancing lance = 1 point, miss = 0.
- Beast attacks = stability/position effect but no automatic separate points in standard joust (supersedes the older v0.2 suggestion until owner decides).
- If neither rider falls after three passes, highest lance points wins; tie may require sudden death/stability comparison.
- Normal matches should always have a viable winning strategy for a skilled player, **not** secretly manipulate outcomes.

## Impact presentation and physics

After verdict: short hit-stop, camera emphasis, ragdoll conversion for rider, lance bend/splinter, bouncing helmets/shields, dust, dinosaur recoil and comedy stumble. For the first prototype only rider ragdoll + helmet/lance prop detach is sufficient; head/limb detach belongs to brainstorm backlog, not core combat.

## Telemetry to log on every pass

`match_seed`, `frame_index`, `player_dino`, `enemy_dino`, `arena`, `velocity`, `lance_angle`, `commit_frame`, `lance_contact_grade`, `dino_action`, `dino_contact`, `stability_before_after`, `score_awarded`, `unseat_result`, `contact_debug_reason`, `rng_visual_seed`.

## Worked three-pass showcase (narrative, not verified engine simulation)

1. **Pass 1:** Raptor sprints into a Protoceratops brace; lance glances off. Defender scores cleaner lance and raptor rider loses stability. Lesson: maximum throttle is not always better.
2. **Pass 2:** Raptor approaches at controlled speed, which enables *Predator Snap* on the opposing harness; rival tilts, creating a cleaner target. Player lands perfect lance. Both actions influence same outcome; no bite button.
3. **Pass 3:** Defender abandons brace to sprint. Player reads tell, adjusts speed, snaps during crossing, and lands a precise lance into unstable rider. Defender is unseated, helmet/splinter fragments fly during replay, dinosaur continues running safely.

This is a **desired player experience** rather than proof that tuning works. It must be validated with engine tests.
