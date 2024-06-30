import { v4 } from "uuid";
import { ClientSocket } from "../models/clientSocket";
import { Lobby } from "../models/lobby";
import ProtocolHelper from "./protocol-handler";

export default class GameServerHandler {
  public connectedClients: ClientSocket[] = [];
  public lobbies: Lobby[] = [];

  public addClient(clientSocket: ClientSocket) {
    try {
      this.connectedClients.push(clientSocket);

      ProtocolHelper.sendPlayerConnectionToAll(this, clientSocket);
    } catch (err: any) {
      console.log(
        `[GameServerHandler.addClient()] ERR: An error had occurred while adding a client: ${err}`
      );
      throw err;
    }
  }

  public removeClient(clientId: String) {
    try {
      // 1) If the player was in a lobby then remove the player from it
      for (const lobby of this.lobbies) {
        for (const player of lobby.players) {
          if (player.id === clientId) {
            lobby.removePlayer(clientId);
            if (lobby.players.length === 0) {
              this.removeLobby(lobby.id);

              // Alert all clients the changes to the lobbies
              this.connectedClients.forEach((el) =>
                ProtocolHelper.sendLobbyList(this, el)
              );
            }
          }
        }
      }
      // 2) Remove the client from the connected client list
      const clientIndex: number = this.connectedClients.findIndex(
        (el) => el.id === clientId
      );
      if (clientIndex > -1) {
        this.connectedClients.splice(clientIndex, 1);
      } else {
        console.log(
          `[GameServerHandler.removeClient()] WARN: attempted to remove an inexistant client`
        );
      }
      ProtocolHelper.sendPlayerDisconnectToAll(this, clientId);
    } catch (err: any) {
      console.log(
        `[GameServerHandler.removeClient()] ERR: An error had occurred while removing a client: ${err}`
      );
      throw err;
    }
  }

  public createLobby(): Lobby {
    try {
      const newLobby = new Lobby(v4());
      this.lobbies.push(newLobby);
      return newLobby;
    } catch (err: any) {
      console.log(
        `[GameServerHandler.createLobby()] ERR: An error had occurred while creating a new lobby: ${err}`
      );
      throw err;
    }
  }

  public getLobbyById(lobbyId: String): Lobby | undefined {
    try {
      return this.lobbies.find((el) => el.id === lobbyId);
    } catch (err: any) {
      console.log(
        `[GameServerHandler.getLobbyById()] ERR: An error had occurred while searching for a lobby by its id: ${err}`
      );
      throw err;
    }
  }

  public getLobbyByPlayerId(clientId: String): Lobby | undefined {
    try {
      return this.lobbies.find(
        (el) => el.players.findIndex((player) => player.id === clientId) > -1
      );
    } catch (err: any) {
      console.log(
        `[GameServerHandler.getLobbyById()] ERR: An error had occurred while searching for a lobby by one of its player: ${err}`
      );
      throw err;
    }
  }

  public getLobbies() {
    return this.lobbies.map((el) => el.get());
  }

  public removeLobby(lobbyId: String) {
    try {
      const index = this.lobbies.findIndex((el) => el.id === lobbyId);
      if (index !== -1) {
        this.lobbies.splice(index, 1);
      }
    } catch (err: any) {
      console.log(
        `[GameServerHandler.removeLobby()] ERR: An error had occurred while removing a lobby: ${err}`
      );
      throw err;
    }
  }
}
