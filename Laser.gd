extends RayCast3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@export var interval: float = 5.0
@onready var laser: RayCast3D = $"."

func _ready() -> void:
	laserUpdate()

func _process(delta: float) -> void:
	if laser.enabled:
		var cast_point
		force_raycast_update()
		
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("Player"):  
				collider.crash_sequence()  
			
			cast_point = to_local(get_collision_point())
			mesh_instance_3d.mesh.height = cast_point.y
			mesh_instance_3d.position.y = cast_point.y / 2

func laserUpdate():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_interval(2.0)
	tween.tween_callback(Callable(self, "close_laser"))
	tween.tween_interval(2.0)
	tween.tween_callback(Callable(self, "open_laser"))

func close_laser() -> void:
	laser.enabled = false
	mesh_instance_3d.visible = false

func open_laser() -> void:
	laser.enabled = true
	mesh_instance_3d.visible = true
