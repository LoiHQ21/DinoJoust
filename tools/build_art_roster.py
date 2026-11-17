"""Build Crownfall's six art-study assets from the vendored CC0 sources.

Run: blender -b -t 4 --python tools/build_art_roster.py
Blender 4.3.2. No downloads, addons, paid services, or engine required.
"""
import bpy
import json
import math
import sys
from pathlib import Path
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/third_party/quaternius'
OUT = ROOT / 'assets/roster'
for folder in ['AssetSource', 'glb', 'previews', 'textures']:
    (OUT / folder).mkdir(parents=True, exist_ok=True)

COLORS = {
    'ivory': 'F5E4BE', 'gold': 'DCA84B', 'gold_light': 'FFE2A0',
    'steel': 'B8D0DE', 'steel_light': 'EDF3EE', 'ink': '202B41',
    'leather': '674737', 'leather_light': 'A87B53', 'skin': 'F0B58D',
    'white': 'FFFAE8', 'blue': '326CAC', 'blue_dark': '25436D',
    'blue_light': '6DA9D1', 'red': 'B93F48', 'red_dark': '672E40',
    'red_light': 'E66F51', 'jade': '358676', 'jade_dark': '244F50',
    'jade_light': '77B29B', 'eye': 'F5C64E',
}
FACTIONS = [
    ('CHR_Knight_Azure_A', 'Azure Lancer', 'blue', 'Helmet1', 0),
    ('CHR_Knight_Crimson_A', 'Crimson Champion', 'red', 'Helmet3', 1),
    ('CHR_Knight_Jade_A', 'Jade Warden', 'jade', 'Helmet2', 2),
]
DINOS = [
    ('DNO_Velociraptor_A', 'Velociraptor', 'blue', .30, (0, -.65, 4.25)),
    ('DNO_Triceratops_A', 'Triceratops', 'jade', .43, (0, .15, 4.30)),
    ('DNO_Parasaurolophus_A', 'Parasaurolophus', 'red', .34, (0, -.65, 4.30)),
]


def linear(hex_color):
    values = [int(hex_color[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c < .04045 else ((c + .055) / 1.055) ** 2.4 for c in values) + (1,)


def material(name):
    key = 'CF_' + name
    m = bpy.data.materials.get(key)
    if m:
        return m
    m = bpy.data.materials.new(key)
    m.diffuse_color = linear(COLORS[name])
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = m.diffuse_color
    p.inputs['Roughness'].default_value = .72
    return m


def activate(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def load_base(name):
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE / (name + '.blend')), load_ui=False)
    if bpy.context.object and bpy.context.object.mode != 'OBJECT':
        bpy.ops.object.mode_set(mode='OBJECT')
    scene = bpy.context.scene
    for o in list(scene.objects):
        if o.type not in {'ARMATURE', 'MESH'}:
            bpy.data.objects.remove(o, do_unlink=True)
    rig = next(o for o in scene.objects if o.type == 'ARMATURE')
    rig.data.pose_position = 'REST'
    rig.animation_data.action = None
    for track in list(rig.animation_data.nla_tracks):
        rig.animation_data.nla_tracks.remove(track)
    for pb in rig.pose.bones:
        pb.matrix_basis = Matrix.Identity(4)
    bpy.context.view_layer.update()
    for ob in [o for o in scene.objects if o.type == 'MESH']:
        transform = rig.matrix_world.inverted() @ ob.matrix_world
        ob.data.transform(transform)
        ob.matrix_parent_inverse = Matrix.Identity(4)
        ob.matrix_basis = Matrix.Identity(4)
        for p in ob.data.polygons:
            p.use_smooth = False
    rig.scale = (1, 1, 1)
    bpy.context.view_layer.update()
    return rig, next(o for o in scene.objects if o.type == 'MESH')


def skin(ob, rig, bone):
    # Geometry is authored in armature rest space, including rigid accessories.
    activate(ob)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    ob.parent = rig
    ob.matrix_parent_inverse = Matrix.Identity(4)
    group = ob.vertex_groups.new(name=bone)
    group.add(list(range(len(ob.data.vertices))), 1, 'REPLACE')
    mod = ob.modifiers.new('Crownfall skin', 'ARMATURE')
    mod.object = rig
    return ob


def mesh(name, verts, faces, color, rig=None, bone=None):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces)
    data.update()
    ob = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(ob)
    data.materials.append(material(color))
    if rig:
        skin(ob, rig, bone)
    return ob


def ico(name, center, scale, color, rig, bone, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1, location=center)
    ob = bpy.context.object
    ob.name = name
    ob.scale = scale
    ob.data.materials.append(material(color))
    return skin(ob, rig, bone)


def bar(name, a, b, radius, color, rig, bone, tip=None, vertices=8):
    a, b = Vector(a), Vector(b)
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius,
        radius2=radius if tip is None else tip, depth=(b-a).length, location=(a+b)/2)
    ob = bpy.context.object
    ob.name = name
    ob.rotation_euler = (b-a).to_track_quat('Z', 'Y').to_euler()
    ob.data.materials.append(material(color))
    return skin(ob, rig, bone)


def plate(name, center, width, height, color, rig, bone, depth=.12):
    x, y, z = center
    outline = [(-.5, .4), (-.35, .5), (.35, .5), (.5, .4), (.42, -.22), (0, -.55), (-.42, -.22)]
    verts = [(x+u*width, y, z+v*height) for u, v in outline]
    verts.append((x, y-depth, z))
    faces = [(i, (i+1) % 7, 7) for i in range(7)]
    return mesh(name, verts, faces, color, rig, bone)


def fin(name, coords, thickness, color, rig, bone):
    # A closed faceted prism in the YZ plane; useful for plumes and feathers.
    verts = [(x+side*thickness/2, y, z) for side in [-1, 1] for x, y, z in coords]
    count = len(coords)
    faces = [tuple(reversed(range(count))), tuple(range(count, count*2))]
    faces += [(i, (i+1) % count, (i+1) % count+count, i+count) for i in range(count)]
    return mesh(name, verts, faces, color, rig, bone)


def socket(name, rig, bone, position):
    ob = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(ob)
    ob.empty_display_type = 'ARROWS'
    ob.empty_display_size = .35
    ob.parent = rig
    ob.parent_type = 'BONE'
    ob.parent_bone = bone
    # Blender's bone parent transform includes the bone's length along local Y.
    parent_matrix = rig.data.bones[bone].matrix_local @ Matrix.Translation((0, rig.data.bones[bone].length, 0))
    ob.matrix_basis = parent_matrix.inverted() @ Matrix.Translation(position)
    ob['purpose'] = name
    return ob


def remap_materials(ob, names):
    indices = [p.material_index for p in ob.data.polygons]
    ob.data.materials.clear()
    for name in names:
        ob.data.materials.append(material(name))
    for p, index in zip(ob.data.polygons, indices):
        p.material_index = min(index, len(names)-1)


def enlarge_head(ob, rig, factor):
    pivot = rig.data.bones['Head'].head_local.copy()
    index = ob.vertex_groups['Head'].index
    for v in ob.data.vertices:
        weight = next((g.weight for g in v.groups if g.group == index), 0)
        v.co = pivot + (v.co-pivot) * (1+(factor-1)*weight)


def knight(asset_id, title, faction, helmet, variant):
    rig, body = load_base('KnightCharacter')
    remap_materials(body, ['steel', 'skin', 'ink'])
    enlarge_head(body, rig, 1.45)
    # Broad chest and armored hands, while retaining the common skeleton.
    for v in body.data.vertices:
        if 2.5 < v.co.z < 3.8 and abs(v.co.x) < .7:
            v.co.x *= 1.18
    with bpy.data.libraries.load(str(SOURCE / (helmet+'.blend')), link=False) as (src, dst):
        dst.objects = src.objects
    helm = next(o for o in dst.objects if o.type == 'MESH')
    bpy.context.collection.objects.link(helm)
    helm.name = 'GEAR_Helmet_' + faction
    helm.location = (0, .04, 5.115)
    helm.scale = (1.45, 1.45, 1.45)
    remap_materials(helm, ['steel_light', faction] if variant == 0 else
        ([faction, 'gold', 'ink'] if variant == 1 else ['steel']))
    skin(helm, rig, 'Head')
    if variant == 2:
        for side in [-1, 1]:
            ico('Eye_white', (side*.45, -.88, 4.98), (.20, .065, .20), 'white', rig, 'Head', 2)
            ico('Eye_iris', (side*.45, -.944, 4.98), (.10, .025, .15), faction, rig, 'Head', 2)
            ico('Eye_pupil', (side*.45, -.966, 4.98), (.05, .015, .12), 'ink', rig, 'Head')
            ico('Eye_glint', (side*.45-.04, -.983, 5.04), (.03, .012, .04), 'white', rig, 'Head')
    # Each faction has a different upper silhouette, beyond a palette swap.
    if variant == 0:
        for side in [-1, 1]:
            for i in range(3):
                bar('Winged_crest', (side*.94, .12+i*.23, 5.75),
                    (side*(1.48-i*.13), .55+i*.25, 6.40-i*.19), .19, 'ivory', rig, 'Head', tip=0)
        fin('Azure_plume', [(0, -.20, 6.15), (0, .65, 6.67), (0, 1.95, 5.9), (0, .6, 6.10)], .25, faction, rig, 'Head')
    elif variant == 1:
        fin('Crimson_horsehair', [(0, -.5, 6.55), (0, .2, 7.10), (0, 1.4, 6.85), (0, 2.0, 5.90), (0, .8, 6.20)], .38, 'red_light', rig, 'Head')
        plate('Crown_diamond', (0, -1.03, 6.11), .38, .61, 'gold', rig, 'Head')
    else:
        for side in [-1, 1]:
            for i in range(3):
                bar('Laurel_crest', (side*.75, -.1+i*.34, 5.95),
                    (side*(1.03-i*.1), -.05+i*.38, 6.58-i*.10), .18, 'gold', rig, 'Head', tip=0)
        plate('Jade_brow', (0, -.83, 5.94), .4, .6, faction, rig, 'Head')
    plate('Breastplate_gold_edge', (0, -.39, 3.25), 1.38, 1.22, 'gold', rig, 'Torso')
    plate('Breastplate_enamel', (0, -.44, 3.27), 1.16, 1.02, faction, rig, 'Torso', .16)
    plate('Chest_sigil', (0, -.63, 3.32), .31, .42, 'ivory', rig, 'Torso', .03)
    bar('Waist_belt', (-.6, -.40, 2.40), (.6, -.40, 2.40), .13, 'leather', rig, 'Abdomen')
    plate('Belt_buckle', (0, -.55, 2.40), .27, .27, 'gold', rig, 'Abdomen', .03)
    for side, suffix in [(1, 'L'), (-1, 'R')]:
        ico('Pauldron_gold', (side*.91, .10, 3.73), (.74, .63, .46), 'gold', rig, 'UpperArm.'+suffix)
        ico('Pauldron_enamel', (side*.92, .03, 3.81), (.63, .58, .40), faction, rig, 'UpperArm.'+suffix)
        plate('Tasset', (side*.37, -.4, 2.12), .62, .85, faction, rig, 'UpperLeg.'+suffix)
        plate('Knee_guard', (side*.53, -.25, .96), .54, .58, 'gold', rig, 'LowerLeg.'+suffix)
        ico('Armored_boot', (side*.53, -.06, .26), (.32, .48, .32), 'steel', rig, 'Foot.'+suffix)
        ico('Gauntlet', (side*2.75, .22, 3.69), (.40, .29, .31), 'steel', rig, 'Palm.'+suffix)
    # Split cape, deliberately rigid to Torso in this prototype (no cloth simulation).
    for side in [-1, 1]:
        verts = [(side*.12,.48,3.65),(side*.65,.48,3.55),(side*.94,1.0,1.72),(side*.18,1.25,1.45),(side*.36,.94,2.7)]
        mesh('Cape_panel', verts, [(0,1,4),(1,2,4),(2,3,4),(3,0,4)], faction+'_dark', rig, 'Torso')
    plate('Shield_gold_edge', (2.97, -.14, 3.55), 1.85, 1.38, 'gold', rig, 'Palm.L')
    plate('Shield_enamel', (2.97, -.23, 3.57), 1.58, 1.19, faction, rig, 'Palm.L', .17)
    plate('Shield_sigil', (2.97, -.43, 3.62), .69, .37, 'ivory', rig, 'Palm.L', .035)
    # Lance is stored as a separate skinned accessory; hand-space socket is exported too.
    bar('Lance_shaft', (-2.97,-.1,2.8), (-2.97,-.1,8.2), .065, 'leather_light', rig, 'Palm.R')
    bar('Lance_grip', (-2.97,-.1,3.3), (-2.97,-.1,4), .11, 'ink', rig, 'Palm.R')
    bar('Lance_guard', (-2.97,-.1,4), (-2.97,-.1,4.4), .30, 'gold', rig, 'Palm.R', tip=.09)
    bar('Lance_tip', (-2.97,-.1,8.2), (-2.97,-.1,8.9), .20, 'steel_light', rig, 'Palm.R', tip=0, vertices=4)
    mesh('Lance_pennon', [(-2.97,-.1,7.9),(-2.97,-.1,7.15),(-1.75,-.1,7.05),(-2.1,-.1,7.5),(-1.75,-.1,7.9)], [(0,1,2,3,4)], faction, rig, 'Palm.R')
    socket('SCK_LancePivot', rig, 'Palm.R', (-2.97, -.1, 3.69))
    socket('SCK_Shield', rig, 'Palm.L', (2.97, -.14, 3.55))
    socket('SCK_RiderSeat', rig, 'Hips', (0, 0, 1.96))
    socket('SCK_Helmet', rig, 'Head', (0, 0, 5.115))
    rig.scale = (.25,)*3
    return finish(asset_id, title, rig, 'Idle', faction)


def dinosaur(asset_id, species, faction, scale, seat):
    rig, body = load_base(species)
    if species == 'Velociraptor':
        remap_materials(body, [faction, 'ink', 'ivory'])
    elif species == 'Triceratops':
        remap_materials(body, [faction, 'ivory', 'ivory'])
    else:
        remap_materials(body, [faction, faction+'_light', 'ivory', 'gold'])
    enlarge_head(body, rig, 1.22)
    # Enrich large planes without adding scale microdetail or extra draw calls.
    body.data.materials.append(material(faction+'_light'))
    light_index = len(body.data.materials)-1
    for p in body.data.polygons:
        if p.material_index == 0 and p.normal.z > .6:
            p.material_index = light_index
    head = rig.data.bones['Head'].head_local
    if species == 'Triceratops':
        eye = (.73, -3.68, 3.10)
    elif species == 'Velociraptor':
        eye = (.50, -4.14, 5.14)
    else:
        eye = (.40, -3.54, 5.40)
    # Head enhancement follows the same pivot as the enlarged source mesh.
    eye = head + (Vector(eye)-head)*1.22
    surface = BVHTree.FromPolygons([v.co for v in body.data.vertices], [p.vertices for p in body.data.polygons])
    for side in [-1, 1]:
        hit, normal, _, _ = surface.ray_cast(Vector((side*10,eye.y,eye.z)),Vector((-side,0,0)))
        assert hit is not None, f'No facial surface for {species} eye'
        pos = (hit.x, eye.y, eye.z)
        ico('Eye_socket', pos, (.07,.26,.22), faction+'_dark', rig, 'Head', 2)
        ico('Eye_amber', (pos[0]+side*.055,pos[1]-.01,pos[2]), (.04,.19,.16), 'eye', rig, 'Head', 2)
        ico('Eye_pupil', (pos[0]+side*.09,pos[1]-.055,pos[2]), (.025,.075,.13), 'ink', rig, 'Head', 2)
        ico('Eye_glint', (pos[0]+side*.11,pos[1]-.09,pos[2]+.06), (.015,.035,.04), 'white', rig, 'Head')
        bar('Brow_ridge', (pos[0],pos[1]-.23,pos[2]+.15), (pos[0],pos[1]+.20,pos[2]+.21), .08, faction+'_dark', rig, 'Head', tip=.04)
    if species == 'Velociraptor':
        for side in [-1, 1]:
            for i in range(3):
                bar('Temple_feather', (side*.50,-3.8,5.28-i*.12), (side*.73,-2.95+i*.18,5.55-i*.14), .14, 'ivory', rig, 'Head', tip=0)
    elif species == 'Triceratops':
        # Small enamel frontal badge; horns and frill remain fully visible.
        plate('Frill_badge', (0,-3.31,4.03), .55,.65,'gold',rig,'Neck',.04)
    x, y, z = seat
    # Saddle fits the back; cloth does not cover the identifying head or tail.
    for side in [-1, 1]:
        verts = [(0,y-.65,z-.10),(side*.72,y-.65,z-.28),(side*.97,y-.45,z-1.0),
                 (side*.94,y+.60,z-.9),(side*.65,y+.72,z-.23),(0,y+.72,z-.10)]
        mesh('Saddlecloth_'+str(side), verts, [(0,1,4,5),(1,2,3,4)], faction+'_dark', rig, 'Hips')
        bar('Cloth_gold_hem',(side*.97,y-.45,z-1),(side*.94,y+.60,z-.9),.045,'gold',rig,'Hips')
        ico('Saddle_side_buckle',(side*.82,y,z-.52),(.09,.20,.18),'gold',rig,'Hips')
        bar('Girth_strap',(side*.65,y,z-.25),(side*.72,y,z-1.40),.075,'leather',rig,'Hips')
        bar('Stirrup_leather',(side*.73,y+.25,z-.3),(side*.89,y+.25,z-1.1),.045,'leather_light',rig,'Hips')
        bar('Stirrup_iron',(side*.89,y+.02,z-1.12),(side*.89,y+.45,z-1.12),.055,'steel',rig,'Hips')
    ico('Saddle_seat',(x,y,z),(.66,.69,.16),'leather',rig,'Hips',2)
    bar('Saddle_pommel',(-.53,y-.58,z+.06),(.53,y-.58,z+.06),.12,'gold',rig,'Hips')
    bar('Saddle_cantle',(-.58,y+.58,z+.08),(.58,y+.58,z+.08),.16,'leather_light',rig,'Hips')
    socket('SCK_RiderSeat',rig,'Hips',(x,y,z+.15))
    socket('SCK_BeastContact',rig,'Head',tuple(head))
    rig.scale=(scale,)*3
    return finish(asset_id, species, rig, species+'_Idle', faction)


def palette_atlas():
    image = bpy.data.images.get('Crownfall_Palette')
    if image:
        return image
    size = 512
    image = bpy.data.images.new('Crownfall_Palette',width=size,height=size,alpha=False)
    keys = list(COLORS)
    pixels=[]
    for y in range(size):
        for x in range(size):
            idx = (y//64)*8+x//64
            color = linear(COLORS[keys[idx]]) if idx < len(keys) else (0.02,.03,.05,1)
            pixels.extend(color)
    image.pixels.foreach_set(pixels)
    image.filepath_raw=str(OUT/'textures/Crownfall_Palette.png')
    image.file_format='PNG'
    image.save()
    image.pack()
    return image


def atlas_meshes():
    atlas=palette_atlas()
    m=bpy.data.materials.new('MAT_Crownfall_Palette')
    m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Roughness'].default_value=.72
    tex=m.node_tree.nodes.new('ShaderNodeTexImage')
    tex.image=atlas
    tex.interpolation='Closest'
    m.node_tree.links.new(tex.outputs['Color'],p.inputs['Base Color'])
    m.use_backface_culling=False
    for ob in [o for o in bpy.context.scene.objects if o.type=='MESH']:
        names=[slot.name.removeprefix('CF_') for slot in ob.data.materials]
        # A center UV per flat color face gives a reusable atlas without external dependencies.
        while ob.data.uv_layers:
            ob.data.uv_layers.remove(ob.data.uv_layers[-1])
        uv=ob.data.uv_layers.new(name='PaletteUV')
        for poly in ob.data.polygons:
            idx=list(COLORS).index(names[poly.material_index])
            coord=((idx%8+.5)/8,(idx//8+.5)/8)
            for loop in poly.loop_indices:
                uv.data[loop].uv=coord
            poly.material_index=0
        ob.data.materials.clear()
        ob.data.materials.append(m)


def actual_bounds():
    dg=bpy.context.evaluated_depsgraph_get()
    pts=[]
    for ob in bpy.context.scene.objects:
        if ob.type!='MESH' or ob.get('studio'):
            continue
        ev=ob.evaluated_get(dg)
        data=ev.to_mesh()
        pts.extend(ev.matrix_world@v.co for v in data.vertices)
        ev.to_mesh_clear()
    lo=Vector([min(p[i] for p in pts) for i in range(3)])
    hi=Vector([max(p[i] for p in pts) for i in range(3)])
    return lo,hi


def finish(asset_id,title,rig,idle,faction):
    rig.name=asset_id+'_Rig'
    rig['asset_status']='ART_PROTOTYPE; not engine-validated'
    rig['source_license']='CC0-1.0; Quaternius base, Crownfall adaptations'
    rig['forward_axis']='-Y in Blender; +Z in glTF'
    rig.data.pose_position='POSE'
    rig.animation_data.action=bpy.data.actions[idle]
    bpy.context.scene.frame_set(0)
    bpy.context.view_layer.update()
    lo,hi=actual_bounds()
    rig.location.z -= lo.z
    bpy.context.view_layer.update()
    atlas_meshes()
    # Join gear into its own skinned mesh; retain the source body separately for editing.
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    # Source mesh is the only mesh with the full set of vertex groups.
    body=max(meshes,key=lambda o:len(o.vertex_groups))
    gear=[o for o in meshes if o!=body]
    if gear:
        bpy.ops.object.select_all(action='DESELECT')
        for ob in gear:ob.select_set(True)
        bpy.context.view_layer.objects.active=gear[0]
        bpy.ops.object.join()
        gear[0].name=asset_id+'_Gear'
    body.name=asset_id+'_Body'
    # Original actions include locomotion and reactions; no gameplay scoring is attached.
    for action in bpy.data.actions:
        action.use_fake_user=True
    scene=bpy.context.scene
    scene.render.fps=30
    scene.frame_start=0
    scene.frame_end=int(bpy.data.actions[idle].frame_range[1])
    scene.unit_settings.system='METRIC'
    scene.unit_settings.scale_length=1
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(OUT/'glb'/f'{asset_id}.glb'),export_format='GLB',
        use_selection=True,export_animations=True,export_animation_mode='ACTIONS',
        export_force_sampling=True,export_frame_range=False,export_skins=True,
        export_yup=True,export_extras=True,export_def_bones=False)
    rig.animation_data.action=bpy.data.actions[idle]
    scene.frame_set(0)
    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'AssetSource'/f'{asset_id}.blend'),compress=True)
    stats={'id':asset_id,'name':title,'faction':faction,'status':'ART_PROTOTYPE',
           'source':'KnightCharacter' if asset_id.startswith('CHR') else title,
           'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in scene.objects if o.type=='MESH'),
           'bones':len(rig.data.bones),'actions':[a.name for a in bpy.data.actions],
           'sockets':[o.name for o in scene.objects if o.type=='EMPTY'],
           'scale':list(rig.scale)}
    if '--no-render' not in sys.argv:
        render_preview(asset_id,title)
    return stats


def render_preview(asset_id,title):
    scene=bpy.context.scene
    lo,hi=actual_bounds()
    center=(lo+hi)/2
    extent=hi-lo
    scene.render.engine='CYCLES'
    scene.cycles.samples=48
    scene.cycles.use_denoising=False
    scene.render.resolution_x=1000
    scene.render.resolution_y=1000
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format='PNG'
    scene.view_settings.view_transform='AgX'
    scene.world=bpy.data.worlds.new('Crownfall_studio')
    scene.world.use_nodes=True
    scene.world.node_tree.nodes.get('Background').inputs[0].default_value=(.24,.30,.40,1)
    scene.world.node_tree.nodes.get('Background').inputs[1].default_value=.55
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.015))
    floor=bpy.context.object;floor['studio']=True
    mat=bpy.data.materials.new('Studio_slate');mat.diffuse_color=(.07,.09,.13,1);mat.use_nodes=True
    mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(.07,.09,.13,1)
    mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.9
    floor.data.materials.append(mat)
    size=max(extent)
    for loc,power,color in [((1,-2,3),130,(1,.88,.72)),((-2,-1,1),85,(.65,.8,1)),((0,2,2),180,(1,.91,.76))]:
        bpy.ops.object.light_add(type='AREA',location=center+Vector(loc)*size)
        o=bpy.context.object;o.data.energy=power*size**2;o.data.color=color;o.data.shape='DISK';o.data.size=size*1.4
        o.rotation_euler=(center-o.location).to_track_quat('-Z','Y').to_euler()
    bpy.ops.object.camera_add(location=center+Vector((1.4,-2.4,1.1))*size)
    camera=bpy.context.object;camera.data.type='ORTHO';scene.camera=camera
    for view,direction in [('hero',(1.4,-2.4,1.1)),('front',(0,-3,0)),('side',(3,0,0)),('back',(0,3,0))]:
        camera.location=center+Vector(direction)*size
        camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
        # Fit projected vertices so long tails do not make front views microscopic.
        bpy.context.view_layer.update()
        inv=camera.matrix_world.inverted()
        corners=[inv@Vector((x,y,z)) for x in (lo.x,hi.x) for y in (lo.y,hi.y) for z in (lo.z,hi.z)]
        width=max(p.x for p in corners)-min(p.x for p in corners)
        height=max(p.y for p in corners)-min(p.y for p in corners)
        camera.data.ortho_scale=max(width,height)*1.16
        scene.render.filepath=str(OUT/'previews'/f'{asset_id}_{view}.png')
        if view!='hero':
            scene.render.resolution_x=600;scene.render.resolution_y=600;scene.cycles.samples=24
        bpy.ops.render.render(write_still=True)


if __name__=='__main__':
    selected=sys.argv[sys.argv.index('--only')+1] if '--only' in sys.argv else None
    results=[]
    for args in FACTIONS:
        if not selected or selected==args[0]:results.append(knight(*args))
    for args in DINOS:
        if not selected or selected==args[0]:results.append(dinosaur(*args))
    target=OUT/('build_report.json' if not selected else f'{selected}_build.json')
    target.write_text(json.dumps({'blender':bpy.app.version_string,'assets':results},indent=2)+'\n')
    print('CROWNFALL BUILD COMPLETE',target,flush=True)
