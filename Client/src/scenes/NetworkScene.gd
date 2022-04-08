extends Node2D

var lobby_widget_reference = load("res://src/ui/LobbyWidget.tscn")

func _ready():
	NetworkSocket.connect("connection", self, "on_connection")
	NetworkSocket.connect("web_socket_disconnected", self, "on_disconnection")
	
	NetworkSocket.connect("update_lobby_list", self, "update_lobby_list")
	NetworkSocket.connect("created_lobby", self, "created_lobby")
	NetworkSocket.connect("joined_lobby", self, "joined_lobby")
	NetworkSocket.connect("lobby_changed", self, "lobby_changed")
	NetworkSocket.connect("left_lobby", self, "left_lobby")
	
	NetworkSocket.connect("game_started", self, "game_started")

func _on_LineEdit_text_changed(new_text):
	$LoginSection/UI/Connect.disabled = new_text == ""

func _on_Connect_pressed():
	$LoginSection/UI.hide()
	$LoadingSection/Label.show()
	yield(get_tree().create_timer(.01), "timeout")
	NetworkSocket.connect_to_server($LoginSection/UI/LineEdit.text)

func on_connection(success):
	if success:
		$LoadingSection/Label.hide()
		$LobbySelectionSection/UI.show()
		NetworkSocket.send_message_get_lobbies()
	else:
		$LoadingSection/Label.hide()
		$LoginSection/UI.show()

func on_disconnection():
	$LobbySelectionSection/UI.hide()
	$LobbySection/Panel.hide()
	$LoadingSection/Label.hide()
	$LoginSection/UI.show()

func _on_CreateLobby_pressed():
	$LobbySelectionSection/UI.hide()
	$LoadingSection/Label.show()
	yield(get_tree().create_timer(.01), "timeout")
	NetworkSocket.send_message_create_lobby()

func lobby_join_attempt():
	yield(get_tree().create_timer(.01), "timeout")
	$LobbySelectionSection/UI.hide()
	$LoadingSection/Label.show()
	

func created_lobby(success):
	if success:
		$LobbySection/Panel/Label.text = "Waiting for opponent..."
		$LoadingSection/Label.hide()
		$LobbySection/Panel.show()

func joined_lobby(success):
	if success:
		$LobbySection/Panel/Label.text = "Waiting for opponent..."
		$LoadingSection/Label.hide()
		$LobbySection/Panel.show()

func lobby_changed(lobby):
	if lobby.players.size() > 1:
		$LobbySection/Panel/Label.text = "Opponent found!"
	else:
		$LobbySection/Panel/Label.text = "Waiting for opponent..."

func left_lobby(success):
	if success:
		$LobbySection/Panel.hide()
		$LobbySelectionSection/UI.show()
		NetworkSocket.send_message_get_lobbies()

func update_lobby_list(lobbies):
	for lobby in $LobbySelectionSection/UI/ScrollLobbies/Lobbies.get_children():
		lobby.queue_free()
	if lobbies.size() == 0:
		$LobbySelectionSection/UI/NoLobbiesLabel.show()
	else:
		$LobbySelectionSection/UI/NoLobbiesLabel.hide()
		for lobby in lobbies:
			var new_lobby_widget = lobby_widget_reference.instance()
			new_lobby_widget.init(lobby)
			new_lobby_widget.connect("lobby_joined", self, "lobby_join_attempt")
			$LobbySelectionSection/UI/ScrollLobbies/Lobbies.add_child(new_lobby_widget)


func _on_LeaveLobby_pressed():
	NetworkSocket.send_message_leave_lobby()

func game_started():
	EventBus.emit_signal("change_scene", "network_battle")
