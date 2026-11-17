"""Refresh the offline gallery, README and checksums after building the roster."""
import hashlib
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/roster'
report = json.loads((OUT/'build_report.json').read_text())
assets = report['assets']
cards = []
rows = []
for asset in assets:
    key, name = asset['id'], asset['name']
    cards.append(f'''<article>
      <a href="previews/{key}_hero.png"><img class="hero" src="previews/{key}_hero.png" alt="Three-quarter mesh render of {html.escape(name)}" width="1000" height="1000"></a>
      <div class="card-body"><h2>{html.escape(name)}</h2><p class="stats">{asset['triangles']:,} source triangles · {asset['bones']} bones · {len(asset['actions'])} clips</p>
      <div class="views">{''.join(f'<a href="previews/{key}_{v}.png">{v.title()}</a>' for v in ['front','side','back'])}</div>
      <div class="downloads"><a href="glb/{key}.glb" download>Download GLB ↓</a><a href="AssetSource/{key}.blend" download>Blender source ↓</a></div></div>
    </article>''')
    rows.append(f"| [{name}](glb/{key}.glb) | {asset['triangles']:,} | {asset['bones']} | {len(asset['actions'])} | [Source](AssetSource/{key}.blend) · [Preview](previews/{key}_hero.png) |")

(OUT/'index.html').write_text('''<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Crownfall · Six-character art study</title>
<style>
:root{color-scheme:dark;font-family:system-ui,sans-serif;background:#111b29;color:#e7e8df}*{box-sizing:border-box}body{margin:0}main{max-width:1400px;margin:auto;padding:56px 30px}header{max-width:900px;margin-bottom:34px}.eyebrow{font-size:12px;letter-spacing:.2em;color:#dfb773;text-transform:uppercase}h1{font-family:Georgia,serif;font-weight:400;font-size:clamp(34px,5vw,64px);margin:16px 0}header p{line-height:1.65;color:#bbc4cf;font-size:16px}a{color:#edc683;text-underline-offset:4px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:24px}article{background:#1c2939;border:1px solid #344253;border-radius:12px;overflow:hidden}.hero{display:block;width:100%;height:auto}.card-body{padding:22px}h2{margin:0 0 10px;font-size:23px;font-weight:500}.stats{font-size:12px;color:#b6c1ce}.views,.downloads{display:flex;gap:20px;flex-wrap:wrap;font-size:13px}.views{margin:20px 0}.downloads{padding-top:18px;border-top:1px solid #3a4654}.note{padding:22px 0;color:#bbc4cf;line-height:1.7;font-size:14px}footer{margin-top:26px;border-top:1px solid #344253;padding-top:22px;font-size:13px;color:#a4b3c3}@media(max-width:1000px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:620px){.grid{grid-template-columns:1fr}main{padding:30px 18px}}
</style><main><header><div class="eyebrow">Jurassic Joust: Crownfall / Art study 01</div>
<h1>Knights of the old world.</h1><p>Three knight variants. Three dinosaur silhouettes. A faceted fantasy roster with shared colors, original equipment, and reusable animated meshes.</p>
<p>These images are rendered from the downloadable models. Open the GLBs or Blender sources to inspect geometry and animation. Front, side, and rear links open full-size orthographic views.</p></header><section class="grid">'''+''.join(cards)+'''</section>
<p class="note"><strong>Art prototypes.</strong> Riding poses, lance aiming, full animation art review, engine integration and phone performance are pending. The three species span different proposed divisions; this study does not change the lightweight MVP roster.</p>
<footer>Base meshes and animations by <a href="https://quaternius.com/">Quaternius</a> (CC0), adapted for Crownfall. <a href="../third_party/quaternius/README.md">Provenance</a> · <a href="../../docs/production/ART_ROSTER_STUDY.md">Art direction and method</a> · <a href="README.md">Technical handoff</a>. Offline gallery; no scripts, tracking or external asset requests.</footer></main></html>''')

(OUT/'README.md').write_text('''# Crownfall art roster

Six **rigged 3D art prototypes** adapted from Quaternius CC0 base meshes. Three distinct knight variants share a skeleton; the dinosaurs are Velociraptor, Triceratops, and Parasaurolophus. These are editable models with animation, not AI-generated concept illustrations.

Open [the offline gallery](index.html) in a browser, or open an `AssetSource/*.blend` file in Blender 4.3.2+. Each asset has a self-contained GLB and hero/front/side/back mesh renders. In Blender, switch to Material Preview to see the packed palette, and use the Action Editor to select a clip. The files open at frame 0 of Idle.

| Asset / GLB | Source triangles | Bones | Source clips | Files |
|---|---:|---:|---:|---|
'''+ '\n'.join(rows)+'''

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
''')

manifest={'status':'ART_PROTOTYPE','notice':'Actual rigged meshes and their rendered previews; not engine validated.',
          'source_record':'../third_party/quaternius/sources.json','files':[]}
for folder in ['AssetSource','glb','previews','textures']:
    for p in sorted((OUT/folder).iterdir()):
        if p.suffix in {'.blend','.glb','.png'}:
            data=p.read_bytes()
            manifest['files'].append({'path':p.relative_to(OUT).as_posix(),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Updated gallery, README and',len(manifest['files']),'artifact hashes')
