import WebSocket = require("ws");
import { Vector2 } from "./vector2";
import { LoggerHelper } from "../helpers/logger-helper";

export class LobbyClient {
  username: String;
  id: String;
  position: Vector2;
  direction: Vector2;

  constructor(
    id: String,
    username: String,
    position: Vector2 = new Vector2(0, 0),
    direction = new Vector2(0, 0)
  ) {
    try {
      this.id = id;
      this.username = username;
      this.position = position;
      this.direction = direction;
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while creating the Client Socket: ${err}`
      );
    }
  }
}
