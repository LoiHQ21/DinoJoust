extends SceneTree
## Drive the scene through its actual input handlers using two independent touches.
var failures := 0
func expect(ok: bool, label: String):
	if not ok:
		failures += 1
		push_error(label)

func key(code: Key, pressed := true) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = pressed
	return e

func touch(index: int, p: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = p
	e.pressed = pressed
	return e

func _initialize():
	call_deferred("run")

func run():
	var g = load("res://arena.tscn").instantiate()
	root.add_child(g)
	g.audio_on = false
	await process_frame
	expect(g.phase=="lists","Boot at the lists")
	g._input(key(KEY_ENTER))
	expect(g.phase=="charge","Enter starts match")
	g.set_physics_process(false)
	g._input(key(KEY_ESCAPE))
	expect(g.paused,"Escape pauses charge")
	g._input(key(KEY_ENTER))
	g.hud.layout()
	var left: Vector2 = g.hud.origin+g.hud.rein_center()*g.hud.scale_ui
	var right: Vector2 = g.shield_screen()
	g._input(touch(2,left,true))
	g._input(touch(7,right,true))
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = left+Vector2(-32,-48)*g.hud.scale_ui
	g._input(drag)
	for i in 10:
		g._physics_process(1.0/60)
	expect(g.duel.line_offset<0 and g.duel.speed[0]>g.duel.RAPTOR.cruise,"Reins steer and accelerate the mount")
	expect(g.aiming() and g.duel.release[0]>=0,"Shield finger lowers lance while steering")
	g._input(touch(2,left,false))
	expect(g.reins()==Vector2.ZERO and g.aiming(),"Lifting reins leaves lance lowered")
	drag.index = 7
	drag.position = right+Vector2(60,-40)*g.hud.scale_ui
	g._input(drag)
	g._physics_process(1.0/60)
	expect(g.duel.side_aim[0]>.25 and g.duel.aim[0]>g.duel.target[0],"Drag moves lance across both shield axes")
	g._input(touch(7,drag.position,false))
	g._physics_process(1.0/60)
	expect(g.duel.release[0]<0 and not g.aiming(),"Lift raises lance and allows a fresh aim")
	g._input(touch(7,g.shield_screen(),true))
	while g.phase=="charge":
		drag.position = g.shield_screen()
		g._input(drag)
		g._physics_process(1.0/60)
	expect(g.phase=="follow" and g.duel.events[0].hits[0].grade=="Clean","Clean pass from mapped input")
	g._input(key(KEY_ENTER))
	expect(g.phase=="summary","Skip follow-through")
	g._input(key(KEY_ENTER))
	expect(g.duel.pass_no==2 and g.reins()==Vector2.ZERO and not g.aiming() and g.duel.release[0]<0,"Next pass clears stale input")
	while g.duel.result=="":
		while g.phase=="charge":
			g._physics_process(1.0/60)
		g._input(key(KEY_ENTER))
		if g.duel.result=="":
			g._input(key(KEY_ENTER))
	expect(g.phase=="summary","Match result reached")
	g._input(key(KEY_ENTER))
	expect(g.phase=="charge" and g.duel.pass_no==1 and g.duel.seat==[100,100],"Rematch resets match")
	print("Scene input, concurrent touch, contact, summary, rematch. Failures: ",failures)
	quit(1 if failures else 0)
