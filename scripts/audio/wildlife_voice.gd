extends AudioStreamPlayer3D

## Generates short, low-cost original tonal wildlife calls at runtime.
## These are placeholder sound designs, not recordings of real animals.
@export var species_id := "rabbit"
@export var minimum_interval := 8.0
@export var maximum_interval := 19.0

var _rng := RandomNumberGenerator.new()
var _next_call := 5.0

func _ready() -> void:
	_rng.randomize()
	volume_db = -13.0
	max_distance = 28.0
	unit_size = 7.0
	panning_strength = 0.35
	_next_call = _rng.randf_range(3.0, 9.0)

func _process(delta: float) -> void:
	if playing:
		return
	_next_call -= delta
	if _next_call > 0.0:
		return
	_next_call = _rng.randf_range(minimum_interval, maximum_interval)
	stream = _build_call()
	play()

func _build_call() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.34
	var sample_count := int(sample_rate * duration)
	var base_frequency := 520.0
	match species_id:
		"deer":
			base_frequency = 310.0
		"gull":
			base_frequency = 760.0
		_:
			base_frequency = 880.0
	base_frequency *= _rng.randf_range(0.88, 1.12)

	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var progress := float(i) / float(sample_count)
		var envelope := minf(progress * 12.0, 1.0) * minf((1.0 - progress) * 7.0, 1.0)
		var sweep := 1.0 + 0.12 * sin(TAU * 3.0 * t)
		var fundamental := sin(TAU * base_frequency * sweep * t)
		var harmonic := sin(TAU * base_frequency * 2.03 * t) * 0.24
		var texture := _rng.randf_range(-0.10, 0.10)
		var sample_value := clampf((fundamental * 0.68 + harmonic + texture) * envelope * 0.25, -1.0, 1.0)
		var pcm := int(sample_value * 32767.0)
		bytes[i * 2] = pcm & 0xff
		bytes[i * 2 + 1] = (pcm >> 8) & 0xff

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.data = bytes
	return audio
