import { v4 } from "uuid";
import { EAction, EGenericAction } from "../base/enumerators";
import { ClientSocket } from "../models/clientSocket";
import { Lobby } from "../models/lobby";
import { Message } from "../models/message";

import GameServerHandler from "./game-server-handler";
import Constants from "../base/constants";

export default class ProtocolHelper {
  public static sendPlayerDisconnectToAll = (
    gameServer: GameServerHandler,
    playerDisconnectedId: String
  ) => {
    const playerDisconnectedMessage: Message = new Message(EAction.PlayerLeft, {
      webId: playerDisconnectedId,
    });
    try {
      gameServer.connectedClients.forEach((el) => {
        try {
          el.socket.send(playerDisconnectedMessage.toString());
        } catch (err: any) {}
      });
    } catch (err: any) {
      console.log(
        `ERR: An error had occurred while notifing a server disconnection: ${err}`
      );
    }
  };

  public static sendPlayerConnectionToAll = (
    gameServer: GameServerHandler,
    playerClient: ClientSocket
  ) => {
    const playerConnectedMessage: Message = new Message(EAction.PlayerJoin, {
      username: playerClient.username,
      id: playerClient.id,
      position: playerClient.position,
      direction: playerClient.direction,
    });
    try {
      gameServer.connectedClients.forEach((el) => {
        try {
          if (el.id != playerClient.id) {
            el.socket.send(playerConnectedMessage.toString());
          }
        } catch (err: any) {}
      });
    } catch (err: any) {
      console.log(
        `ERR: An error had occurred while notifing a server disconnection: ${err}`
      );
    }
  };

  public static parseReceivingMessage = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket,
    message: Message
  ) => {
    try {
      switch (message.action) {
        case EAction.Connect:
          ProtocolHelper.connectToServer(gameServer, clientSocket, message);
          break;
        case EAction.GetUsers:
          ProtocolHelper.sendUserList(gameServer, clientSocket);
          break;
        case EAction.GetLobbies:
          ProtocolHelper.sendLobbyList(gameServer, clientSocket);
          break;
        case EAction.GetOwnLobby:
          ProtocolHelper.sendLobby(gameServer, clientSocket);
          break;
        case EAction.CreateLobby:
          ProtocolHelper.createNewLobby(gameServer, clientSocket);
          break;
        case EAction.LeaveLobby:
          ProtocolHelper.leaveLobby(gameServer, clientSocket, message);
          break;
        case EAction.JoinLobby:
          ProtocolHelper.joinExistingLobby(gameServer, clientSocket, message);
          break;
        case EAction.MessageToLobby:
          ProtocolHelper.sendMessageToLobby(gameServer, clientSocket, message);
          break;
      }
    } catch (err) {
      console.log(`ERR: An error had occurred while parsing a message: ${err}`);
    }
  };

  private static connectToServer = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket,
    message: Message
  ) => {
    try {
      console.log("Connection attempt...");
      if (message.payload.secretKey === Constants.SecretKey) {
        clearTimeout(clientSocket.logoutTimeout);
        clientSocket.username = message.payload.username;
        console.log(`Connection confirmed for ${clientSocket.id}`);

        // Send response
        const connectMessage: Message = new Message(EAction.Connect, {
          success: true,
          webId: clientSocket.id,
        });
        clientSocket.socket.send(connectMessage.toString());

        // Notifies other clients
        gameServer.connectedClients.forEach((el) => {
          if (el !== clientSocket) {
            ProtocolHelper.sendUserList(gameServer, clientSocket);
          }
        });
      } else {
        clearTimeout(clientSocket.logoutTimeout);
        clientSocket.socket.close();
        return false;
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.connectToServer()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  public static sendUserList = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket
  ) => {
    try {
      const userListMessage: Message = new Message(EAction.GetUsers, {
        success: true,
        users: gameServer.connectedClients.map((el) => {
          return {
            username: el.username,
            id: el.id,
            position: el.position,
            direction: el.direction,
          };
        }),
      });
      clientSocket.socket.send(userListMessage.toString());
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendUserList()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  public static sendLobbyList = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket
  ) => {
    try {
      const lobbyListMessage: Message = new Message(EAction.GetLobbies, {
        success: true,
        lobbies: gameServer.getLobbies(),
      });
      clientSocket.socket.send(lobbyListMessage.toString());
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendLobbies()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  public static sendLobby = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket
  ) => {
    try {
      const lobby: Lobby = gameServer.getLobbyByPlayerId(clientSocket.id);
      if (!!lobby) {
        const message = new Message(EAction.GetOwnLobby, {
          lobby: lobby.get(),
        });
        clientSocket.socket.send(message.toString());
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendLobby()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  private static createNewLobby = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket
  ) => {
    try {
      if (gameServer.getLobbyByPlayerId(clientSocket.id)) {
        console.log(
          `WARN: Client ${clientSocket.id} is requesting a new lobby while inside a lobby.`
        );
        const invalidLobbyMessage = new Message(EAction.CreateLobby, {
          success: false,
        });
        clientSocket.socket.send(invalidLobbyMessage.toString());
        return false;
      } else {
        const newLobby = gameServer.createLobby();
        newLobby.addPlayer(clientSocket);

        const createLobbySuccessMessage = new Message(EAction.CreateLobby, {
          success: true,
        });
        clientSocket.socket.send(createLobbySuccessMessage.toString());
        // Alert all clients the changes to the lobbies
        gameServer.connectedClients.forEach((el) => {
          ProtocolHelper.sendLobbyList(gameServer, el);
        });
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.createNewLobby()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  private static leaveLobby = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket,
    message: Message
  ) => {
    try {
      const lobby = gameServer.getLobbyByPlayerId(clientSocket.id);
      if (!!lobby) {
        lobby.removePlayer(clientSocket.id);

        const createLobbySuccessMessage = new Message(EAction.LeaveLobby, {
          success: true,
        });
        clientSocket.socket.send(createLobbySuccessMessage.toString());
        // If the lobby is empty, erase it
        if (lobby.players.length === 0) {
          gameServer.removeLobby(lobby.id);
        } else {
          for (let el of lobby.players) {
            el.socket.send(
              new Message(EAction.PlayerLeft, {
                webId: clientSocket.id,
              }).toString()
            );
          }
        }
        // Alert all clients the changes to the lobbies
        gameServer.connectedClients.forEach((el) =>
          ProtocolHelper.sendLobbyList(gameServer, el)
        );
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.leaveLobby()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  private static joinExistingLobby = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket,
    message: Message
  ) => {
    try {
      const lobbyToJoin: Lobby | undefined = gameServer.getLobbyById(
        message.payload.id
      );
      if (!!lobbyToJoin) {
        if (lobbyToJoin.addPlayer(clientSocket)) {
          const joinLobbySuccessMessage = new Message(EAction.JoinLobby, {
            success: true,
            lobbyId: lobbyToJoin.id,
          });
          clientSocket.socket.send(joinLobbySuccessMessage.toString());
          // Alert all clients the changes to the lobbies
          gameServer.connectedClients.forEach((el) =>
            ProtocolHelper.sendLobbyList(gameServer, el)
          );
          lobbyToJoin.players.forEach((el) => {
            ProtocolHelper.sendLobbyChanged(el, lobbyToJoin);
          });

          if (lobbyToJoin.players.length >= 2 && !lobbyToJoin.isGameStarted) {
            setTimeout(() => {
              lobbyToJoin.isGameStarted = true;
              lobbyToJoin.players.forEach((el) => {
                ProtocolHelper.sendGameStarted(el);
              });
            }, 1000);
          }
        }
      } else {
        const joinLobbyFailureMessage = new Message(EAction.JoinLobby, {
          success: false,
        });
        clientSocket.socket.send(joinLobbyFailureMessage.toString());
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.joinExistingLobby()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };

  public static sendGameStarted(clientSocket: ClientSocket) {
    try {
      const lobbyListMessage: Message = new Message(EAction.GameStarted, {});
      clientSocket.socket.send(lobbyListMessage.toString());
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendGameStarted()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  }

  public static sendLobbyChanged(
    clientSocket: ClientSocket,
    lobbyToJoin: Lobby
  ) {
    try {
      const lobbyListMessage: Message = new Message(EAction.LobbyChanged, {
        lobby: lobbyToJoin.get(),
      });
      clientSocket.socket.send(lobbyListMessage.toString());
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendLobbyChanged()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  }

  private static sendMessageToLobby = (
    gameServer: GameServerHandler,
    clientSocket: ClientSocket,
    message: Message
  ) => {
    try {
      const lobby: Lobby = gameServer.getLobbyByPlayerId(clientSocket.id);
      if (!!lobby) {
        const lobbyMessage = new Message(
          EAction.MessageToLobby,
          message.payload
        );
        lobby.players.forEach((el) => {
          if (el !== clientSocket) {
            el.socket.send(lobbyMessage.toString());
          }
        });
      }
    } catch (err: any) {
      console.log(
        `[ProtocolHelper.sendMessageToLobby()] ERR: An error had occurred while parsing a message: ${err}`
      );
    }
  };
}
