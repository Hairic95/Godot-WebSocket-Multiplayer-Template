import { v4 } from "uuid";
import { EAction } from "../base/enumerators";
import { ClientSocket } from "./clientSocket";
import { LobbyClient } from "./lobbyClient";
import { Message } from "./message";
import { LoggerHelper } from "../helpers/logger-helper";

export class Lobby {
  players: ClientSocket[];
  isGameStarted: boolean = false;
  id: String;

  constructor(id: String, players: ClientSocket[] = []) {
    try {
      this.players = players;
      this.id = id;
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while creating the Lobby: ${err}`
      );
    }
  }

  addPlayer(newPlayer: ClientSocket) {
    try {
      // Stop the player if the lobby if full
      if (this.players.length >= 2) {
        return false;
      }
      // Stop if the player is already in the lobby
      if (this.players.find((el) => el.id === newPlayer.id)) {
        return false;
      }
      // Add the player to the Lobby list
      this.players.push(newPlayer);

      return true;
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while adding a new player to the Lobby: ${err}`
      );
    }
  }

  removePlayer(idPlayer: String) {
    try {
      // remove the player from the list
      const index = this.players.findIndex((el) => el.id === idPlayer);
      if (index !== -1) {
        this.players.splice(index, 1);
      }

      const playerLeftMessage = new Message(EAction.PlayerLeft, {});

      this.players.forEach((el) =>
        el.socket.send(playerLeftMessage.toString())
      );
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while removing a player from the Lobby: ${err}`
      );
    }
  }
  get = () => {
    try {
      return {
        id: this.id,
        isGameStarted: this.isGameStarted,
        players: this.players.map(
          (el) => new LobbyClient(el.id, el.username, el.position, el.direction)
        ),
      };
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while getting the lobby: ${err}`
      );
    }
  };
}
