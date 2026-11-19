extends Node3D
const G = preload("res://art/geometry.gd")
const GOLD := "efb74e"
const STEEL := "b9cbd4"
const DARK := "302d3d"
const IVORY := "fff0c2"
const LEATHER := "74432f"
var crest: String
var scale_color: String
var hide: String
var belly: String
var raptor: bool
var trunk: Node3D
var head: Node3D
var tail: Node3D
var rider: Node3D
var target_plate: Node3D
var lance: Node3D
var cape: Node3D
var legs: Array[Node3D] = []
var leg_home: Array[Vector3] = []
var gait := 0.0
var loose_saddle := false
var girth: Node3D
var rider_base: float

func build(is_raptor: bool):
	raptor = is_raptor
	crest = "b3233c" if raptor else "255f9c"
	scale_color = "d45331" if raptor else "487eb4"
	hide = "913740" if raptor else "354f85"
	belly = "f2b878" if raptor else "a6c5cf"
	trunk = G.joint(self,Vector3.ZERO)
	if raptor:
		make_raptor()
	else:
		make_frill()
	rider_base = 1.72 if raptor else 1.65
	make_knight()
	G.batch(self)

func make_raptor():
	G.body(trunk,[Vector4(-1.13,1.42,.24,.30),Vector4(-.63,1.49,.43,.50),
		Vector4(.18,1.38,.56,.57),Vector4(.78,1.35,.43,.43),Vector4(1.07,1.33,.24,.26)],scale_color)
	G.gem(trunk,Vector3(0,1.16,-.19),Vector3(.42,.33,.81),belly)
	tail = G.joint(trunk,Vector3(0,1.38,.77))
	G.body(tail,[Vector4(0,0,.38,.37),Vector4(.64,.02,.27,.26),Vector4(1.30,.18,.18,.17),
		Vector4(1.95,.38,.09,.09),Vector4(2.46,.44,.02,.025)],scale_color)
	for j in 4:
		var f := j/4.0
		G.gem(tail,Vector3(0,.22+f*.31,.20+f*2.3),Vector3(.28*(1-f),.12*(1-f),.16),hide)
	head = G.joint(trunk,Vector3(0,1.44,-.79))
	G.body(head,[Vector4(-.79,.44,.25,.27),Vector4(-.40,.25,.33,.35),Vector4(.12,.01,.30,.32)],scale_color)
	G.body(head,[Vector4(-1.66,.40,.19,.105),Vector4(-1.23,.40,.27,.13),Vector4(-.75,.40,.33,.17)],belly)
	G.body(head,[Vector4(-1.70,.55,.21,.12),Vector4(-1.46,.59,.32,.16),Vector4(-1.05,.63,.38,.24),
		Vector4(-.77,.64,.37,.32),Vector4(-.53,.57,.23,.22)],scale_color)
	for s in [-1,1]:
		G.gem(head,Vector3(s*.32,.67,-1.04),Vector3(.083,.115,.14),"ffcd54")
		G.gem(head,Vector3(s*.386,.68,-1.075),Vector3(.025,.082,.046),DARK)
		G.gem(head,Vector3(s*.397,.72,-1.09),Vector3(.012,.024,.018),IVORY)
		var brow := G.gem(head,Vector3(s*.32,.79,-1.035),Vector3(.11,.065,.24),hide)
		brow.rotation.x = -.20
		G.gem(head,Vector3(s*.231,.63,-1.59),Vector3(.037,.031,.04),DARK)
		for j in 4:
			var p := Vector3(s*(.23+j*.024),.48,-1.52+j*.13)
			G.rod(head,p,p+Vector3(0,-.085,0),.036,0,IVORY,5)
		var cheek := Vector3(s*.34,.52,-1.22)
		G.rod(head,cheek,Vector3(s*.31,.69,-1.28),.040,.040,LEATHER)
		G.rod(head,cheek,Vector3(s*.29,.37,-1.20),.040,.040,LEATHER)
		G.gem(head,cheek,Vector3(.053,.069,.069),GOLD)
		G.rod(trunk,Vector3(s*.35,1.95,-1.97),Vector3(s*.44,1.72,-1.08),.022,.022,LEATHER)
		G.rod(trunk,Vector3(s*.44,1.72,-1.08),Vector3(s*.4,2.10,-.40),.022,.022,LEATHER)
		var shoulder := Vector3(s*.36,1.44,-.71)
		var wrist := Vector3(s*.45,.99,-.89)
		G.rod(trunk,shoulder,wrist,.12,.073,scale_color)
		G.rod(trunk,wrist,wrist+Vector3(0,.04,-.24),.08,.045,belly)
		for k in 2:
			var p := wrist+Vector3((k-.5)*.06,.04,-.23)
			G.rod(trunk,p,p+Vector3(0,-.055,-.11),.026,0,DARK,5)
		make_leg(s,.48,1.2,.32)
	for j in 4:
		var p := Vector3(0,.87-j*.034,-.89+j*.15)
		G.rod(head,p,p+Vector3(0,.18+j*.02,.16),.095,0,hide,5)

func make_frill():
	G.body(trunk,[Vector4(-1.14,1.22,.39,.38),Vector4(-.79,1.23,.61,.54),
		Vector4(.03,1.23,.68,.57),Vector4(.78,1.2,.56,.48),Vector4(1.14,1.15,.32,.31)],scale_color,10)
	tail = G.joint(trunk,Vector3(0,1.17,.93))
	G.body(tail,[Vector4(0,0,.32,.29),Vector4(.61,-.04,.23,.19),Vector4(1.22,.02,.12,.10),Vector4(1.59,.12,.02,.02)],scale_color)
	head = G.joint(trunk,Vector3(0,1.28,-.76))
	var fan := G.gem(head,Vector3(0,.40,-.32),Vector3(.77,.65,.20),hide)
	fan.rotation.x = -.34
	var fan_face := G.gem(head,Vector3(0,.43,-.41),Vector3(.69,.57,.16),scale_color)
	fan_face.rotation.x = -.34
	for j in 9:
		var a := PI*(j/8.0)
		var p := Vector3(cos(a)*.69,.43+sin(a)*.56,-.34+sin(a)*.14)
		G.rod(head,p,p+Vector3(cos(a)*.12,sin(a)*.15,.025),.088,0,belly,5)
	G.body(head,[Vector4(-1.41,.04,.16,.18),Vector4(-1.13,.12,.29,.24),
		Vector4(-.75,.18,.44,.35),Vector4(-.32,.22,.45,.37)],scale_color)
	G.gem(head,Vector3(0,.00,-1.32),Vector3(.21,.18,.23),belly)
	G.rod(head,Vector3(0,.29,-1.17),Vector3(0,.42,-1.42),.09,0,IVORY)
	for s in [-1,1]:
		G.gem(head,Vector3(s*.36,.29,-.84),Vector3(.085,.12,.13),IVORY)
		G.gem(head,Vector3(s*.423,.29,-.87),Vector3(.03,.08,.06),DARK)
		G.gem(head,Vector3(s*.35,.40,-.85),Vector3(.11,.07,.17),hide)
		make_leg(s,.50,1.03,-.68)
		make_leg(s,.48,1.04,.70)

func make_leg(side: int, width: float, height: float, z: float):
	var limb := G.joint(self,Vector3(side*width,height,z))
	legs.append(limb)
	leg_home.append(limb.position)
	var knee := Vector3(side*.03,-height*.36,-.28 if raptor else -.065)
	var ankle := Vector3(0,-height*.76,.15 if raptor else .045)
	var foot := Vector3(0,-height+.12,-.10)
	G.gem(limb,knee*.4,Vector3(.25,.38,.33) if raptor else Vector3(.22,.31,.22),scale_color)
	G.rod(limb,knee,ankle,.17,.095,scale_color)
	G.rod(limb,ankle,foot,.105,.09,belly)
	G.gem(limb,foot,Vector3(.16,.10,.23),belly)
	for k in [-1,0,1]:
		var p := foot+Vector3(k*.08,-.01,-.10)
		G.rod(limb,p,p+Vector3(k*.07,-.055,-.23 if raptor else -.12),.055,0,DARK,5)

func make_knight():
	G.gem(trunk,Vector3(0,rider_base-.02,0),Vector3(.60,.17,.63),LEATHER)
	girth = G.joint(trunk,Vector3(0,rider_base,0))
	for s in [-1,1]:
		G.rod(girth,Vector3(s*.43,.06,.26),Vector3(s*.57,-.30,.15),.052,.052,LEATHER)
		G.gem(girth,Vector3(s*.56,-.21,.17),Vector3(.07,.09,.06),GOLD)
		var saddlecloth := G.gem(trunk,Vector3(s*.48,rider_base-.20,.08),Vector3(.13,.34,.43),crest)
		saddlecloth.rotation.z = -s*.24
		G.gem(trunk,Vector3(s*.55,rider_base-.18,.07),Vector3(.09,.13,.13),GOLD)
	rider = G.joint(trunk,Vector3(0,rider_base,0))
	for s in [-1,1]:
		var knee := Vector3(s*.50,-.18,-.23)
		G.rod(rider,Vector3(s*.20,.12,.01),knee,.145,.15,DARK)
		G.gem(rider,knee,Vector3(.15,.17,.17),STEEL)
		G.rod(rider,knee,knee+Vector3(s*.04,-.32,.09),.125,.095,LEATHER)
		G.gem(rider,knee+Vector3(s*.035,-.34,.00),Vector3(.14,.11,.20),DARK)
	G.gem(rider,Vector3(0,.35,0),Vector3(.33,.39,.25),STEEL)
	G.gem(rider,Vector3(0,.16,0),Vector3(.34,.12,.26),LEATHER)
	G.box(rider,Vector3(0,.17,-.247),Vector3(.14,.10,.035),GOLD)
	cape = G.joint(rider,Vector3(0,.63,.16))
	G.body(cape,[Vector4(0,0,.27,.06),Vector4(.23,-.19,.34,.07),Vector4(.51,-.42,.43,.07),Vector4(.75,-.49,.37,.035)],crest)
	for s in [-1,1]:
		G.rod(cape,Vector3(s*.21,-.01,.07),Vector3(s*.33,-.36,.53),.023,.023,GOLD)
	G.gem(cape,Vector3(0,-.27,.44),Vector3(.09,.043,.115),GOLD)
	G.rod(cape,Vector3(-.36,-.47,.72),Vector3(.36,-.47,.72),.025,.025,GOLD)
	for s in [-1,1]:
		G.gem(rider,Vector3(s*.32,.51,-.01),Vector3(.19,.15,.21),GOLD)
		G.gem(rider,Vector3(s*.33,.55,-.02),Vector3(.18,.13,.20),STEEL)
		G.rod(rider,Vector3(s*.31,.44,0),Vector3(s*.45,.28,-.16),.115,.094,DARK)
		G.rod(rider,Vector3(s*.45,.28,-.16),Vector3(s*.42,.43,-.39),.10,.089,STEEL)
		G.gem(rider,Vector3(s*.42,.43,-.39),Vector3(.10,.10,.12),LEATHER)
	G.gem(rider,Vector3(0,.89,-.015),Vector3(.32,.34,.29),STEEL)
	G.gem(rider,Vector3(0,.88,-.18),Vector3(.30,.23,.18),DARK)
	G.gem(rider,Vector3(0,.80,-.26),Vector3(.29,.14,.12),STEEL)
	for s in [-1,1]:
		G.gem(rider,Vector3(s*.12,.944,-.327),Vector3(.076,.030,.022),"ffdc9e")
		G.rod(rider,Vector3(0,1.02,-.316),Vector3(s*.28,.994,-.22),.025,.023,GOLD)
		for k in 2:
			G.box(rider,Vector3(s*(.07+k*.082),.805,-.366+k*.016),Vector3(.023,.076,.02),DARK)
	G.gem(rider,Vector3(0,1.17,0),Vector3(.12,.10,.16),GOLD)
	G.body(rider,[Vector4(-.12,1.20,.08,.10),Vector4(.03,1.34,.15,.16),Vector4(.24,1.37,.13,.14),
		Vector4(.48,1.29,.09,.12),Vector4(.62,1.16,.022,.05)],crest)
	target_plate = G.joint(rider,Vector3(0,.55,-.42))
	G.gem(target_plate,Vector3.ZERO,Vector3(.22,.23,.063),GOLD)
	G.gem(target_plate,Vector3(0,0,-.029),Vector3(.171,.182,.046),crest)
	G.gem(target_plate,Vector3(0,0,-.080),Vector3(.067,.067,.027),IVORY)
	# Long painted tournament lance, mounted in the rider's right gauntlet.
	lance = G.joint(rider,Vector3(.42,.43,-.39))
	var guard := Vector3(0,0,-.12)
	G.rod(lance,Vector3(0,0,.45),guard,.052,.065,LEATHER)
	G.rod(lance,guard,Vector3(0,0,-.39),.19,.105,GOLD)
	for j in 10:
		var a := j/10.0
		var b := (j+1)/10.0
		G.rod(lance,Vector3(0,0,-.39-3.23*a),Vector3(0,0,-.39-3.23*b),
			lerpf(.111,.031,a),lerpf(.111,.031,b),IVORY if j%2 else crest)
	G.rod(lance,Vector3(0,0,-3.62),Vector3(0,0,-3.78),.055,.015,GOLD)
	var shield := G.joint(rider,Vector3(-.49,.35,-.24))
	shield.rotation.y = .66
	G.gem(shield,Vector3.ZERO,Vector3(.28,.36,.11),GOLD)
	G.gem(shield,Vector3(0,.015,-.047),Vector3(.243,.302,.092),crest)
	G.box(shield,Vector3(0,.015,-.13),Vector3(.044,.30,.022),IVORY)
	G.box(shield,Vector3(0,.05,-.13),Vector3(.22,.047,.022),IVORY)

func pose(dt: float, pace: float, lance_aim: float, tell: bool, reaction: float, fallen: bool, side_reach := 0.0, lowered := true):
	gait += dt * (2.1 + pace*.88)
	var weight := clampf(pace/7.0,.11,1.0)
	trunk.position.y = (1.0-cos(2.0*gait))*.045*weight
	trunk.rotation.x = sin(gait*2)*.021*weight
	tail.rotation.y = sin(gait*.51)*(.06+.10*weight)
	head.rotation.x = cos(gait*2)*.028 + (0.16 if tell else 0.0) - sin(reaction*PI)*.19
	head.rotation.y = (-.18 if tell else 0.0)
	cape.rotation.x = sin(gait)*.09*weight - pace*.017
	for j in legs.size():
		var phase := gait + (PI if j in [1,2] else 0.0)
		legs[j].rotation.x = sin(phase)*.46*weight
		legs[j].position.y = leg_home[j].y + maxf(0,cos(phase))*.13*weight
	lance.rotation.y = -asin(clampf((1.68+side_reach)/3.78,-1,1))
	var pitch := atan2(2.27 + lance_aim*.82 - (rider_base+.43),3.4) if lowered else .54
	lance.rotation.x = move_toward(lance.rotation.x,pitch,dt*6.0)
	girth.visible = not loose_saddle
	rider.position = Vector3(0,rider_base,0)
	rider.rotation = Vector3(-.07*weight+sin(reaction*PI)*.25,0,.09*sin(gait)+.07 if loose_saddle else 0.0)
	if fallen:
		rider.position += Vector3(-2.4*reaction,3.5*sin(PI*reaction)-1.30*reaction,1.8*reaction)
		rider.rotation.z = reaction*4.6
