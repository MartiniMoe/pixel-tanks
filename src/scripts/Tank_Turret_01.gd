extends Node2D

var can_shoot = true
var is_reloading = false

var bullet = load("res://scenes/Player_bullet.tscn")

func _ready():
	pass # Replace with function body.


func _on_Reload_timer_timeout():
	is_reloading = false
