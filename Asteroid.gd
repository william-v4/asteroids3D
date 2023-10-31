extends RigidBody
# how many times asteroid was split
var generation : int
var size
# asteroid scene
var asteroidscene = load("res://Asteroid.tscn")
# random movement vector
var movement : Vector3
var speed = 0.5
# constructor
func init(gen : int, loc : Vector3):
	# set param to global variable
	generation = gen
	# set size
	resize()
	# set position to parameter
	global_transform.origin = loc
	# set movement vector
	randdir()
	# start pinging
	$AudioStreamPlayer3D.stream = preload("res://sounds/ping.wav")
	$AudioStreamPlayer3D.set_unit_db(20)
	$AudioStreamPlayer3D.play()
# runs continuously while it exists
func _process(delta):
	# set random movement vector if stationary
	if global_transform.origin.distance_squared_to(movement) < 2:
		# new movement vector
		randdir()
	# move towards new vector
	global_transform.origin = global_transform.origin.linear_interpolate(movement, delta * speed)
# set size based on splits
func resize():
	size = 4 / pow(2, generation)
	global_scale(Vector3(size, size, size))

func _on_Area_body_entered(body):
	if "Laser" in body.name:
		# play explosion
		$AudioStreamPlayer3D.stream = preload("res://sounds/explosion.wav")
		$AudioStreamPlayer3D.set_unit_db(20)
		$AudioStreamPlayer3D.play()
		# delete laser
		body.free()
		# add to score
		get_parent().get_node("Rocket").score += 10
		# delete if too small
		if generation > 2:
			# play explosion
			$AudioStreamPlayer3D.stream = preload("res://sounds/explosion.wav")
			$AudioStreamPlayer3D.set_unit_db(20)
			$AudioStreamPlayer3D.play()
			# hydra
			var asteroid = asteroidscene.instance()
			get_parent().add_child(asteroid)
			asteroid.init(0, global_transform.origin)
			# random chance of powerup
			randomize()
			# pick random number
			var randnum = randi() % 10
			# pick another random number and see if they align
			randomize()
			var randnum2 = randi() % 10
			# see if the 2 number match up and if they do, call powerup and pass it to the function
			if randnum2 == randnum:
				get_parent().get_node("Rocket").powerup(randnum)
			get_parent().kills += 1
			queue_free()
		# split in half
		generation += 1
		resize()
		#duplicate
		for i in range(generation - 1):
			var asteroid = asteroidscene.instance()
			get_parent().add_child(asteroid)
			asteroid.init(generation, global_transform.origin)
# generate new movement vector
func randdir():
	# roll the dice
	randomize()
	# generate random vector within range
	movement = Vector3(rand_range(-100, 100), rand_range(-100, 100), rand_range(-100, 100))
