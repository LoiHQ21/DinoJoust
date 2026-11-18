extends SceneTree
const Duel = preload("res://duel.gd")
var failures := 0
var wins := 0
var losses := 0

func check(value: bool, label: String):
	if not value:
		push_error(label)
		failures += 1

func pass_with(d: Duel, lead: float, offset: float, pace := 12.2):
	while not d.done:
		d.step(d.speed[0]<pace, d.target[0]+offset, d.release[0]<0 and d.eta()<=lead)
	return d.events.back()

func _initialize():
	var stone := Duel.new()
	var clay := Duel.new(1234,"Rainsoft Clay")
	for i in 70:
		stone.step(true,0,false)
		clay.step(true,0,false)
	check(stone.speed[0]>clay.speed[0], "Clay changes acceleration")
	var fast: float = stone.speed[0]
	stone.step(false,0,false)
	check(stone.speed[0]<fast, "Coasting reduces speed")
	var clean = pass_with(Duel.new(),.40,0.0)
	var glance = pass_with(Duel.new(),.40,.30)
	var miss = pass_with(Duel.new(),1.8,0.0)
	check(clean.hits[0].grade=="Clean" and glance.hits[0].grade=="Glance" and miss.hits[0].grade=="Miss","All three contact grades")
	check(clean.seat_after[1]<glance.seat_after[1] and glance.seat_after[1]<miss.seat_after[1],"Stability follows lance quality")
	var snap = pass_with(Duel.new(),-1,0,7.2)
	check(snap.beast[0]=="Predator snap" and snap.hits[0].points==0 and snap.seat_after[1]<100,"Beast contact without lance points")
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
					pass_with(d,.40 if skill else -1.0,0)
					if d.result=="":
						d.next_pass()
				if skill and d.result=="Victory": wins += 1
				if not skill and d.result=="Defeat": losses += 1
				verify_replay(d.recording())
	check(wins>0 and losses>0,"Win and loss reachable")
	var tie := Duel.new()
	tie.pass_no = 3
	tie.resolve_contact()
	check(tie.result=="","Equal lance points grant sudden death")
	tie.next_pass()
	tie.resolve_contact()
	check(tie.result!="","Sudden death terminates")
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
			d.step(input[1], input[2]/1000.0, input[3])
		check(d.done and d.events.back()==record.contacts[p],"Recorded fixed-step contact diverged")
