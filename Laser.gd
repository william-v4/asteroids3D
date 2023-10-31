extends RigidBody
# constructor
func init(rotation):
	global_transform.basis.z = rotation
# runs continuously while it exists
func _process(delta):
	# move
	transform.origin.z -= 10 * delta
	transform.origin -= transform.basis.z.normalized()
	# delete if too far (and deduct score cause we're evil
	if global_transform.origin.length() > 200:
		get_parent().get_node("Rocket").score -= 1
		queue_free()
