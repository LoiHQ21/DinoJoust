extends Node3D
const Duel = preload("res://duel.gd")
const Rider = preload("res://art/competitor.gd")
const Court = preload("res://art/court.gd")
const Overlay = preload("res://hud.gd")
const Sound = preload("res://art/sound.gd")
const G = preload("res://art/geometry.gd")
var field := Court.new()
var player := Rider.new()
var enemy := Rider.new()
var cam := Camera3D.new()
var hud := Overlay.new()
var sound := Sound.new()
var duel: Duel
var phase := "lists"
var surface := "Royal Stone"
var paused := false
var audio_on := true
var low_detail := OS.has_feature("web") or OS.has_feature("mobile")
var shadows: Array[MeshInstance3D] = []
var debug := false
var touch_reins := Vector2.ZERO
var aim_position := Vector2.ZERO
var mouse_aim := false
var drive_finger := -1
var aim_finger := -1
var held_keys := {}
var follow := 0.0
var end_positions: Array[Vector3] = []
var sparks: Array[MeshInstance3D] = []
var spark_origin := Vector3.ZERO
var next_hoof := 0.0
var menu_time := 0.0

func _ready():
	add_child(field)
	field.build()
	add_child(player)
	player.build(true)
	add_child(enemy)
	enemy.build(false)
	for mount in [player,enemy]:
		var shadow := G.gem(mount,Vector3(0,.025,.08),Vector3(.81,.012,1.70),"987858")
		shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shadows.append(shadow)
	apply_graphics()
	add_child(cam)
	cam.current = true
	cam.far = 270
	add_child(sound)
	for i in 12:
		var spark := G.gem(self,Vector3.ZERO,Vector3(.035,.035,.24),"ffda83" if i%2 else "fff5cd")
		spark.visible = false
		sparks.append(spark)
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.g = self
	menu()

func apply_graphics():
	field.sunlight.shadow_enabled = not low_detail
	get_viewport().scaling_3d_scale = .75 if low_detail else 1.0
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED if low_detail else Viewport.MSAA_2X
	for shadow in shadows:
		shadow.visible = low_detail

func menu():
	phase = "lists"
	paused = false
	reset_input()
	for spark in sparks:
		spark.hide()
	player.position = Vector3(-.8,0,.2)
	player.trunk.rotation.z = 0
	player.rotation.y = -.22
	enemy.position = Vector3(1.6,0,-11.4)
	enemy.rotation.y = PI-.22
	cam.fov = 38
	menu_time = 0
	menu_camera()
	field.ground(surface)

func menu_camera():
	var p := player.position
	cam.position = p+Vector3(6.9+sin(menu_time*.16)*.20,2.20,-5.5)
	cam.look_at(p+Vector3(1.34,1.40,1.65),Vector3.UP)

func start_match(match_seed := -1):
	duel = Duel.new(randi_range(1,1000000) if match_seed<0 else match_seed,surface)
	start_pass()

func start_pass():
	phase = "charge"
	paused = false
	reset_input()
	aim_position = Vector2.ZERO
	enemy.target_plate.position.y = Duel.TIP_BASE + duel.target[0]*Duel.AIM_TRAVEL - enemy.rider_base
	player.target_plate.position.y = Duel.TIP_BASE + duel.target[1]*Duel.AIM_TRAVEL - player.rider_base
	follow = 0
	next_hoof = .25
	player.rotation.y = 0
	enemy.rotation.y = PI
	cam.fov = 55
	for spark in sparks:
		spark.hide()
	update_positions()
	chase_camera()
	play("horn")

func reset_input():
	held_keys.clear()
	drive_finger = -1
	aim_finger = -1
	mouse_aim = false
	touch_reins = Vector2.ZERO

func reins() -> Vector2:
	if drive_finger >= 0:
		return Vector2(touch_reins.x,maxf(0,-touch_reins.y))
	var right := held_keys.has(KEY_D) or held_keys.has(KEY_RIGHT)
	var left := held_keys.has(KEY_A) or held_keys.has(KEY_LEFT)
	var sprint := held_keys.has(KEY_W) or held_keys.has(KEY_UP) or held_keys.has(KEY_SPACE)
	return Vector2(int(right)-int(left),float(sprint))

func aiming() -> bool:
	return mouse_aim or aim_finger>=0

func shield_screen() -> Vector2:
	return cam.unproject_position(enemy_shield())

func aim_pixels_per_metre() -> float:
	# Magnify the distant shield so its rim stays reachable with a thumb.
	var projected := cam.unproject_position(enemy_shield()+Vector3.RIGHT)
	return maxf(112.0*hud.scale_ui,projected.distance_to(shield_screen()))

func lance_point() -> Vector2:
	if not aiming():
		return Vector2(0,-.25)
	var offset := (aim_position-shield_screen())/aim_pixels_per_metre()
	return Vector2((offset.x-duel.line_offset)/Duel.SIDE_REACH,
		duel.target[0]-offset.y/Duel.AIM_TRAVEL).clamp(-Vector2.ONE,Vector2.ONE)

func enemy_shield() -> Vector3:
	return duel.target_position(0)

func update_positions():
	player.position = Vector3(-Duel.LANE+duel.line_offset,0,Duel.START-duel.travel[0])
	enemy.position = Vector3(Duel.LANE,0,-Duel.START+duel.travel[1])

func chase_camera():
	var anchor := player.position-Vector3.RIGHT*duel.line_offset*.55
	cam.position = anchor+Vector3(1.47,3.22,5.25)
	cam.look_at(anchor+Vector3(.97,1.70,-7.3),Vector3.UP)

func play(tone: String):
	if audio_on:
		sound.cue(tone)

func _physics_process(dt: float):
	if paused:
		return
	if phase == "charge":
		duel.step(reins(),lance_point(),aiming())
		update_positions()
		chase_camera()
		next_hoof -= dt
		if next_hoof <= 0:
			play("hoof")
			next_hoof = 3.2/duel.speed[0]
		if duel.done:
			phase = "follow"
			end_positions = [player.position,enemy.position]
			spark_origin = enemy_shield() if duel.events.back().hits[0].points>0 else player.position+Vector3.UP*2.25
			reset_input()
			var contact: bool = duel.events.back().hits[0].points+duel.events.back().hits[1].points>0
			play("hit" if contact else "miss")
			save_recording()
	elif phase=="follow":
		follow += dt
		var t := maxf(0,follow-.14)
		player.position = end_positions[0]+Vector3.FORWARD*duel.speed[0]*t*.48
		enemy.position = end_positions[1]+Vector3.BACK*duel.speed[1]*t*.48
		var focus := end_positions[0].lerp(end_positions[1],.50)
		var blend := smoothstep(.05,.95,follow)
		var before := end_positions[0]+Vector3(1.47,3.22,5.25)
		cam.position = before.lerp(focus+Vector3(7.8,2.8,4.6),blend)
		cam.look_at((end_positions[0]+Vector3(.97,1.70,-7.3)).lerp(focus+Vector3.UP*1.45,blend),Vector3.UP)
		update_sparks()
		if follow >= 1.55:
			show_summary()

func update_sparks():
	var contact: bool = duel.events.back().hits[0].points+duel.events.back().hits[1].points>0
	for i in sparks.size():
		var spark := sparks[i]
		spark.visible = contact and follow<.42
		if spark.visible:
			var angle := i*TAU/sparks.size()
			var v := Vector3(cos(angle),sin(angle),sin(i*7.3)*.72).normalized()
			spark.position = spark_origin+v*(.09+follow*3.3)
			spark.look_at(spark.position+v,Vector3.UP)
			spark.scale = Vector3(.035,.035,.25)*maxf(.1,1-follow/.48)

func show_summary():
	phase = "summary"
	for spark in sparks:
		spark.hide()
	if duel.result=="Victory":
		play("win")

func save_recording():
	var file := FileAccess.open("user://last_joust.json",FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(duel.recording()))

func _process(dt: float):
	if not paused:
		if phase=="lists":
			menu_time += dt
			menu_camera()
			player.pose(dt,0,.30,false,0,false)
			enemy.pose(dt,0,.40,false,0,false)
		elif phase in ["charge","follow"]:
			var reaction := clampf(follow/1.3,0,1) if phase=="follow" else 0.0
			player.pose(dt,duel.speed[0],duel.aim[0],duel.eta()<1.15 and duel.snap_ready(),reaction,duel.seat[0]==0,duel.side_aim[0],duel.release[0]>=0)
			player.trunk.rotation.z = -reins().x*.09
			enemy.pose(dt,duel.speed[1],duel.aim[1],duel.eta()<1.15 and duel.guard_ready(),reaction,duel.seat[1]==0,-duel.side_aim[1],duel.release[1]>=0 or duel.eta()<1.5)
	hud.queue_redraw()

func action(id: String):
	match id:
		"graphics":
			low_detail = not low_detail
			apply_graphics()
		"audio":
			audio_on = not audio_on
		"menu":
			menu()
		"terrain":
			surface = "Rainsoft Clay" if surface=="Royal Stone" else "Royal Stone"
			field.ground(surface)
		"start":
			start_match()
		"next":
			if duel.result:
				start_match()
			else:
				duel.next_pass()
				start_pass()
		"pause","resume":
			paused = not paused
			reset_input()

func _notification(what: int):
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and phase=="charge":
		paused = true
		reset_input()

func set_touch_reins(pos: Vector2):
	touch_reins = ((hud.local_ui(pos)-hud.rein_center())/hud.REIN_RADIUS).limit_length(1.0)

func _input(event: InputEvent):
	if not hud.is_inside_tree():
		return
	if event is InputEventKey:
		if event.echo:
			return
		if event.pressed:
			match event.keycode:
				KEY_F3:
					debug = not debug
				KEY_ESCAPE:
					if phase=="charge":
						action("resume" if paused else "pause")
					elif phase=="follow":
						show_summary()
					elif phase=="summary":
						menu()
				KEY_ENTER,KEY_KP_ENTER:
					if paused:
						action("resume")
					elif phase=="lists":
						action("start")
					elif phase=="summary":
						action("next")
					elif phase=="follow":
						show_summary()
				_:
					if phase=="charge" and not paused:
						held_keys[event.keycode] = true
		else:
			held_keys.erase(event.keycode)
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			var id := hud.action_at(event.position)
			if id:
				action(id)
			elif phase=="charge" and not paused:
				mouse_aim = true
				aim_position = event.position
		elif mouse_aim:
			mouse_aim = false
	elif event is InputEventMouseMotion:
		hud.pointer = event.position
		if mouse_aim:
			aim_position = event.position
	elif event is InputEventScreenTouch:
		hud.on_touch = true
		if event.pressed:
			var id := hud.action_at(event.position)
			if id:
				action(id)
			elif phase=="charge" and not paused:
				if hud.local_ui(event.position).distance_to(hud.rein_center())<=hud.REIN_RADIUS+28:
					if drive_finger<0:
						drive_finger = event.index
						set_touch_reins(event.position)
				elif aim_finger<0:
					aim_finger = event.index
					aim_position = event.position
		elif event.index==drive_finger:
			drive_finger = -1
			touch_reins = Vector2.ZERO
		elif event.index==aim_finger:
			aim_finger = -1
	elif event is InputEventScreenDrag:
		if event.index==drive_finger:
			set_touch_reins(event.position)
		elif event.index==aim_finger:
			aim_position = event.position
