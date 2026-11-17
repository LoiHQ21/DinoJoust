# Crownfall art roster

Six **rigged 3D art prototypes** adapted from Quaternius CC0 base meshes. Three distinct knight variants share a skeleton; the dinosaurs are Velociraptor, Triceratops, and Parasaurolophus. These are editable models with animation, not AI-generated concept illustrations.

Open [the offline gallery](index.html) in a browser, or open an `AssetSource/*.blend` file in Blender 4.3.2+. Each asset has a self-contained GLB and hero/front/side/back mesh renders. In Blender, switch to Material Preview to see the packed palette, and use the Action Editor to select a clip. The files open at frame 0 of Idle.

| Asset / GLB | Source triangles | Bones | Source clips | Files |
|---|---:|---:|---:|---|
| [Azure Lancer](glb/CHR_Knight_Azure_A.glb) | 1,986 | 31 | 12 | [Source](AssetSource/CHR_Knight_Azure_A.blend) · [Preview](previews/CHR_Knight_Azure_A_hero.png) |
| [Crimson Champion](glb/CHR_Knight_Crimson_A.glb) | 2,001 | 31 | 12 | [Source](AssetSource/CHR_Knight_Crimson_A.blend) · [Preview](previews/CHR_Knight_Crimson_A_hero.png) |
| [Jade Warden](glb/CHR_Knight_Jade_A.glb) | 2,585 | 31 | 12 | [Source](AssetSource/CHR_Knight_Jade_A.blend) · [Preview](previews/CHR_Knight_Jade_A_hero.png) |
| [Velociraptor](glb/DNO_Velociraptor_A.glb) | 2,316 | 29 | 6 | [Source](AssetSource/DNO_Velociraptor_A.blend) · [Preview](previews/DNO_Velociraptor_A_hero.png) |
| [Triceratops](glb/DNO_Triceratops_A.glb) | 2,325 | 29 | 6 | [Source](AssetSource/DNO_Triceratops_A.blend) · [Preview](previews/DNO_Triceratops_A_hero.png) |
| [Parasaurolophus](glb/DNO_Parasaurolophus_A.glb) | 2,398 | 29 | 6 | [Source](AssetSource/DNO_Parasaurolophus_A.blend) · [Preview](previews/DNO_Parasaurolophus_A_hero.png) |

“Source triangles” counts triangulated mesh faces before glTF export. Exported triangle counts appear in `validation.json`; flat shading and UV seams may duplicate vertices. All six assets use the same 512×512 palette atlas, embedded in each GLB and packed into each Blender file. Each character has two skinned meshes: body and equipment.

## Coordinate and attachment contract

- Meters; Blender Z up, −Y forward. GLB Y up, +Z forward. Uniform rig scale is intentional and exported; import the entire rig and its meshes together.
- Feet are placed at the ground in the frame-0 idle pose. Root origin is near the feet, not at the model's bounding-box center. Animation may subsequently lift feet or jump.
- `SCK_RiderSeat`: mount attachment proposal, or rider pelvis alignment reference. Fit a seated pose before attaching; snapping a standing rider's socket is insufficient.
- Knights: `SCK_LancePivot`, `SCK_Shield`, `SCK_Helmet`. Mounts: `SCK_BeastContact`. These are visual sockets; gameplay collision/aim integration has not been built.
- Knight skeletons are shared; mount skeletons retain species-specific rest poses. No cross-species retargeting guarantee.
- Source locomotion/reaction clips are retained, including generic combat/death clips. They require equipment-intersection and gameplay-specific animation review. Capes and saddlecloth are rigid weighted panels; no cloth physics or ragdoll is included.
- Palette UVs sample color cells. Unique hand-painting UVs, gradient/AO baking, LODs, seated IK and runtime equipment swapping remain production tasks.

## Rebuild and verify

From the repository root:

```sh
blender -b -t 4 --python tools/build_art_roster.py
blender -b -t 4 --python tools/validate_art_roster.py
python tools/build_art_catalog.py
python tools/validate_data.py
```

The build uses only the vendored source files and Blender. It regenerates six sources, six GLBs, 24 PNG previews and `build_report.json`. For geometry/export work without rendering, append `-- --no-render`. To rebuild one asset, append `-- --only CHR_Knight_Jade_A`; this writes a separate per-asset report, which should be merged into `build_report.json` before refreshing the catalog. No engine or paid generator is required.

Optional independent Khronos validator (install outside the repository):

```sh
npm install --prefix /tmp/crownfall-validation --cache /tmp/crownfall-npm-cache gltf-validator@2.0.0-dev.3.10 --no-audit --no-fund
NODE_PATH=/tmp/crownfall-validation/node_modules node tools/validate_art_gltf.cjs
```

`validation.json` records actual round-trip GLB imports, normalized skin weights, embedded textures, sockets, and finite deformation at five sample times in every imported clip. `gltf_validation.json` records independent format checks. Blender's exporter emits `NODE_SKINNED_MESH_NON_ROOT` warnings for the body and equipment nodes parented under their rig; the skeleton carries the intended transforms. These warnings do not mean missing weights, but import the full character hierarchy and test transforms in the chosen engine.

**Verified:** use the committed reports for exact counts and checks. **Unverified:** full-frame animation/art quality, seated riders, aiming, contact motion, chase view with HUD, target-device performance. **Environment-blocked:** in-engine gameplay validation; there is no implemented/selected engine project here.

## Art direction and provenance

Read [the art study](../../docs/production/ART_ROSTER_STUDY.md) for analysis, route selection and limitations. [The source record](../third_party/quaternius/README.md) documents the commercially reusable CC0 bases, download pages and hashes. Generated modifications are project work; no repository-wide license is selected by this study. This art set does not alter the proposed lightweight MVP roster or approve cross-division matches.
