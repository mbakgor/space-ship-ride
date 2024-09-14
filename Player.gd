extends RigidBody3D

## How much vertical force to apply when moving.
@export_range(750.0, 3000.0) var thrust: float = 1000.0 

## How much horizantal force to apply when moving.
@export_range(10.0, 500.0) var torque_thrust: float = 100.0

@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var fail_audio: AudioStreamPlayer = $FailAudio
@onready var engine_audio: AudioStreamPlayer3D = $EngineAudio

@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_right: GPUParticles3D = $BoosterParticlesRight
@onready var booster_particles_left: GPUParticles3D = $BoosterParticlesLeft

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


var is_transitioning: bool = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		if engine_audio.playing == false :
			engine_audio.play()
			booster_particles.emitting = true
	else:
		engine_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(00., 0.0, -torque_thrust * delta))
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false


func _on_body_entered(body: Node) -> void:
	print("Body entered: ", body.name)
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		
		if "Hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	fail_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.4)
	tween.tween_callback(get_tree().reload_current_scene)
	explosion_particles.emitting = true
	
func complete_level(next_level_file: String) -> void:
	success_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	success_particles.emitting = true
