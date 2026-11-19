extends Node
## Small original synthesized fanfare, hoofbeats and contact cues.
var clips := {}
var voices: Array[AudioStreamPlayer] = []
var next := 0
func _ready():
	for i in 5:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	clips.hoof = make([72.0],.075,.34,true)
	clips.horn = make([293.66,392.0,493.88],.125,.22,false)
	clips.final_horn = make([392.0,392.0,523.25],.18,.28,false)
	clips.strap = make([587.33,98.0],.08,.42,true)
	clips.hit = make([164.81,523.25],.115,.42,true)
	clips.miss = make([220.0,164.81],.11,.17,false)
	clips.win = make([392.0,493.88,587.33,783.99],.15,.24,false)

func make(notes: Array, length: float, volume: float, percussive: bool) -> AudioStreamWAV:
	const RATE := 22050
	var count := roundi(RATE*length)
	var data := PackedByteArray()
	data.resize(count*notes.size()*2)
	for j in notes.size():
		for i in count:
			var t := i/float(RATE)
			var phase: float = TAU*notes[j]*t
			var env := minf(1.0,t/.014)*pow(1.0-i/float(count),1.8)
			var sample := sin(phase)+.25*sin(phase*2)+.12*sin(phase*3)
			if percussive:
				sample += .4*sin(phase*3.27+sin(phase*1.7)*2)
			data.encode_s16(2*(j*count+i),roundi(sample*env*volume*16000))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = RATE
	clip.data = data
	return clip

func cue(key: String):
	voices[next].stream = clips[key]
	voices[next].play()
	next = (next+1)%voices.size()
