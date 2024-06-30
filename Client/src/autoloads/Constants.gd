extends Node

# SERVER
#const Server_SecretKey = "YOUR_SECRET_KEY_HERE_NEVER_SHOW_IT_:)"
const Server_SecretKey = "b7524f5c-f4f1-4eeb-a1d7-96dcf23d4802"

# Change to your server url, currently set to the localhost
#const Server_WSUrl = "ws://127.0.0.1:6900"
const Server_WSUrl = "wss://game.hairiclilred.com"

# ACTIONS

const Action_Connect = "Connect"

const Action_GetUsers = "GetUsers"
const Action_PlayerJoin = "PlayerJoin"
const Action_PlayerLeft = "PlayerLeft"

const Action_GetLobbies = "GetLobbies"
const Action_GetOwnLobby = "GetOwnLobby"
const Action_CreateLobby = "CreateLobby"
const Action_JoinLobby = "JoinLobby"
const Action_LeaveLobby = "LeaveLobby"
const Action_LobbyChanged = "LobbyChanged"
const Action_GetUsersInLobby = "GetUsersInLobby"
const Action_MapSelected = "MapSelected"

const Action_GameStarted = "GameStarted"

const Action_MessageToLobby = "MessageToLobby"

# GENERIC MESSAGES

const GenericAction_EntityHardUpdatePosition = "EntityHardUpdatePosition"
const GenericAction_EntityUpdatePosition = "EntityUpdatePosition"
const GenericAction_EntityUpdateState = "EntityUpdateState"
const GenericAction_EntityMiscProcessData = "EntityMiscProcessData"
const GenericAction_EntityMiscOneOff = "EntityMiscOneOff"
const GenericAction_EntityDeath = "EntityDeath"
const GenericAction_EntitySpawn = "EntitySpawn"

# ENTITIES TYPES

const EntityType_Player = "Player"
const EntityType_Bullet = "Bullet"

var BulletCategories = {
	"regular": load("res://src/entities/bullet/NetworkBullet.tscn")
}

const BulletCategories_Regular = "regular"

func get_bullet_by_category(bullet_category):
	var result = Constants.BulletCategories[bullet_category]
	if result != null:
		return result.instance()
	else:
		return null
	# TODO when adding new bullet types
	#match(bullet_category):
