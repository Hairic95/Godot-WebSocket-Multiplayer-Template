import WebSocket = require("ws");
import { v4 } from "uuid";

import { ClientSocket } from "./models/clientSocket";
import { Message } from "./models/message";

import ProtocolHelper from "./handlers/protocol-handler";
import GameServerHandler from "./handlers/game-server-handler";

import configuration from "./configuration.json";

const gameServer = new GameServerHandler();

try {
  console.log("Starting Server on port " + configuration.port);
  const wss = new WebSocket.Server({ port: configuration.port });

  wss.on("connection", (ws) => {
    console.log("New device connected, creating new ClientSocket");

    const clientSocket: ClientSocket = new ClientSocket(ws, v4());

    gameServer.addClient(clientSocket);

    ws.on("message", (msg) => {
      const parsedMessage: Message = Message.fromString(msg.toString());

      ProtocolHelper.parseReceivingMessage(
        gameServer,
        clientSocket,
        parsedMessage
      );
    });

    ws.on("close", () => {
      gameServer.removeClient(clientSocket.id);
      console.log(`Connection closed for ${clientSocket.id}`);
    });

    ws.on("error", (err) => {
      gameServer.removeClient(clientSocket.id);
      console.log(`WS Error: Connection closed for ${clientSocket.id}`);
      ws.close();
    });
  });
} catch (err) {
  console.log(
    `An error had occurred while initalizing the application: ${err}`
  );
}
