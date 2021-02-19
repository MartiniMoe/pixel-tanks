extends KinematicBody2D

const speed = 200
const rotation_speed = 1.5
var direction = Vector2(0, 0)

# For the remote players
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_rotation = 0.0
puppet var puppet_direction = Vector2()

func _ready():
	pass

func _physics_process(delta):
	if is_network_master():
		var rotation_input = rotation_speed * delta * (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
		var drive_input = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
		# Mirror rotation when driving backwards
		if drive_input < 1:
			rotate(rotation_input)
		else:
			rotate(rotation_input * -1)
		
		# Get global front facing direction
		var orientation_global = (to_global(Vector2(0, 1)) - global_position)
		
		direction = Vector2(drive_input * orientation_global).normalized()
		
		move_and_slide(direction * speed)
	else:
		# Make rotation look smooth when player lags without tween
		rotation = lerp(rotation, puppet_rotation, delta * 8)
		# Predict movement if nothing has been received
		if not $Tween.is_active():
			move_and_slide(puppet_direction * speed)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	# Make it look smooth when player lags
	#                           object, property,        initial val,     final_val,       duration
	$Tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$Tween.start()

func _on_Network_tick_rate_timeout():
	# This is not in physics_process to not send 60 packets per second
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_direction", direction)
		rset_unreliable("puppet_rotation", rotation)
