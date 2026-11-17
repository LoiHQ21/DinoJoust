"""Round-trip the exported assets and sample every animation in Blender.

Run: blender -b -t 4 --python tools/validate_art_roster.py
This validates interchange files, not gameplay, retargeting, or mobile performance.
"""
import bpy
import hashlib
import json
import math
import struct
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/roster'


def glb_json(path):
    raw=path.read_bytes()
    magic,version,length=struct.unpack_from('<4sII',raw)
    assert magic==b'glTF' and version==2 and length==len(raw), path
    size,kind=struct.unpack_from('<II',raw,12)
    assert kind==0x4e4f534a
    return json.loads(raw[20:20+size])


def bounds():
    dg=bpy.context.evaluated_depsgraph_get()
    points=[]
    for ob in bpy.context.scene.objects:
        if ob.type!='MESH':continue
        ev=ob.evaluated_get(dg);data=ev.to_mesh()
        points.extend(ev.matrix_world@v.co for v in data.vertices)
        ev.to_mesh_clear()
    assert points and all(math.isfinite(c) for p in points for c in p)
    return [[min(p[i] for p in points),max(p[i] for p in points)] for i in range(3)]


def validate(path):
    doc=glb_json(path)
    assert doc.get('skins') and doc.get('animations') and doc.get('meshes'), path
    assert all('uri' not in b for b in doc['buffers']), 'External buffer'
    assert all('bufferView' in im for im in doc['images']), 'Missing embedded palette'
    names={n.get('name') for n in doc['nodes']}
    assert 'SCK_RiderSeat' in names, 'Missing saddle interface'
    if path.stem.startswith('CHR'):
        assert {'SCK_LancePivot','SCK_Shield','SCK_Helmet'} <= names
    for mesh in doc['meshes']:
        for p in mesh['primitives']:
            assert {'POSITION','NORMAL','TEXCOORD_0','JOINTS_0','WEIGHTS_0'} <= set(p['attributes'])
    bpy.ops.wm.open_mainfile(filepath=str(OUT/'AssetSource'/(path.stem+'.blend')),load_ui=False)
    bpy.context.scene.frame_set(0)
    bpy.context.view_layer.update()
    expected_idle_bounds=bounds()
    expected_rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    expected_idle_name=expected_rig.animation_data.action.name
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.render.fps=30
    bpy.ops.import_scene.gltf(filepath=str(path))
    rigs=[o for o in bpy.context.scene.objects if o.type=='ARMATURE']
    assert len(rigs)==1, f'{path}: expected one armature'
    rig=rigs[0]
    # Blender's importer creates an editor-only Icosphere for bone display.
    # It is not a mesh from the GLB and must not affect geometry bounds.
    shapes={b.custom_shape for b in rig.pose.bones if b.custom_shape}
    for b in rig.pose.bones:
        b.custom_shape=None
    for shape in shapes:
        bpy.data.objects.remove(shape,do_unlink=True)
    for ob in [o for o in bpy.context.scene.objects if o.type=='MESH']:
        assert ob.data.uv_layers
        assert any(m.type=='ARMATURE' and m.object==rig for m in ob.modifiers)
        for v in ob.data.vertices:
            weights=[g.weight for g in v.groups]
            assert weights and abs(sum(weights)-1)<.001, (path,ob.name,v.index)
    for track in rig.animation_data.nla_tracks:
        track.mute=True
    results=[]
    checked_idle=False
    for action in bpy.data.actions:
        rig.animation_data.action=action
        if hasattr(action,'slots') and action.slots:
            rig.animation_data.action_slot=action.slots[0]
        start,end=action.frame_range
        frames=[start,start+(end-start)*.25,start+(end-start)*.5,start+(end-start)*.75,end]
        samples=[]
        poses=[]
        for frame in frames:
            bpy.context.scene.frame_set(int(frame),subframe=frame%1)
            bpy.context.view_layer.update()
            samples.append(bounds())
            poses.append([tuple(row) for bone in rig.pose.bones for row in bone.matrix])
        if action.name in {expected_idle_name,expected_idle_name+'_'+rig.name}:
            bpy.context.scene.frame_set(0)
            bpy.context.view_layer.update()
            got=bounds()
            error=max(abs(a-b) for expected,actual in zip(expected_idle_bounds,got) for a,b in zip(expected,actual))
            assert error<.001, f'{path}: idle geometry changed by {error} meters on round-trip'
            checked_idle=True
        assert any(poses[i]!=poses[0] for i in range(1,len(poses))), f'Static animation: {path}: {action.name}'
        # Detect transform explosions; do not mistake rolling/death bounds for grounded locomotion.
        assert max(abs(c) for sample in samples for axis in sample for c in axis)<30, (path,action.name,samples)
        results.append({'clip':action.name,'frame_range':[start,end],'sampled_frames':frames,'finite_deformation':True})
    assert checked_idle, f'{path}: idle action not found after import'
    return {'file':path.name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'skins':len(doc['skins']),'meshes':len(doc['meshes']),
        'triangles':sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives']),
        'materials':len(doc['materials']),'idle_bounds_m':expected_idle_bounds,
        'idle_round_trip_tolerance_m':.001,'animations':results,'status':'PASS'}


files=sorted((OUT/'glb').glob('*.glb'))
assert len(files)==6, f'Expected six assets, got {len(files)}'
report={'tool':'Blender '+bpy.app.version_string,'checks':'GLB round-trip, embedded palette, sockets, normalized weights, finite deformation at five points per clip',
        'assets':[validate(p) for p in files],
        'unverified':['Engine import and runtime shaders','Mounted pose/IK and lance aim','Contact animation and gameplay','Chase camera with HUD','Real-device performance']}
(OUT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: six rigged GLBs imported; every animation sampled; see assets/roster/validation.json')
