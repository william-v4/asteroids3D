extends Area
var alpha : float
# proton wave growth speed
var growth: int = 1
# run when proton wave summoned
func _ready():
	# play proton wave sound
	$AudioStreamPlayer3D.play()
# runs continuously
func _process(delta):
	# incrementally grow proton wave
	if scale < Vector3(50, 50, 50):
		scale += Vector3(growth, growth, growth)
		# and increase opacity
		alpha += 0.01
		$MeshInstance.mesh.surface_get_material(0).set_shader_param("alpha", alpha)
		# remove asteroids in range
		for x in get_overlapping_bodies():
			if "Asteroid" in x.name:
				print(x)
				x.free()
	# and then self destruct when done
	else: 
		queue_free()
