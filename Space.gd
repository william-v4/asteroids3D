extends Spatial
# pause state see line
var paused : bool
# asteroid
var asteroidscene = preload("res://Asteroid.tscn")
# player
var playerscene = preload("res://Rocket.tscn")
# minimum value for random asteroid generation
var randmin : int = -100
# maximum value for random asteroid generation
var randmax : int = 100
# kill count
var kills : int
# runs as soon as project is run
func _ready():
	# capture mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# spawn player
	add_child(playerscene.instance())
	
	# make 3 asteroids
	for i in range(3):
		# make instance of asteroid
		var asteroid = asteroidscene.instance()
		add_child(asteroid)
		# roll the dice
		var rand = RandomNumberGenerator.new()
		rand.randomize()
		# random position
		asteroid.init(0, Vector3(rand.randf_range(randmin, randmax), rand.randf_range(randmin, randmax), rand.randf_range(randmin, randmax)))
# runs continuosly
func _process(delta):
	# pause game on escape
	if Input.is_action_just_pressed("pause") and !paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		paused = true
	# and resume when window clicked
	if Input.is_mouse_button_pressed(1) and paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		paused = false;
