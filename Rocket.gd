extends KinematicBody
var speed = 0.01
# mouse sensitivity
var mousesens = 5
# movement vector
var direction : Vector3
# mouse movement
var mousemotion : Vector2
# joystick direction
var stickdir : Vector2
# joystick sensitivity
var sticksens = 2
# laser scene
var laserscene = preload("res://Laser.tscn")
# asteroid count
var asteroids : int
var score : int
# proton wave scene
var wavescene = preload("res://Protonwave.tscn")
# invincibility powerup
var invincible : bool
# gameover screen
var deathscreen = preload("res://Gameover.tscn")
var ded : bool
# run at start
func _ready():
	# reset score counter
	$View/Control/Score.text = "0"
	# reset powerup display
	$View/Control/Powerups.text = ""
	# spawn protection
	powerup(0)
# runs continuously (delta for interpolation)
func _process(delta):
	# get joystick movement
	stickdir = Input.get_vector("camleft", "camright", "camup", "camdown")
	# rotate player based on stick direction
	rotate_y(deg2rad(stickdir.x * sticksens))
	$View.rotate_x(deg2rad(clamp(stickdir.y * sticksens, -90, 90)))
	# convert keyboard/joystick input into direction vector
	if Input.is_action_pressed("forward"): 
		direction.z -= speed
		direction -= transform.basis.z.normalized()
	if Input.is_action_pressed("back"): 
		direction.z += speed
		direction += transform.basis.z.normalized()
	if Input.is_action_pressed("left"): 
		direction.x -= speed
		direction -= transform.basis.x.normalized()
	if Input.is_action_pressed("right"): 
		direction.x += speed
		direction += transform.basis.x.normalized()
	if Input.is_action_pressed("up"): 
		direction.y += speed
		direction += transform.basis.y.normalized()
	if Input.is_action_pressed("down"): 
		direction.y -= speed
		direction -= transform.basis.y.normalized()
	# actually move the player
	global_transform.origin = direction
	# dynamic crosshair
	if $View/Camera/RayCast.get_collider() and "Asteroid" in $View/Camera/RayCast.get_collider().name and !ded:
		$View/Control/CenterContainer/Crosshair.modulate = Color(0, 1, 0)
	else:
		if !ded:
			$View/Control/CenterContainer/Crosshair.modulate = Color(1, 1, 1)
	# shoot on click/trigger
	if Input.is_action_just_pressed("shoot") && !ded:
		# pew pew
		$AudioStreamPlayer3D.play()
		# for extra immersion
		Input.start_joy_vibration(0, 0.5, 0, 0.1)
		# prepare instance of laser
		var laser = laserscene.instance()
		# make sure it shoots in our direction
		laser.transform.origin = $View/Camera/RayCast.global_transform.origin
		laser.transform.basis = $View/Camera/RayCast.global_transform.basis
		# spawn laser
		get_parent().add_child(laser)
	# update asteroid counter
	asteroids = 0
	for x in get_parent().get_children():
		if "Asteroid" in x.name:
			asteroids += 1
	$View/Control/Asteroidmeter/CenterContainer/Label.text = str(asteroids)
	# interpolate and update score
	if int($View/Control/Score.text) < score:
		$View/Control/Score.text = str(int($View/Control/Score.text) + 1)
	else: if int($View/Control/Score.text) > score:
		$View/Control/Score.text = str(int($View/Control/Score.text) - 1)
	# deploy proton wave and check if cooldown done
	if Input.is_action_just_pressed("wave") and $WaveCooldown.is_stopped() and !ded:
		# add instance of proton wave
		var wave = wavescene.instance()
		get_parent().add_child(wave)
		# move it to current position
		wave.global_transform.origin = global_transform.origin
		# start 3 second cooldown
		$WaveCooldown.start(3)
	# update text if invincibility powerup activated
	if invincible:
		if $Invincibility.time_left >= 10:
			$View/Control/Powerups.text = "Invincibillity 00:" + str(stepify($Invincibility.time_left, 0.1))
		elif $Invincibility.time_left < 10:
			$View/Control/Powerups.text = "Invincibillity 00:0" + str(stepify($Invincibility.time_left, 0.1))
	# delete powerup text once done
	if $Invincibility.is_stopped():
		invincible = false
		$View/Control/Powerups.text = ""
	# check collisions
	for x in $Area.get_overlapping_bodies():
		# check if asteroid and make sure powerup not active
		if "Asteroid" in x.name and !invincible and !ded:
			# for ultra immersive experience
			Input.start_joy_vibration(0, 1, 1, 1)
			# game over
			ded = true
			var scoreboard = deathscreen.instance()
			scoreboard.init(get_parent().kills, score)
			get_parent().add_child(scoreboard)
			get_node("View/Control/CenterContainer/Crosshair").free()
			

# runs whenever inputs are received
func _input(event):
	if event is InputEventMouseMotion:
		# get mouse movement
		mousemotion = -event.relative.normalized()
		# left and right
		rotate_y(deg2rad(mousemotion.x * mousesens))
		# up and down
		$View.rotate_x(deg2rad(clamp(mousemotion.y, -90, 90)))
		
# called by asteroid if powerup
func powerup(sec):
	$Invincibility.start(sec + 10)
	invincible = true
