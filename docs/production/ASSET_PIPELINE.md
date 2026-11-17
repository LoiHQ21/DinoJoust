# Asset generation and integration pipeline (Blender + AI-assisted concepts)

## Why a pipeline is essential

One AI-generated image is not a reusable animated 3D game object. Screenshots/style boards can guide shapes, but cannot replace valid UVs, skeletons, skin weights, clean normals, animation clips, collider proxies and platform-friendly meshes. Use concept generation to accelerate decisions, then standardize production artifacts.

## Stage 0: approve shapes from the latest references

- Use `assets/concepts/current/` as the consistent target for *feel*, not exact topology.
- Choose one chibi knight in the new faceted style and two contrasting dinosaur rigs (biped raptor, quadruped ceratopsian).
- Produce **orthographic front/side/back + 3/4** concept views for rider, dinosaur, saddle and lance separately. Check anatomical consistency.
- Develop an original palette, heraldry and design motifs. Do not copy named characters or logos from other games.

## Stage 1: concept → blockout

- Model simple Blender forms to the right scale and axes. For AI image-to-3D, treat output as reference/blockout; remove non-manifold pieces and artifacts.
- Standardize unit scale, world-forward, up axis, origin, foot plane, saddle mount point and lance attachment.
- Ensure silhouette survives a low-res chase camera screenshot without detailed textures.

## Stage 2: topology, UV and materials

- Retopologize for deformation at legs, jaw, neck, tail, shoulders and saddle contact; build low-mid-poly meshes.
- Use palette masks, shared materials, gradient texture atlas, AO, minimal detail maps.
- Store source `.blend` under a game-engine AssetSource directory *when actual assets exist*; export `.fbx` or `.glb` with controlled settings and reference version numbers.
- Variant gear should use shared attachment sockets and color/material instances.

## Stage 3: rigging and animation

- Knight shared skeleton with upper-body lean, weapon aim, recoil, dismount and ragdoll joint mapping.
- Biped dino: root, hips, legs, spine/neck, head/jaw, tail chain and saddle socket.
- Quadruped ceratopsian: root, 4 legs, body, frill/head/horns, tail and saddle socket.
- Test walk/charge/brace/snap/impact/stumble/idles and anatomical poses; isolate unique signatures from shared locomotion.
- Separate authoritative collision hitboxes from decorative ragdoll physics bodies. Detached helm/armor visual objects must have predictable pooling/cleanup.

## Stage 4: import validation

- Actual 3D file imports and animates in selected engine; no pink/missing materials, swapped axis, duplicated skinned meshes, broken constraints or foot sliding.
- Can swap 2 rider outfits and recolor faction without rebuilding animation.
- Lance aim remains aligned with simulated hit proxy in a moving chase-camera screenshot.
- Run target-phone performance test before mass producing species.

## Suggested naming

```text
CHR_Rider_Base_A
DNO_Raptor_Base_A
DNO_Proto_Base_A
GEAR_Lance_Standard_A
GEAR_Helmet_FactionRed_A
SCK_RiderSeat
SCK_LancePivot
COL_RiderTorso
COL_BeastHead
ANIM_Dino_Charge
ANIM_Dino_Brace
ANIM_Dino_Snap
```

## Asset order for the first playable

1. One knight; one biped raptor; one quadruped Protoceratops; basic lance, saddle and helmet.
2. One ground lane, rail, castle wall, banner and simplified spectator crowd.
3. Charge, lance aim, beast telegraph/attack, brace, stagger and dismount.
4. Impact starburst, dust, broken lance/helm props.
5. UI components for speed, aim, pass, rider stability and beast status.
6. Only after successful integrated gameplay: extra species, new arena themes and cosmetics.

## AI/tool considerations

Different services and tools have different commercial-use terms and output quality. Verify tool license and any reference-image rights before publishing. Suggested division of labor: image tools for 2D style exploration and turnarounds, Blender for controlled topology/rigs and repeatable exports, AI-to-3D as optional blockout source, engine for final lighting/shaders and profiling.

**Do not push third-party style references from social media/game screenshots to a public repo without a rights review.** This handoff includes only our generated images and a note about the external screenshots.
