# Six-character art study

Status: **PROPOSED art prototypes**, created on branch `art/faceted-knights-and-dinosaurs` at the owner's request. These are real mesh assets with skeletons and animation clips. They do not constitute a playable engine project or approval of production art.

## Reading the direction

The decision register D010–D012 and current art bible take precedence over the archive. The current roster reference combines large knight heads, angular armor, expressive dinosaur heads, strong faction colors, and simple readable materials. The practical target is a faceted fantasy character that still reads from the rear chase camera. Rounded toy shading, voxel anatomy, realistic scales, and ornamental noise work against that target.

The reference image has more elaborate faces and hand-painted shading than these first meshes. This study establishes the reusable geometry, shared color system, and animation/export workflow; it does not claim a final match to every detail of the painting.

## Production route selected

| Route | Assessment for this task |
|---|---|
| Adapt a commercially reusable rigged mesh in Blender | Selected. Existing anatomy, topology and animation provide a concrete base; proportions, gear and palette can be revised reproducibly. |
| Image generation | Useful for new shape exploration, but the repo already has a clear visual direction. Another concept image would not supply the requested reusable 3D assets. |
| Image-to-3D generation | Potential blockout route for a missing species. Would still need topology, rigging, UV and animation checks, so it offers less benefit here than the available rigged sources. No service used or subscription required. |
| Entirely new hand-authored meshes | Best control for a final hero pass, but unnecessary for establishing this six-model art study when reusable sources exist. |

The creator's [Animated Dinosaur Pack](https://quaternius.com/packs/animateddinosaurs.html) and [Animated Knight Pack](https://quaternius.com/packs/knightcharacter.html) both explicitly list **CC0** and personal/commercial use. Downloads came from the creator's [dinosaur itch.io page](https://quaternius.itch.io/animated-lowpoly-dinosaurs) and [knight itch.io page](https://quaternius.itch.io/lowpoly-animated-knight). The website's Google Drive downloads returned quota-exceeded responses, so the creator's alternative distribution was used. The [CC0 deed](https://creativecommons.org/publicdomain/zero/1.0/) permits modification and commercial use. Pack-specific evidence and hashes are in `assets/third_party/quaternius/`; no third-party screenshots are used as textures.

## The six designs

| Asset | Design treatment |
|---|---|
| Azure Lancer | Enlarged chibi head; winged, plumed helmet; blue enamel, pale steel, gold edging; lance and shield. |
| Crimson Champion | Closed angular helmet; tall swept plume; crimson enamel, warm gold, dark cape; lance and shield. |
| Jade Warden | Open helm with laurel crest; jade enamel, steel and gold; eye geometry; lance and shield. |
| Velociraptor | Lightweight biped, long balancing tail, enlarged head, blue/cream palette, temple feathers, saddle. |
| Triceratops | Broad quadruped, three horns and frill, jade/ivory palette, restrained badge and saddle. |
| Parasaurolophus | Distinct swept cranial crest, biped posture, crimson/cream/gold palette and saddle. |

Species follow the available reusable meshes and span the existing Light, Heavy and Middle roster concepts. **This is not a replacement for the proposed Light MVP set** (Velociraptor, Protoceratops, Pachycephalosaurus), a new matchmaking rule, or evidence that these differently sized mounts should face each other in ordinary matches. Existing balance data and locked decisions are unchanged.

## Adaptation details

- Three knight variants share the same 31-bone source skeleton. Head geometry is enlarged around the head bone, rather than changing skeleton rest lengths; new gear is weighted to the existing joints.
- Each dinosaur retains its own source mesh, skeleton, and six animation actions. Head enlargement, eyes, brows, saddlecloth, seat, straps and stirrups are authored in armature rest space.
- A shared 512×512 color atlas replaces legacy material setups. Palette UVs intentionally sample flat color cells; these are not paint-ready, unique UV islands. A final gradient/AO texture pass remains open.
- Two skinned meshes per character separate body and equipment. The gear mesh retains vertex groups, so rigid plates follow their joints. Accessories can be separated in Blender by connected components; they are not a finished runtime equipment system.
- `SCK_RiderSeat` exists on riders and mounts. Knights also expose `SCK_LancePivot`, `SCK_Shield`, and `SCK_Helmet`. Mounts expose `SCK_BeastContact`. Sockets are visual attachment proposals, not authoritative collision hitboxes.
- Blender uses meters, Z up, −Y forward. GLB converts to Y up, +Z forward. The uniform scale remains on the rig, and is included in the exports. Do not apply it to only the body or only the skeleton.
- Generic source death/jump/attack/roll clips remain available for evaluation. They are not approved joust actions, and equipped lance/shield motion during those clips needs art review. No gore or new gameplay is introduced.

## Review and handoff

Start with [the asset README](../../assets/roster/README.md) or the local `assets/roster/index.html` gallery. Hero/front/side/back images are renders of the actual meshes. Editable sources and self-contained GLBs are separate from the untouched third-party files. Rebuild and validation commands are documented beside the assets.

**Verified** results are recorded in `build_report.json`, `validation.json`, and `gltf_validation.json`. These checks cover file structure, embedded materials, weights, animation sampling, and round-trip import, not production suitability.

**Unverified:** seated rider pose/IK, retargeting between mount families, deformation quality over every frame, gear intersections during all actions, painted gradients, optimized LODs, chase-view readability with HUD, and target-device cost. Capes are rigid panels, not simulated cloth. Scale is an art proposal, not biological scale or approved gameplay balance.

**Environment-blocked:** in-engine gameplay and phone profiling, because this repository has no chosen/implemented engine project or attached target device. Next useful gate: fit the Azure rider to the raptor, author a seated/aim pose, and review a 1280×720 chase-view scene in the selected engine.
