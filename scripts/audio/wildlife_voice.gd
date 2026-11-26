extends AudioStreamPlayer3D
## Procedural animal calls; add OGG recordings in res://audio/wildlife/ to override.
@export var species_id := "rabbit"
@export var minimum_interval := 8.0
@export var maximum_interval := 19.0
var _rng:=RandomNumberGenerator.new()
var _timer:=4.0
func _ready()->void:
	_rng.randomize()
	volume_db=-15.0
	max_distance=32.0
	unit_size=7.0
	_timer=_rng.randf_range(2,8)
func _exit_tree() -> void:
	_stop_voice()


func _stop_voice() -> void:
	stop()
	stream = null


func _process(delta:float)->void:
	if playing:return
	_timer-=delta
	if _timer>0:return
	_timer=_rng.randf_range(minimum_interval,maximum_interval)
	var path:="res://audio/wildlife/%s_call.ogg" % species_id
	stream=load(path) if ResourceLoader.exists(path) else _make_call()
	play()
func _make_call()->AudioStreamWAV:
	var rate:=22050
	var duration:=0.42
	var pitch:=620.0
	var sweep:=0.16
	var noise_level:=0.05
	match species_id:
		"deer": pitch=330.0; duration=0.48; sweep=-0.22
		"gull": pitch=820.0; duration=0.52; sweep=0.34; noise_level=0.16
		"dog": pitch=185.0; duration=0.48; sweep=-0.08; noise_level=0.30
		"cat": pitch=520.0; duration=0.62; sweep=-0.48
		"chicken": pitch=430.0; duration=0.40; sweep=-0.20; noise_level=0.18
		"cow": pitch=135.0; duration=0.88; sweep=-0.16; noise_level=0.08
		"horse": pitch=410.0; duration=0.72; sweep=0.45; noise_level=0.22
		_: pitch=900.0; duration=0.22; sweep=0.28
	var count:=int(rate*duration)
	var bytes:=PackedByteArray()
	bytes.resize(count*2)
	var phase:=0.0
	for i in range(count):
		var t:=float(i)/float(rate)
		var p:=float(i)/float(count)
		var env:=pow(maxf(0.0,sin(PI*p)),0.7)
		if species_id=="dog":
			env*=1.0 if (p<0.36 or (p>0.56 and p<0.90)) else 0.0
		elif species_id=="chicken":
			env*=1.0 if (p<0.24 or (p>0.38 and p<0.62) or p>0.76) else 0.0
		phase+=TAU*pitch*(1.0+sweep*p)*(1.0+0.035*sin(TAU*5*t))/float(rate)
		var tone:=sin(phase)*0.72+sin(phase*2.02)*0.28+sin(phase*3.01)*0.10
		var sample:=clampf((tone+_rng.randf_range(-1,1)*noise_level)*env*0.28,-1,1)
		var pcm:=int(sample*32767)
		bytes[i*2]=pcm&0xff
		bytes[i*2+1]=(pcm>>8)&0xff
	var wav:=AudioStreamWAV.new()
	wav.format=AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate=rate
	wav.stereo=false
	wav.data=bytes
	return wav
