extends Control

onready var multiplayer_config_ui = $Multiplayer_configure
onready var client_name = $Multiplayer_configure/Client_name

var playernode = load("res://scenes/Player.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

func _player_connected(id):
	# Fires for client and server
	print("Player " + str(id) + " has connected")
	
	instance_player(id)

func _player_disconnected(id):
	# Fires for client and server
	print("Player " + str(id) + " has disconnected")
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()

func _connected_to_server():
	# Fires for client
	print("Successfully connected to the server")
	# Load local player
	instance_player(get_tree().get_network_unique_id())

func _on_Join_game_pressed():
	if client_name.text != "":
		multiplayer_config_ui.hide()
		Network.join_server()

func instance_player(id):	
	# Get the id of the RPC sender.
	if id != 1:
		# Do not instanciate a player for the server
		print("Registering Player #" + str(id))
		
		# Load remote player
		var player_instance = Global.instance_node_at_location(playernode, Players, Vector2(rand_range(0, 1920), rand_range(0, 1080)))
		player_instance.set_name(str(id))
		player_instance.set_network_master(id)
