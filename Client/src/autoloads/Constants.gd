extends Node

# SERVER

const Server_SecretKey = "YOUR_SECRET_KEY_HERE_NEVER_SHOW_IT_:)"

# Change to your server url, currently set to the localhost
const Server_WSUrl = "ws://127.0.0.1:6900"

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

const Action_GameStarted = "GameStarted"

const Action_MessageToLobby = "MessageToLobby"

# GENERIC MESSAGES

const GenericAction_UpdatePosition = "UpdatePosition"
const GenericAction_UpdateWeapon = "UpdateWeapon"
const GenericAction_ShootBullet = "ShootBullet"
