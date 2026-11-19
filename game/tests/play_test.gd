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
	# Start near the centre seam on the left and well away from the shield on the right.
	var size: Vector2 = g.hud.size
	var left := size*Vector2(.49,.31)
	var right := size*Vector2(.86,.78)
	g._input(touch(2,left,true))
	g._input(touch(7,right,true))
	expect(g.rein_origin==left and g.aim_origin==right,"Both controls anchor at touch-down")
	expect(g.reins()==Vector2.ZERO and g.lance_point()==Vector2(0,-.25),"Touch-down never moves reins or aim")
	g._input(touch(9,size*Vector2(.15,.81),true))
	expect(g.drive_finger==2 and g.aim_finger==7,"Extra fingers cannot steal a control")
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = left+Vector2(32,-48)*g.hud.scale_ui
	g._input(drag)
	for i in 10:
		g._physics_process(1.0/60)
	expect(g.duel.line_offset>0 and g.duel.speed[0]>g.duel.RAPTOR.cruise,"Reins retain ownership across the seam")
	g._input(touch(2,drag.position,false))
	expect(g.drive_finger<0 and g.reins()==Vector2.ZERO and g.aiming(),"Releasing reins leaves lance independent")
	var start_aim: Vector2 = g.lance_point()
	drag.index = 7
	drag.position = right+Vector2(20,-26)*g.hud.scale_ui
	g._input(drag)
	var displaced: Vector2 = g.lance_point()
	expect(displaced.x>start_aim.x and displaced.y>start_aim.y,"Off-centre thumb moves lance on both axes")
	for i in 8:
		g._physics_process(1.0/60)
	expect(g.lance_point()==displaced,"Holding the thumb still preserves the angle")
	var cancel := touch(7,drag.position,false)
	cancel.canceled = true
	g._input(cancel)
	expect(g.aim_finger<0 and not g.aiming(),"Cancellation removes the aim pad")
	var grip := size*Vector2(.79,.66)
	g._input(touch(4,grip,true))
	expect(g.lance_point()==displaced,"Re-gripping elsewhere preserves lance direction")
	var goal := Vector2(-g.duel.line_offset/g.duel.SIDE_REACH,g.duel.target[0])
	var correction := goal-displaced
	drag.index = 4
	drag.position = grip + Vector2(correction.x,-correction.y)*g.AIM_SENSITIVITY*g.hud.scale_ui
	g._input(drag)
	expect(drag.position.x>size.x*.7,"Aim without approaching the opponent on screen")
	while g.phase=="charge":
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
