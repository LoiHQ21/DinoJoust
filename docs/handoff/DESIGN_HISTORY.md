# Short conversation / decision timeline

The content is a **structured summary**, not a full transcript. The archived GDD and current art are primary files for implementation.

1. **Original pitch (November 2026):** Medieval knights ride dinosaurs in jousts; control dinosaur speed and lance angle/timing; enjoy the fantasy of a nimble dinosaur defeating heavier opponents.
2. **Modernization options:** brainstormed Crownfall roguelite, physics party fighter, precision boss rush, mind-game duel, racing joust, creature-management stable. Crownfall selected as the main direction; boss puzzle and comic physics elements were kept as influences.
3. **Sport rules added:** Weight/size divisions, meaningful terrain, distinct species stats/advantages, simple controls, Campaign/Challenge/Draft/Endless; avoid hidden guaranteed-win mechanics; fun readable physics.
4. **First GDD request:** True 3D, Windows + phone **landscape**, camera specification by mode, several image concepts. This became v0.2 in the supplied artifact set.
5. **First stylization change:** Reduced earlier somewhat realistic presentation to easier-to-author original rounded, bright Kingshot-inspired art. Dinosaur shapes must remain dinosaur-like, not cuboids.
6. **Dinosaur agency:** Knights and dinosaurs both influence joust. Main design: species-specific natural contacts, contextual triggers, temperament; throttle conditions control timing, no extra bite button. Contact destabilizes/opposes riders and complements lance strikes. Example Raptor versus Protoceratops three-pass fight.
7. **Animation concept:** 9-frame GIF showing joust, raptor/head contact, lance hit and comic dismount; conceptual, not an engine clip.
8. **New unapproved creative thought:** Ragdoll physics and detachable heads, limbs, armor and weapons; hold as idea backlog.
9. **Camera change:** User provided portrait mobile jousting screenshots and requested the over-the-rider forward chase viewpoint, focusing speed and impact point. This **supersedes** old live side camera. Adapt to landscape and preserve post-impact cinematic alternate angles.
10. **Latest art change:** User supplied a fantasy hero roster ad and asked for more faceted angular chibi-anime 3D rather than Kingshot. Four new concept images generated: charge duel, impact, hub, roster.
11. **Current handoff (2026-11-18):** New canonical v0.3 Markdown GDD, Codex instructions, organized current/archived images and implementation plan for GitHub.

## Known design contradictions deliberately resolved

- **Live view:** older v0.2 says sideline camera; current **chase** view wins.
- **Art:** older v0.2 says Kingshot-like round toys; current **faceted chibi-anime 3D** wins.
- **Beast scoring:** early v0.2 considered points for beast contact; latest combat explanation preferred *stability effects only*. Treat that as **PROPOSED**, to validate.
- **Guaranteed victories:** user asked whether always having a chance is wise. Recommended *skill-based viable counters*, not guaranteed win/rubber banding.
- **Detachment:** user added it to idea backlog, not final design; do not mark limbs/head detachable as MVP requirement.
