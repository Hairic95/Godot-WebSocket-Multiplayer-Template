export enum EAction {
  Connect = "Connect",

  GetUsers = "GetUsers",
  PlayerJoin = "PlayerJoin",
  PlayerLeft = "PlayerLeft",

  GetLobbies = "GetLobbies",
  GetOwnLobby = "GetOwnLobby",
  CreateLobby = "CreateLobby",
  JoinLobby = "JoinLobby",
  LobbyChanged = "LobbyChanged",
  LeaveLobby = "LeaveLobby",

  GameStarted = "GameStarted",

  MessageToLobby = "MessageToLobby",
}

export enum EGenericAction {
  UpdatePlayerPosition = "UpdatePlayerPosition",
  UpdateWeapon = "UpdateWeapon",
}
