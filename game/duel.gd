extends RefCounted
## Authoritative state. All distances are metres, input is sampled once per 60 Hz tick.
const DT := 1.0 / 60.0
const START := 58.0
const TIP_FORWARD := 3.77
const PLATE_FORWARD := 0.42
const REACH := TIP_FORWARD + PLATE_FORWARD
const LANE := 1.05
const TIP_BASE := 2.27
const AIM_TRAVEL := 0.82
const SIDE_REACH := 1.0
const CLEAN_RADIUS := 0.15
const SHIELD_RADIUS := 0.38
const TERRAIN := {
	"Royal Stone": {"accel": 1.0, "grip": 1.0, "recoil": 1.1},
	"Rainsoft Clay": {"accel": 0.68, "grip": 0.74, "recoil": 0.89},
}
const RAPTOR := {"name":"Velociraptor", "cruise":4.4, "top":12.2, "accel":2.9}
const FRILL := {"name":"Protoceratops", "cruise":4.2, "top":10.2, "accel":2.55}
var seed_value: int
var surface: String
var pass_no := 0
var tick := 0
var seat := [100, 100]
var points := [0, 0]
var speed := [0.0, 0.0]
var travel := [0.0, 0.0]
var aim := [0.0, 0.0]
var line_offset := 0.0 # Metres from the centre of the player’s lane.
var side_aim := [0.0, 0.0] # Lateral lance reach, in world X.
var release := [-1, -1]
var target := [0.0, 0.0] # Shield heights, indexed by the attacking rider.
var events: Array = []
var trace: Array = []
var history: Array = []
var last_input: Array = []
var done := false
var result := ""
var verdict := ""
var ai_lead: float
var ai_error: float
var ai_pace: float

func _init(match_seed := 1234, ground := "Royal Stone"):
	seed_value = match_seed
	surface = ground
	next_pass()

func next_pass():
	pass_no += 1
	tick = 0
	speed = [RAPTOR.cruise, FRILL.cruise]
	travel = [0.0, 0.0]
	aim = [-0.25, 0.0]
	line_offset = 0.0
	side_aim = [0.0, 0.0]
	release = [-1, -1]
	done = false
	trace = []
	last_input = []
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + pass_no * 997
	target = [rng.randf_range(0.02, 0.36), rng.randf_range(-0.12, 0.16)]
	ai_lead = rng.randf_range(0.20, 0.65)
	ai_error = rng.randf_range(-0.36, 0.36)
	ai_pace = rng.randf_range(0.53, 0.92)

func gap() -> float:
	return START * 2.0 - travel[0] - travel[1] - REACH

func eta() -> float:
	return maxf(0.0, gap()) / (speed[0] + speed[1])

func snap_ready() -> bool:
	return line_offset >= -.40 and speed[0] >= 5.4 and speed[0] <= 8.8

func guard_ready() -> bool:
	return line_offset >= -.40 and speed[1] <= 7.75

func move_mount(i: int, mount: Dictionary, throttle: float):
	var goal := lerpf(mount.cruise, mount.top, throttle)
	var rate: float = mount.accel * TERRAIN[surface].accel if speed[i]<goal else 2.2 * TERRAIN[surface].grip
	speed[i] = move_toward(speed[i], goal, rate * DT)
	travel[i] += speed[i] * DT

func step(reins: Vector2, point: Vector2, lowered: bool):
	if done:
		return
	tick += 1
	# Quantize before both recording and simulation so input logs reproduce a pass.
	reins = reins.clamp(Vector2(-1,0),Vector2.ONE).snappedf(.001)
	point = point.clamp(-Vector2.ONE,Vector2.ONE).snappedf(.001)
	var sample := [reins.x, reins.y, point.x, point.y, lowered]
	if sample != last_input:
		trace.append([tick] + sample)
		last_input = sample
	line_offset = clampf(line_offset + reins.x * 1.7 * TERRAIN[surface].grip * DT, -1.75, .42)
	side_aim[0] = point.x * SIDE_REACH
	aim[0] = point.y
	if lowered and release[0]<0:
		release[0] = tick
	elif not lowered:
		release[0] = -1
	if release[1] < 0:
		aim[1] = target[1] + ai_error
		side_aim[1] = clampf(line_offset,-SIDE_REACH,SIDE_REACH)
		if eta() <= ai_lead:
			release[1] = tick
	move_mount(0, RAPTOR, reins.y)
	move_mount(1, FRILL, 1.0 if speed[1]<FRILL.top*ai_pace else 0.0)
	if gap() <= 0.0:
		resolve_contact()

# The front plane of each rider target is crossed once, even on a high-speed tick.
# At crossing, both lances extend from their inner gauntlet into the opposite lane.
func target_position(attacker: int) -> Vector3:
	var z: float = -START+travel[1]+PLATE_FORWARD if attacker==0 else START-travel[0]-PLATE_FORWARD
	return Vector3(LANE if attacker==0 else -LANE+line_offset,TIP_BASE+target[attacker]*AIM_TRAVEL,z)

func contact_tip(attacker: int) -> Vector3:
	var tip := target_position(attacker)
	tip.x = LANE+line_offset+side_aim[0] if attacker==0 else -LANE+side_aim[1]
	tip.y = TIP_BASE+aim[attacker]*AIM_TRAVEL
	return tip

func strike(i: int) -> Dictionary:
	var lead: float = (tick - release[i]) * DT
	var miss_by: float = contact_tip(i).distance_to(target_position(i))
	var grade := "Miss"
	var reason := "Outside shield"
	if release[i] < 0:
		reason = "Lance was raised"
	elif i==1 and lead > 0.86:
		reason = "Released too early"
	elif i==1 and lead < 0.10:
		reason = "Released too late"
	elif miss_by <= CLEAN_RADIUS and (i==0 or (lead >= 0.22 and lead <= 0.58)):
		grade = "Clean"
		reason = "Shield centre"
	elif miss_by <= SHIELD_RADIUS:
		grade = "Glance"
		reason = "Shield rim"
	return {"grade":grade, "reason":reason, "points":{"Clean":2,"Glance":1,"Miss":0}[grade],
		"commit_tick":release[i], "aim":aim[i], "target":target[i], "error_m":miss_by, "line_offset_m":line_offset, "side_aim_m":side_aim[i],
		"contact_world":Array(PackedFloat32Array([contact_tip(i).x,contact_tip(i).y,contact_tip(i).z]))}

func resolve_contact():
	done = true
	var hits := [strike(0), strike(1)]
	var before := seat.duplicate()
	var snap := snap_ready()
	var guard := guard_ready()
	var beast := ["Predator snap" if snap else "Ran through", "Frill guard" if guard else "Ran through"]
	for i in 2:
		var base: float = [0.0, 16.0, 37.0][hits[i].points]
		var damage := roundi(base * (0.72 + speed[i] / 27.0) * TERRAIN[surface].recoil)
		if i == 0:
			if guard:
				damage = maxi(0, damage - 6)
			if snap:
				damage += 3 if guard else 10
		elif guard:
			damage += 3
		seat[1-i] = maxi(0, seat[1-i] - damage)
		points[i] += hits[i].points
	if seat.min() == 0:
		verdict = "Double unseat" if seat.max() == 0 else "Unseated"
		result = "Draw" if seat.max() == 0 else ("Victory" if seat[1] == 0 else "Defeat")
	elif pass_no >= 3:
		if points[0] != points[1]:
			verdict = "Lance points"
			result = "Victory" if points[0] > points[1] else "Defeat"
		elif pass_no == 4:
			verdict = "Remaining stability"
			result = "Draw" if seat[0] == seat[1] else ("Victory" if seat[0] > seat[1] else "Defeat")
	events.append({"pass":pass_no, "tick":tick, "hits":hits, "beast":beast, "speed":speed.duplicate(),
		"seat_before":before, "seat_after":seat.duplicate(), "points":points.duplicate(), "verdict":verdict, "result":result})
	history.append(trace.duplicate(true))

func recording() -> Dictionary:
	return {"version":2, "seed":seed_value, "terrain":surface, "mounts":[RAPTOR.name, FRILL.name],
		"frequency":60, "passes":history, "contacts":events}
