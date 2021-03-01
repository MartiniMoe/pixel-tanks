extends Node

var server = "127.0.0.1"
var port = "3456"
var peer = null
var playernode = load("res://scenes/Player.tscn")

# To have all object names (bullets...) use increasing ids
var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	# Read environment file
	var envfile = File.new()
	if envfile.file_exists("res://.env"):
		print("Using environment file")
		envfile.open("res://.env", File.READ)
		var content = envfile.get_as_text()
		envfile.close()
		for line in content.split("\n", false):
			if line.begins_with("GAMEPORT="):
				port = line.trim_prefix("GAMEPORT=")
			elif line.begins_with("SERVER="):
				server = line.trim_prefix("SERVER=")
			else:
				print("Ignoring config line: " + line)
	else:
		print("No environment file found, using defaults")
	
	print("Using server " + server)
	print("Using port " + port)
	
	if OS.has_feature("Server") || "--server" in OS.get_cmdline_args():
		# This runs when launched by godot server oder headless binary
		# or when launched with --server
		create_server()
	
func _physics_process(delta):
	# poll for new data. Needed for websocket
	if peer != null:
		if peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			peer.poll()

func create_server():
	print("Creating server")
	peer = WebSocketServer.new()
	peer.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(peer)

func join_server():
	peer = WebSocketClient.new()
	var server_url = ""
	if OS.has_feature("standalone"):
		# Client always connects to port 80/game because of Traefik reverseproxy!
		print("Running standalone")
		server_url = "wss://" + str(server) + "/game"
	else:
		print("Running from editor!")
		server_url = "ws://" + str(server) + ":" + str(port)
	print("Connecting to " + server_url)
	peer.connect_to_url(server_url, PoolStringArray(), true)
	get_tree().set_network_peer(peer)

func _server_disconnected():
	# Fires for client
	print("Disconnected from the server")

func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
