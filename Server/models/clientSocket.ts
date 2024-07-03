import WebSocket = require("ws");
import { Vector2 } from "./vector2";
import { LoggerHelper } from "../helpers/logger-helper";

export class ClientSocket {
  username: String;
  socket: WebSocket;
  id: String;
  position: Vector2;
  direction: Vector2;
  logoutTimeout: NodeJS.Timeout;

  constructor(
    socket: WebSocket,
    id: String,
    position: Vector2 = new Vector2(0, 0),
    direction = new Vector2(0, 0)
  ) {
    try {
      this.socket = socket;
      this.id = id;
      this.position = position;
      this.direction = direction;

      this.logoutTimeout = setTimeout(() => {
        LoggerHelper.logWarn(`Closing socket ${this.id}. No validation.`);
        this.socket.close();
      }, 4 * 1000);
    } catch (err) {
      LoggerHelper.logError(
        `An error had occurred while creating the Client Socket: ${err}`
      );
    }
  }
}
