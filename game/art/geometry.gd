extends RefCounted
## Shared low-poly forms. Section profiles run nose to tail along local +Z.
static var materials := {}
static var shapes := {}

static func material(tone: String) -> StandardMaterial3D:
	if not materials.has(tone):
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(tone)
		m.roughness = 0.85
		materials[tone] = m
	return materials[tone]

static func joint(parent: Node3D, p: Vector3) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	n.position = p
	return n

static func piece(parent: Node3D, shape: Mesh, p: Vector3, size: Vector3, tone: String) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = shape
	n.material_override = material(tone)
	parent.add_child(n)
	n.position = p
	n.scale = size
	return n

static func box(parent: Node3D, p: Vector3, size: Vector3, tone: String) -> MeshInstance3D:
	if not shapes.has("box"):
		shapes.box = BoxMesh.new()
	return piece(parent, shapes.box, p, size, tone)

static func triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, outside: Vector3):
	var normal := (c-a).cross(b-a).normalized()
	if normal.dot(outside) < 0.0:
		var tmp := b
		b = c
		c = tmp
		normal = -normal
	for v: Vector3 in [a,b,c]:
		st.set_normal(normal)
		st.add_vertex(v)

# Each cross-section is (depth, centre height, half width, half height).
static func hull(sections: Array, sides := 8) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var previous := PackedVector3Array()
	for i in sections.size():
		var s: Vector4 = sections[i]
		var ring := PackedVector3Array()
		for j in sides:
			var a := TAU * (j + 0.5) / sides
			ring.append(Vector3(cos(a)*s.z, s.y+sin(a)*s.w, s.x))
		for j in sides:
			var k := (j + 1) % sides
			if i > 0:
				var out := Vector3(ring[j].x, ring[j].y-s.y, 0)
				triangle(st, previous[j], ring[j], ring[k], out)
				triangle(st, previous[j], ring[k], previous[k], out)
			if i == 0 or i == sections.size()-1:
				triangle(st, Vector3(0,s.y,s.x), ring[j], ring[k], Vector3.FORWARD if i == 0 else Vector3.BACK)
		previous = ring
	return st.commit()

static func body(parent: Node3D, sections: Array, tone: String, sides := 8) -> MeshInstance3D:
	return piece(parent, hull(sections,sides), Vector3.ZERO, Vector3.ONE, tone)

static func gem(parent: Node3D, p: Vector3, radii: Vector3, tone: String) -> MeshInstance3D:
	if not shapes.has("gem"):
		shapes.gem = hull([Vector4(-1,0,.18,.18),Vector4(-.55,0,.83,.83),Vector4(0,0,1,1),
			Vector4(.62,0,.78,.78),Vector4(1,0,.18,.18)],8)
	return piece(parent,shapes.gem,p,radii,tone)

static func rod(parent: Node3D, a: Vector3, b: Vector3, bottom: float, top: float, tone: String, sides := 8) -> MeshInstance3D:
	var key := "%s/%s/%s" % [bottom,top,sides]
	if not shapes.has(key):
		var cylinder := CylinderMesh.new()
		cylinder.bottom_radius = bottom
		cylinder.top_radius = top
		cylinder.height = 1
		cylinder.radial_segments = sides
		cylinder.rings = 0
		cylinder.cap_top = top > 0
		shapes[key] = cylinder
	var n := piece(parent,shapes[key],(a+b)*0.5,Vector3.ONE,tone)
	var y := (b-a).normalized()
	var x := y.cross(Vector3.FORWARD if absf(y.z) < .95 else Vector3.UP).normalized()
	n.basis = Basis(x,y*a.distance_to(b),x.cross(y))
	return n

# Merge static instances per shape/material for the arena and rigid rig segments.
static func batch(parent: Node3D):
	var groups := {}
	for child in parent.get_children():
		if child is MeshInstance3D:
			var key := [child.mesh.get_rid(), child.material_override.get_rid()]
			if not groups.has(key):
				groups[key] = []
			groups[key].append(child)
		elif child is Node3D:
			batch(child)
	for group: Array in groups.values():
		if group.size() < 2:
			continue
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = group[0].mesh
		multi.instance_count = group.size()
		var draw := MultiMeshInstance3D.new()
		draw.multimesh = multi
		draw.material_override = group[0].material_override
		parent.add_child(draw)
		for i in group.size():
			multi.set_instance_transform(i, group[i].transform)
			group[i].free()
