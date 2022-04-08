extends Panel

var lobby_id = ""

signal lobby_joined()

func _ready():
	pass

func init(lobby_data):
	lobby_id = lobby_data.id
	if lobby_data.players.size() >= 1:
		$Player1Name.text = lobby_data.players[0].username
	else:
		$Player1Name.text = "---"
	if lobby_data.players.size() >= 2:
		$Player2Name.text = lobby_data.players[1].username
	else:
		$Player2Name.text = "---"
	$JoinLobby.disabled = lobby_data.isGameStarted || lobby_data.players.size() > 1

func _on_JoinLobby_pressed():
	emit_signal("lobby_joined")
	NetworkSocket.send_message_join_lobby(lobby_id)
