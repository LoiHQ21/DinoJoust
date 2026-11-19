extends SceneTree
const Duel = preload("res://duel.gd")
var failures := 0
var wins := 0
var losses := 0

func check(value: bool, label: String):
	if not value:
		push_error(label)
		failures += 1

func pass_with(d: Duel, lowered: bool, height_offset: float, pace := 12.2, side_offset := 0.0):
	while not d.done:
		var reins := Vector2(0,float(d.speed[0]<pace))
		d.step(reins,Vector2(side_offset,d.target[0]+height_offset),lowered)
	return d.events.back()

func _initialize():
	var stone := Duel.new()
	var clay := Duel.new(1234,"Rainsoft Clay")
	for i in 70:
		stone.step(Vector2.DOWN,Vector2.ZERO,false)
		clay.step(Vector2.DOWN,Vector2.ZERO,false)
	check(stone.speed[0]>clay.speed[0], "Clay changes acceleration")
	var fast: float = stone.speed[0]
	stone.step(Vector2.ZERO,Vector2.ZERO,false)
	check(stone.speed[0]<fast, "Coasting reduces speed")
	var clean = pass_with(Duel.new(),true,0.0)
	var glance = pass_with(Duel.new(),true,.30)
	var miss = pass_with(Duel.new(),true,0.0,12.2,.65)
	check(clean.hits[0].grade=="Clean" and glance.hits[0].grade=="Glance" and miss.hits[0].grade=="Miss","All three contact grades")
	check(clean.seat_after[1]<glance.seat_after[1] and glance.seat_after[1]<miss.seat_after[1],"Stability follows lance quality")
	var wide := Duel.new()
	for i in 120:
		wide.step(Vector2.LEFT,Vector2(1,wide.target[0]),true)
	check(wide.line_offset==-1.75 and not wide.snap_ready(),"Wide line stays in the arena and leaves beast contact range")
	var wide_hit = pass_with(wide,true,0,7,1)
	check(wide_hit.hits[0].grade=="Miss","Steering outside lance reach causes a miss")
	verify_replay(wide.recording())
	var snap = pass_with(Duel.new(),false,0,7.2)
	check(snap.beast[0]=="Predator snap" and not snap.hits[0].landed and snap.seat_after[1]<100,"Beast contact with raised lance")
	check(clean.beast[0]=="Ran through","Sprint suppresses snap")
	var guard := Duel.new()
	guard.speed=[7.5,6.5]
	guard.resolve_contact()
	var open := Duel.new()
	open.speed=[7.5,9.0]
	open.resolve_contact()
	check(guard.seat[1]>open.seat[1],"Frill guard absorbs snap")
	for seed_number in range(1,25):
		for ground in Duel.TERRAIN:
			for skill in [false,true]:
				var d := Duel.new(seed_number,ground)
				while d.result=="":
					pass_with(d,skill,0)
					if d.result=="":
						d.next_pass()
				if skill and d.result=="Victory": wins += 1
				if not skill and d.result=="Defeat": losses += 1
				check(d.pass_no in [2,3],"Duel resolves in two or three passes")
				verify_replay(d.recording())
	check(wins>0 and losses>0,"Win and loss reachable")
	var loss_by_pass := Duel.new()
	for i in Duel.MAX_PASSES:
		loss_by_pass.resolve_contact()
		if i<2:
			check(loss_by_pass.result=="","Both mounted before the last pass")
		loss_by_pass.next_pass()
	check(loss_by_pass.result=="Defeat" and loss_by_pass.pass_no==3,"Defender keeps crown after three misses")
	var final := Duel.new()
	final.pass_no = 3
	var last = pass_with(final,true,0)
	check(last.hits[0].grade=="Clean" and final.seat[1]==0,"Final clean can unseat an untouched defender")
	var both := Duel.new()
	both.pass_no = 3
	both.tick = 100
	both.release = [80,80]
	both.aim = both.target.duplicate()
	both.aim[1] += .05
	both.resolve_contact()
	check(both.seat==[0,0] and both.result=="Victory","Closer lance wins a double fall")
	var two := Duel.new(123,"Rainsoft Clay")
	pass_with(two,true,0,4.4)
	check(two.seat[1]>0 and two.seat[1]<=Duel.STRAP_BREAK,"First clean breaks a strap")
	two.next_pass()
	pass_with(two,true,0,4.4)
	check(two.seat[1]==0 and two.result!="" and two.pass_no==2,"Two clean hits end the duel")
	print("96 matches replayed. Accurate wins: %d/48. Uncommitted losses: %d/48. Failures: %d" % [wins,losses,failures])
	quit(1 if failures else 0)

func verify_replay(record: Dictionary):
	var d := Duel.new(record.seed,record.terrain)
	for p in record.passes.size():
		if p>0:
			d.next_pass()
		var samples: Array = record.passes[p]
		var idx := 0
		var input: Array = samples[0]
		while not d.done and d.tick<3000:
			if idx<samples.size() and samples[idx][0]==d.tick+1:
				input = samples[idx]
				idx += 1
			d.step(Vector2(input[1],input[2]),Vector2(input[3],input[4]),input[5])
		check(d.done and d.events.back()==record.contacts[p],"Recorded fixed-step contact diverged")
