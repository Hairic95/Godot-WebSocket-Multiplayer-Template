extends Node

var current_username : String = ""

var web_socket_client : WebSocketClient

var current_web_id = ""

# Web socket signals
signal web_socket_connected()
signal web_socket_disconnected()

# Web socket message signals
signal connection(success)

signal update_user_list(success, users)
signal player_join(id, position, direction)
signal player_left(webId)

signal update_lobby_list(success, lobbies)
signal get_own_lobby(lobby)
signal created_lobby(success)
signal joined_lobby(success)
signal left_lobby(success)
signal lobby_changed(lobby)

signal game_started()

signal player_position_update(data)
signal weapon_update(data)
signal shoot_bullet(data)

func _process(_delta):
	if _is_web_socket_connected() || _is_web_socket_connecting():
		web_socket_client.poll()

func connect_to_server(username : String):
	if _is_web_socket_connected() || _is_web_socket_connecting():
		web_socket_client.disconnect_from_host(1000, "Reconnecting")
	
	current_username = username
	
	web_socket_client = WebSocketClient.new()
	
	web_socket_client.connect("data_received", self, "data_received")
	web_socket_client.connect("connection_established", self, "connection_established")
	web_socket_client.connect("connection_closed", self, "connection_closed")
	web_socket_client.connect("connection_error", self, "connection_error")
	web_socket_client.connect("connection_failed", self, "connection_failed")
	
	
	web_socket_client.connect_to_url(Constants.Server_WSUrl)
	
	yield(get_tree().create_timer(4.0), "timeout")
	
	if !(_is_web_socket_connected()):
		web_socket_client.disconnect_from_host()
		emit_signal("web_socket_disconnected")
	

func data_received():
	var packet = web_socket_client.get_peer(1).get_packet().get_string_from_utf8()
	if !validate_json(packet):
		parse_message_received(parse_json(packet))
	else:
		print("Invalid message received")

func connection_established(_protocol):
	print("Connected! Sending Connect confirmation message")
	send_message_connect(current_username)
	emit_signal("web_socket_connected")

func connection_closed(was_clean_close):
	print("Web socket connection was closed")
	emit_signal("web_socket_disconnected")
func connection_error():
	print("Web socket connection was interrupted")
	emit_signal("web_socket_disconnected")
func connection_failed():
	print("Web socket connection failed")
	emit_signal("web_socket_disconnected")

func _send_message(action : String, payload : Dictionary):
	if _is_web_socket_connected():
		var message = {
			"action": action,
			"payload": payload
		}
		var parsed_message = to_json(message)
		web_socket_client.get_peer(1).put_packet(parsed_message.to_utf8())

func _is_web_socket_connected() -> bool:
	if web_socket_client:
		return web_socket_client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED
	return false

func _is_web_socket_connecting() -> bool:
	if web_socket_client:
		return web_socket_client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTING
	return false 

func send_message_connect(username : String, position: Vector2 = Vector2.ZERO, direction = Vector2.ZERO):
	if _is_web_socket_connected():
		_send_message(Constants.Action_Connect, {"secretKey" : Constants.Server_SecretKey, "username" : username})

func send_message_get_users():
	if _is_web_socket_connected():
		_send_message(Constants.Action_GetUsers,  {})

func send_message_get_lobbies():
	if _is_web_socket_connected():
		_send_message(Constants.Action_GetLobbies, {})

func send_message_get_own_lobby():
	if _is_web_socket_connected():
		_send_message(Constants.Action_GetOwnLobby, {})

func send_message_create_lobby():
	if _is_web_socket_connected():
		_send_message(Constants.Action_CreateLobby, {})

func send_message_join_lobby(idLobby : String):
	if _is_web_socket_connected():
		_send_message(Constants.Action_JoinLobby, { "id": idLobby })

func send_message_leave_lobby():
	if _is_web_socket_connected():
		_send_message(Constants.Action_LeaveLobby, {})

func send_message_to_lobby(messageContent):
	if _is_web_socket_connected():
		_send_message(Constants.Action_MessageToLobby, messageContent)

func parse_message_received(json_message):
	if json_message.has("action") && json_message.has("payload"):
		
		match(json_message.action):
			Constants.Action_Connect:
				if json_message.payload.has("success") &&  json_message.payload.has("webId"):
					current_web_id = json_message.payload.webId
					emit_signal("connection", json_message.payload.success)
					if !json_message.payload.success:
						web_socket_client.disconnect_from_host(1000, "Couldn't authenticate")
				else:
					emit_signal("connection", false)
					web_socket_client.disconnect_from_host(1000, "Couldn't authenticate")
			Constants.Action_GetUsers:
				if json_message.payload.has("success"):
					if json_message.payload.success:
						if json_message.payload.has("users"):
							emit_signal("update_user_list", json_message.payload.success, json_message.payload.users)
						else:
							emit_signal("update_user_list", false, [])
					else:
						emit_signal("update_user_list", json_message.payload.success, [])
				else:
					emit_signal("update_user_list", false, [])
			Constants.Action_GetLobbies:
				if json_message.payload.has("lobbies"):
					emit_signal("update_lobby_list", json_message.payload.lobbies)
			Constants.Action_GetOwnLobby:
				if json_message.payload.has("lobby"):
					emit_signal("get_own_lobby", json_message.payload.lobby)
			Constants.Action_PlayerJoin:
				if json_message.payload.has("id") && json_message.payload.has("position") && json_message.payload.has("direction"):
					emit_signal("player_join", json_message.payload.id, json_message.payload.position, json_message.payload.direction)
			Constants.Action_PlayerLeft:
				if json_message.payload.has("webId"):
					emit_signal("player_left", json_message.payload.webId)
			Constants.Action_CreateLobby:
				if json_message.payload.has("success"):
					emit_signal("created_lobby", json_message.payload.success)
			Constants.Action_JoinLobby:
				if json_message.payload.has("success"):
					emit_signal("joined_lobby", json_message.payload.success)
			Constants.Action_LeaveLobby:
				if json_message.payload.has("success"):
					emit_signal("left_lobby", json_message.payload.success)
			Constants.Action_LobbyChanged:
				if json_message.payload.has("lobby"):
					emit_signal("lobby_changed", json_message.payload.lobby)
			Constants.Action_MessageToLobby:
				if json_message.payload.has("type"):
					match (json_message.payload.type):
						Constants.GenericAction_UpdatePosition:
							if json_message.payload.has("position") && json_message.payload.has("direction"):
								emit_signal("player_position_update", json_message.payload)
						Constants.GenericAction_UpdateWeapon:
							if json_message.payload.has("rotation_direction"):
								emit_signal("weapon_update", json_message.payload)
						Constants.GenericAction_ShootBullet:
							if json_message.payload.has("owner_id") && json_message.payload.has("position") && json_message.payload.has("direction"):
								emit_signal("shoot_bullet", json_message.payload)
			Constants.Action_GameStarted:
				emit_signal("game_started")
