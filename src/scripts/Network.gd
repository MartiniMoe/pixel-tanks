extends Node

var server = "127.0.0.1"
var port = "3456"
var peer = null
var playernode = load("res://scenes/Player.tscn")

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	if OS.has_feature("Server") || "--server" in OS.get_cmdline_args():
		# This runs when launched by godot server oder headless binary
		# or when launched with --server
		create_server()
	
	if OS.get_environment("GAMEPORT") != "":
		port = OS.get_environment("GAMEPORT")
	if OS.get_environment("SERVER") != "":
		server = OS.get_environment("SERVER")
	
func _physics_process(delta):
	# poll for new data. Needed for websocket
	if peer != null:
		if peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			peer.poll()

func create_server():
	print("Creating server at " + str(server) + ":" + str(port))
	peer = WebSocketServer.new()
	peer.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(peer)

func join_server():
	peer = WebSocketClient.new()
	var server_url = "ws://" + str(server) + ":" + str(port)
	peer.connect_to_url(server_url, PoolStringArray(), true)
	get_tree().set_network_peer(peer)

func _server_disconnected():
	# Fires for client
	print("Disconnected from the server")
