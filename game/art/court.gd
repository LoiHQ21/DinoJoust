extends Node3D
const G = preload("res://art/geometry.gd")
const WOOD := "8b5744"
const LIGHT_WOOD := "cd9761"
const GOLD := "edc375"
const RED := "ad3949"
const BLUE := "3c6999"
var rng := RandomNumberGenerator.new()
var track: MeshInstance3D
var sunlight: DirectionalLight3D

func build():
	rng.seed = 1791
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var gradient := ProceduralSkyMaterial.new()
	gradient.sky_top_color = Color("287dbe")
	gradient.sky_horizon_color = Color("9dcced")
	gradient.sky_curve = .62
	gradient.ground_horizon_color = Color("9dcced")
	gradient.sun_angle_max = 0
	sky.sky_material = gradient
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("efedf9")
	environment.ambient_light_energy = .55
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.fog_enabled = true
	environment.fog_light_color = Color("bcd4da")
	environment.fog_density = .0017
	environment.fog_sky_affect = .12
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,139,0)
	sun.light_color = Color("fff0d5")
	sun.light_energy = .74
	sunlight = sun
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 34
	add_child(sun)
	var decor := G.joint(self,Vector3.ZERO)
	G.box(decor,Vector3(0,-.45,0),Vector3(360,.72,360),"8eaf69")
	track = G.box(self,Vector3(0,-.10,0),Vector3(10.4,.2,177),"c59665")
	for s in [-1,1]:
		G.box(decor,Vector3(s*4.96,.014,0),Vector3(.12,.028,170),"f5d797")
		for z in range(-84,85,4):
			var root := Vector3(s*5.4,.0,z)
			G.box(decor,root+Vector3.UP*.65,Vector3(.22,1.30,.24),WOOD)
			G.rod(decor,root+Vector3.UP*1.30,root+Vector3.UP*1.50,.17,0,LIGHT_WOOD,4)
			for y in [.47,.98]:
				G.box(decor,root+Vector3(0,y,2),Vector3(.15,.18,4.05),LIGHT_WOOD)
			if z%12 == 0:
				var flagcolor := RED if (z+84)%24 == 0 else BLUE
				var fp := root+Vector3(-s*.17,.75,.85)
				G.box(decor,fp,Vector3(.042,.67,.65),flagcolor)
				G.box(decor,fp+Vector3(-s*.027,0,0),Vector3(.022,.35,.08),GOLD)
		for z in range(-72,73,16):
			stand(decor,s,z)
		for z in range(-81,82,9):
			tree(decor,Vector3(s*rng.randf_range(16,23),0,z),rng.randf_range(.75,1.5))
	for j in 320:
		var x := rng.randf_range(-4.75,4.75)
		var z := rng.randf_range(-85,85)
		G.gem(decor,Vector3(x,.014,z),Vector3(rng.randf_range(.03,.15),.014,rng.randf_range(.09,.34)),
			["c79769","eac08a","d4a376"][j%3])
	for z in range(-83,84,3):
		G.box(decor,Vector3(0,.016,z),Vector3(.055,.018,1.4),"f2ce91")
	for sign_z in [-1,1]:
		castle(decor,sign_z)
	for i in 48:
		var a := i*TAU/48
		var p := Vector3(cos(a)*rng.randf_range(122,155),-2,sin(a)*rng.randf_range(129,161))
		var h := rng.randf_range(16,35)
		var mountain: String = ["819ba4","8badae","799da9","91adb1"][i%4]
		G.rod(decor,p,p+Vector3(0,h,0),rng.randf_range(13,26),0,mountain,5)
		if i%3 == 0:
			G.rod(decor,p+Vector3.UP*h*.78,p+Vector3.UP*h,.22*16,0,"d4e1d7",5)
	for i in 35:
		var a := i*TAU/35
		var p := Vector3(cos(a)*129,rng.randf_range(26,48),sin(a)*129)
		for j in 3:
			G.gem(decor,p+Vector3(j*4,j%2*1.5,0),Vector3(7,2.5+j%2,5),"f9f1dd")
	G.batch(decor)

func ground(surface: String):
	track.material_override = G.material("b08769" if surface == "Rainsoft Clay" else "c59665")

func tree(n: Node3D, p: Vector3, k: float):
	G.rod(n,p,p+Vector3.UP*3.1*k,.32*k,.18*k,WOOD)
	for j in 3:
		var q := p+Vector3((j-1)*.88,3.2+(j%2)*1.02,rng.randf_range(-.6,.6))*k
		G.gem(n,q,Vector3(1.65,1.7,1.5)*k,["81a556","73944e","a3b45c"][j])

func stand(n: Node3D, side: int, z: int):
	var tint := RED if (z+72)%32 == 0 else BLUE
	for row in 3:
		var x := side*(7.7+row*1.1)
		var y := .65+row*.68
		G.box(n,Vector3(x,y/2,z),Vector3(1.35,y,14),WOOD)
		G.box(n,Vector3(x,y,z),Vector3(1.42,.13,14.1),LIGHT_WOOD)
		for j in 10:
			var p := Vector3(x,y+.46,z-6.2+j*1.36+rng.randf_range(-.15,.15))
			var cloth: String = [tint,"a36c48","8a7683","589589","dbaa56","516779"][rng.randi_range(0,5)]
			G.gem(n,p,Vector3(.28,.40,.30),cloth)
			var skin: String = ["dcad83","a16e54","efc393"][rng.randi_range(0,2)]
			G.gem(n,p+Vector3.UP*.48,Vector3(.22,.24,.22),skin)
			for eye_z in [-.084,.084]:
				G.box(n,p+Vector3(-side*.202,.49,eye_z),Vector3(.032,.04,.042),"524438")
			G.gem(n,p+Vector3(.035*side,.62,0),Vector3(.225,.15,.23),["634638","80533b","baa16d"][j%3])
	for end in [-1,1]:
		G.box(n,Vector3(side*10.15,2.45,z+end*6.6),Vector3(.2,4.9,.21),WOOD)
	# Striped, sloping cloth awnings above the uppermost spectators.
	for j in 8:
		var roof := G.box(n,Vector3(side*9.65,4.85,z-6.14+j*1.75),Vector3(4.15,.13,1.76),tint if j%2==0 else "f1dcab")
		roof.rotation.z = side*.14
		G.box(n,Vector3(side*7.62,4.45,z-6.14+j*1.75),Vector3(.10,.29,1.74),tint if j%2==0 else "f1dcab")
	var pole := Vector3(side*6.15,0,z)
	G.rod(n,pole,pole+Vector3.UP*5.65,.09,.07,WOOD)
	G.rod(n,pole+Vector3.UP*5.59,pole+Vector3.UP*5.94,.155,0,GOLD)
	G.box(n,pole+Vector3(0,5.02,.74),Vector3(.055,.89,1.42),tint)
	G.box(n,pole+Vector3(0,5.02,.31),Vector3(.06,.89,.13),GOLD)
	# A tournament standard hangs in front of each striped canopy.
	var standard := pole+Vector3(0,3.12,1.08)
	G.rod(n,pole+Vector3.UP*4.39,pole+Vector3(0,4.39,1.83),.055,.055,GOLD)
	G.box(n,standard+Vector3.UP*.27,Vector3(.06,1.94,1.17),tint)
	var hem := G.box(n,standard+Vector3.DOWN*.69,Vector3(.062,.83,.83),tint)
	hem.rotation.x = PI*.25
	var motif := standard+Vector3(-side*.052,.16,0)
	for k in [-1,0,1]:
		var tooth := G.box(n,motif+Vector3(0,.15+(.08 if k==0 else 0.0),k*.20),Vector3(.04,.30,.105),GOLD)
		tooth.rotation.x = k*.24
	G.box(n,motif,Vector3(.045,.17,.51),GOLD)

func castle(n: Node3D, s: int):
	var z := s*87.0
	for side in [-1,1]:
		for j in 14:
			var brick := Vector3(side*(5+j%7*1.86+(j/7)*.47),2.3+(j/7)*1.96,z-s*1.51)
			G.box(n,brick,Vector3(1.42,.52,.06),"a49d9a")
		G.box(n,Vector3(side*12,3.25,z),Vector3(15,6.5,3),"b5ada6")
		for j in 8:
			G.box(n,Vector3(side*(5+j*1.85),7,z),Vector3(1.05,1.08,3.1),"c9bfb1")
		for d in [5.1,19.6]:
			var p := Vector3(side*d,0,z)
			G.rod(n,p,p+Vector3.UP*10.4,2.55,2.27,"b8afa8",8)
			for y in [1.0,7.8,10.25]:
				G.rod(n,p+Vector3.UP*y,p+Vector3.UP*(y+.34),2.46,2.48,"d3c7b7",8)
			G.rod(n,p+Vector3.UP*10.5,p+Vector3.UP*15.9,2.9,0,"526b88",8)
			G.rod(n,p+Vector3.UP*15.9,p+Vector3.UP*17.8,.075,.045,WOOD)
			G.box(n,p+Vector3(.90,17.30,0),Vector3(1.81,.68,.05),RED)
			G.box(n,p+Vector3(0,6.1,-s*2.34),Vector3(.52,1.72,.12),"4c5362")
	G.box(n,Vector3(0,7.15,z),Vector3(9.1,2.8,3),"b8afa8")
	G.box(n,Vector3(0,8.51,z),Vector3(10,.4,3.2),"d5c6b0")
	for j in 5:
		G.box(n,Vector3(-3.6+j*1.8,9,z),Vector3(1,1,3.1),"c6b9aa")
	var flag := Vector3(0,7.48,z-s*1.59)
	G.box(n,flag,Vector3(2.0,2.6,.11),BLUE)
	G.box(n,flag+Vector3(0,0,-s*.07),Vector3(.35,1.3,.10),GOLD)
