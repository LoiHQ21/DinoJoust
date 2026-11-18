extends Control
const REIN_RADIUS := 64.0
const TITLE = preload("res://art/Cinzel.ttf")
const INK := Color("#18242c")
const MID := Color("#34404a")
const GOLD := Color("#ebc680")
const PAPER := Color("#fff3d7")
const FADE := Color("#c1beb0")
const RED := Color("#a43b43")
const GREEN := Color("#aadeac")
var g: Node
var regular: Font = ThemeDB.fallback_font
var bold: FontVariation
var scale_ui := 1.0
var bounds := Vector2(1280,720)
var origin := Vector2.ZERO
var buttons := {}
var pointer := Vector2(-1000,-1000)
var on_touch := false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	bold = FontVariation.new()
	bold.base_font = regular
	bold.variation_embolden = .6
	on_touch = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")

func layout():
	var area := Rect2(Vector2.ZERO,size)
	if OS.has_feature("mobile") and size.x > 0:
		var pixels := Vector2(DisplayServer.screen_get_size())
		if pixels.x > 0 and pixels.y > 0:
			var safe := DisplayServer.get_display_safe_area()
			area = Rect2(Vector2(safe.position)*size/pixels,Vector2(safe.size)*size/pixels)
	scale_ui = maxf(.1,minf(area.size.x/1280.0,area.size.y/720.0))
	origin = area.position
	bounds = area.size/scale_ui

func local_ui(p: Vector2) -> Vector2:
	return (p-origin)/scale_ui

func action_at(p: Vector2) -> String:
	for id in buttons:
		if buttons[id].has_point(local_ui(p)):
			return id
	return ""

func words(s: String, x: float, y: float, pt := 18, ink := PAPER, font: Font = null, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0):
	draw_string(font if font else regular,Vector2(x,y),s,align,width,pt,ink)

func centered(s: String, y: float, pt: int, ink: Color, font: Font = null):
	words(s,0,y,pt,ink,font,HORIZONTAL_ALIGNMENT_CENTER,bounds.x)

func line(a: Vector2, b: Vector2, tint: Color, w := 1.0):
	draw_line(a,b,tint,w,true)

func diamond(p: Vector2, radius: float, color: Color):
	draw_colored_polygon(PackedVector2Array([p+Vector2.UP*radius,p+Vector2.RIGHT*radius,p+Vector2.DOWN*radius,p+Vector2.LEFT*radius]),color)

func crown(p: Vector2, k: float, tint: Color):
	var vertices := PackedVector2Array()
	for v: Vector2 in [Vector2(-15,-8),Vector2(-7,-2),Vector2(0,-13),Vector2(7,-2),Vector2(15,-8),Vector2(11,5),Vector2(-11,5)]:
		vertices.append(p+v*k)
	draw_colored_polygon(vertices,tint)
	line(p+Vector2(-10,8)*k,p+Vector2(10,8)*k,tint,2.4*k)

func plate(r: Rect2, fill := INK, edge := Color("#ad9364")):
	var a := r.position
	var b := r.end
	var pts := PackedVector2Array([Vector2(a.x+7,a.y),Vector2(b.x-7,a.y),Vector2(b.x,a.y+7),
		Vector2(b.x,b.y-7),Vector2(b.x-7,b.y),Vector2(a.x+7,b.y),Vector2(a.x,b.y-7),Vector2(a.x,a.y+7)])
	draw_colored_polygon(pts,fill)
	pts.append(pts[0])
	draw_polyline(pts,edge,1.4,true)

func button(id: String, r: Rect2, label: String, primary := false):
	buttons[id] = r
	var fill := Color("#f0cd87") if primary else Color("#273640")
	var hover := r.has_point(local_ui(pointer))
	plate(r,fill.lightened(.12) if hover else fill, Color("#ffe5aa") if primary else Color("#947f5b"))
	words(label,r.position.x,r.get_center().y+7,20,INK if primary else PAPER,bold,HORIZONTAL_ALIGNMENT_CENTER,r.size.x)

func _draw():
	if not g:
		return
	layout()
	draw_set_transform(origin,0,Vector2.ONE*scale_ui)
	buttons.clear()
	match g.phase:
		"lists": menu()
		"charge","follow": live()
		"summary": summary()
	if g.paused:
		draw_rect(Rect2(Vector2.ZERO,bounds),Color(0.04,.08,.10,.82))
		buttons.clear()
		var cx := bounds.x/2
		centered("Joust paused",bounds.y/2-44,49,PAPER,TITLE)
		button("resume",Rect2(cx-145,bounds.y/2,290,54),"Resume joust",true)
		button("menu",Rect2(cx-145,bounds.y/2+68,290,48),"Return to the lists")
	if g.debug and g.duel != null:
		var d = g.duel
		var r := Rect2(16,bounds.y*.47,390,88)
		plate(r)
		words("Seed %d  ·  Tick %d  ·  Pass %d" % [d.seed_value,d.tick,d.pass_no],28,r.position.y+27,16,GOLD)
		words("Gap %.2f m   Aim %.3f   Release %d" % [d.gap(),d.aim[0],d.release[0]],28,r.position.y+51,16)
		words("Shield %.3f   Seat %s" % [d.target[0],str(d.seat)],28,r.position.y+75,16)
	if size.y > size.x:
		plate(Rect2(bounds.x/2-175,8,350,36))
		centered("Turn your device to landscape",33,18,GOLD,bold)

func menu():
	var x := 52.0
	var y := bounds.y/2-302
	var panel := PackedVector2Array([Vector2.ZERO,Vector2(478,0),Vector2(543,bounds.y*.56),Vector2(488,bounds.y),Vector2(0,bounds.y)])
	draw_colored_polygon(panel,Color("#192730f9"))
	draw_polyline(PackedVector2Array([Vector2(465,0),Vector2(530,bounds.y*.56),Vector2(475,bounds.y)]),Color("#a48c60"),1.5,true)
	crown(Vector2(x+14,y+12),1.0,GOLD)
	words("T H E   R O Y A L   L I S T S",x+49,y+17,16,GOLD,bold)
	line(Vector2(x,y+45),Vector2(436,y+45),Color("#6d6a58"))
	words("Jurassic",x-3,y+134,73,PAPER,TITLE)
	words("Joust",x-3,y+219,92,PAPER,TITLE)
	draw_colored_polygon(PackedVector2Array([Vector2(x,y+240),Vector2(x+295,y+240),Vector2(x+284,y+259),Vector2(x+295,y+278),Vector2(x,y+278)]),RED)
	words("C R O W N F A L L",x+17,y+267,23,PAPER,TITLE)
	words("Light Division Exhibition",x,y+323,25,PAPER,TITLE)
	words("Unseat the rival knight or lead on lance",x,y+357,19,FADE)
	words("points after three passes.",x,y+383,19,FADE)
	button("terrain",Rect2(x,y+411,380,44),"‹     "+g.surface+"     ›")
	button("start",Rect2(x,y+468,380,60),"Enter the lists    ›",true)
	words("Drag the reins to ride. Hold the rival’s shield to hit." if on_touch else "A / D to steer. W to gallop. Hold click on the shield.",x,y+563,16,PAPER)
	words("Keep aiming as you pass. Lift to raise your lance.",x,y+589,15,FADE)
	var bx := bounds.x-325
	plate(Rect2(bx,bounds.y-98,291,66),Color("#1b2b33ea"))
	diamond(Vector2(bx+24,bounds.y-64),7,Color("#de7058"))
	words("THE EMBER KNIGHT",bx+44,bounds.y-68,16,GOLD,bold)
	words("Velociraptor  /  Predator snap",bx+44,bounds.y-44,16,PAPER)
	button("graphics",Rect2(bounds.x-276,22,153,42),"Detail   Low" if g.low_detail else "Detail   High")
	button("audio",Rect2(bounds.x-111,22,87,42),"Sound" if g.audio_on else "Muted")

func bar(x: float, y: float, w: float, ratio: float, fill: Color):
	draw_rect(Rect2(x,y,w,7),Color("#101c22"))
	draw_rect(Rect2(x,y,w*clampf(ratio,0,1),7),fill)

func rider_panel(right: bool):
	var d = g.duel
	var i := 1 if right else 0
	var x := bounds.x-320 if right else 22.0
	plate(Rect2(x,20,298,79),Color("#192831f4"))
	var tint := Color("#92b7ec") if right else Color("#e78a78")
	diamond(Vector2(x+23,43),6,tint)
	words("AZURE WARDEN" if right else "EMBER KNIGHT",x+40,49,19,PAPER,bold)
	words(str(d.seat[i]),x+230,50,22,tint,bold,HORIZONTAL_ALIGNMENT_RIGHT,47)
	bar(x+17,65,263,d.seat[i]/100.0,tint)
	words("SEAT STABILITY",x+17,90,12,FADE,bold)

func rein_center() -> Vector2:
	return Vector2(121,bounds.y-119)

func draw_reins():
	var hub := rein_center()
	var deflection: Vector2 = g.touch_reins if on_touch else Vector2(g.reins().x,-g.reins().y).limit_length(1.0)
	var rim := Color("#e5c68ac9")
	draw_circle(hub,REIN_RADIUS,Color("#15252cba"),true,-1,true)
	draw_arc(hub,REIN_RADIUS,0,TAU,64,rim,2,true)
	for dir: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
		var arrow := hub+dir*(REIN_RADIUS-12)
		var wing := dir.orthogonal()*5
		draw_polyline(PackedVector2Array([arrow-dir*6+wing,arrow,arrow-dir*6-wing]),rim,2,true)
	var knob := hub+deflection*(REIN_RADIUS-18)
	draw_circle(knob,19,INK,true,-1,true)
	draw_arc(knob,19,0,TAU,36,GOLD,2,true)
	diamond(knob,5,GOLD)
	var gallop := "PUSH TO GALLOP" if on_touch else "W / SPACE   GALLOP"
	var steer := "DRAG TO STEER" if on_touch else "A / D   STEER"
	plate(Rect2(hub.x-84,hub.y-104,168,29),Color("#192831e8"))
	words(gallop,hub.x-84,hub.y-84,14,PAPER,bold,HORIZONTAL_ALIGNMENT_CENTER,168)
	plate(Rect2(hub.x-84,hub.y+72,168,29),Color("#192831e8"))
	words(steer,hub.x-84,hub.y+92,14,PAPER,bold,HORIZONTAL_ALIGNMENT_CENTER,168)

func shield_sight():
	var d = g.duel
	var center := local_ui(g.shield_screen())
	var scale_m: float = g.aim_pixels_per_metre()/scale_ui
	var radius: float = d.SHIELD_RADIUS*scale_m
	var offset := Vector2(d.line_offset+d.side_aim[0],(d.target[0]-d.aim[0])*d.AIM_TRAVEL)
	var down: bool = d.release[0]>=0
	var aligned: bool = down and offset.length()<=d.SHIELD_RADIUS
	var tint := GREEN if aligned else GOLD
	draw_arc(center,radius,0,TAU,64,INK,5,true)
	draw_arc(center,radius,0,TAU,64,tint,2,true)
	draw_arc(center,d.CLEAN_RADIUS*scale_m,0,TAU,32,Color(tint,.84),1.5,true)
	if down:
		var tip := center+offset*scale_m
		for dir: Vector2 in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
			line(tip+dir*5,tip+dir*13,INK,5)
			line(tip+dir*5,tip+dir*13,PAPER,2.5)
		diamond(tip,2.5,PAPER)
	var prompt := "HOLD ON SHIELD" if on_touch else "HOLD CLICK ON SHIELD"
	if down:
		prompt = "ON TARGET" if aligned else "AIM AT SHIELD"
	var tag := Vector2(center.x,center.y-radius-28)
	plate(Rect2(tag.x-108,tag.y-14,216,30),Color("#192831ed"),tint)
	words(prompt,tag.x-108,tag.y+7,16,tint,bold,HORIZONTAL_ALIGNMENT_CENTER,216)

func live():
	var d = g.duel
	rider_panel(false)
	rider_panel(true)
	var cx := bounds.x*.5
	plate(Rect2(cx-102,17,204,72),Color("#192831ee"))
	centered("SUDDEN DEATH" if d.pass_no==4 else "PASS  %d  /  3" % d.pass_no,43,17,GOLD,bold)
	centered("%d   ◆   %d" % [d.points[0],d.points[1]],74,23,PAPER,TITLE)
	if g.phase == "follow":
		var hit: Dictionary = d.events.back().hits[0]
		plate(Rect2(cx-166,bounds.y*.22,332,65),INK)
		centered(hit.grade.to_upper()+" STRIKE",bounds.y*.22+42,30,GOLD,TITLE)
		return
	draw_reins()
	shield_sight()
	var eta: float = d.eta()
	if eta<2.5:
		var tell := "FRILL GUARD" if d.guard_ready() else "RIVAL CHARGING"
		var own := "SNAP READY" if d.snap_ready() else "RAPTOR STRIDE"
		plate(Rect2(cx-155,101,310,32),Color("#192831eb"))
		centered(own+"   /   "+tell,123,14,GOLD,bold)
	button("pause",Rect2(bounds.x-92,110,70,44),"Ⅱ")

func summary():
	var d = g.duel
	var e: Dictionary = d.events.back()
	var x := bounds.x/2-260
	var y := bounds.y/2-266
	draw_rect(Rect2(Vector2.ZERO,bounds),Color(.06,.10,.13,.50))
	plate(Rect2(x,y,520,532),Color("#1b2932fc"),GOLD)
	crown(Vector2(bounds.x*.5,y+43),1.10,GOLD)
	centered("PASS  %d   •   %s" % [d.pass_no,g.surface.to_upper()],y+86,16,GOLD,bold)
	var headline: String = d.result if d.result else e.hits[0].grade+" strike"
	centered(headline,y+151,49,PAPER,TITLE)
	centered(d.verdict if d.result else ("Sudden death ahead" if d.pass_no==3 else "Both knights stay mounted"),y+186,19,FADE)
	line(Vector2(x+33,y+210),Vector2(x+487,y+210),Color("#80785f"))
	for i in 2:
		var yy := y+244+i*82
		var color := Color("#e78a78") if i==0 else Color("#92b7ec")
		words("EMBER" if i==0 else "AZURE",x+36,yy,16,color,bold)
		words("%s  ·  +%d points" % [e.hits[i].grade,e.hits[i].points],x+148,yy,20,PAPER,bold)
		words("%s  ·  %s" % [e.hits[i].reason,e.beast[i]],x+36,yy+28,17,FADE)
		words("Seat %d → %d   /   Impact %d km/h" % [e.seat_before[i],e.seat_after[i],roundi(e.speed[i]*3.6)],x+36,yy+51,15,FADE)
	line(Vector2(x+33,y+388),Vector2(x+487,y+388),Color("#80785f"))
	centered("Lance points      %d  —  %d" % [d.points[0],d.points[1]],y+421,22,GOLD,TITLE)
	button("next",Rect2(x+36,y+447,295,56),"Ride again    ›" if d.result else "Next pass    ›",true)
	button("menu",Rect2(x+345,y+447,139,56),"The lists")
