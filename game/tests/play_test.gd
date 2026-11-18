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
	var left := Vector2(100,500)
	var right := Vector2(900,420)
	g._input(touch(2,left,true))
	g._input(touch(7,right,true))
	var drag := InputEventScreenDrag.new()
	drag.index = 7
	drag.relative.y = -(g.duel.target[0]-g.height)*g.hud.size.y/3.5
	g._input(drag)
	expect(g.driving() and absf(g.height-g.duel.target[0])<.001,"Concurrent touch aim and throttle")
	g._input(touch(2,left,false))
	expect(not g.driving() and not g.pending_commit,"Throttle release leaves lance held")
	g._input(key(KEY_SPACE))
	while g.duel.eta()>.40:
		g._physics_process(1.0/60)
	g._input(touch(7,right,false))
	while g.phase=="charge":
		g._physics_process(1.0/60)
	expect(g.phase=="follow" and g.duel.events[0].hits[0].grade=="Clean","Clean pass from mapped input")
	g._input(key(KEY_ENTER))
	expect(g.phase=="summary","Skip follow-through")
	g._input(key(KEY_ENTER))
	expect(g.duel.pass_no==2 and not g.driving() and g.duel.release[0]<0,"Next pass clears stale input")
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
