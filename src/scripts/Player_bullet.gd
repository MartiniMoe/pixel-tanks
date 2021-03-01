extends Node2D

var velocity = Vector2(1, 0) # Direction?
var turret_rotation
var player_owner = 0

export var speed = 680
export var damage = 25

puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity = Vector2(0, 0)
puppet var puppet_rotation = 0

onready var initial_position = global_position

func _ready():
	# Make visible after rotated
	visible = false
	yield(get_tree(), "idle_frame")
	
	if is_network_master():
		velocity = velocity.rotated(turret_rotation)
		rotation = turret_rotation
		rset("puppet_velocity", velocity)
		rset("puppet_rotation", rotation)
		rset("puppet_position", global_position)
	
	visible = true

func _physics_process(delta):
	if is_network_master():
		global_position += velocity * speed * delta
	else:
		rotation = puppet_rotation
		global_position += puppet_velocity * speed * delta

func puppet_position_set(new_value):
	puppet_position = new_value
	global_position = puppet_position

sync func destroy():
	queue_free()

sync func damage(id):
	Persistent_nodes.get_node(id).damage(damage)

func _on_Destroy_timer_timeout():
	if is_network_master():
		rpc("destroy")

func _on_Hitbox_body_entered(body):
	if get_tree().is_network_server():
		print("entered body " + body.name)
		rpc("damage", body.name)
		rpc("destroy")
