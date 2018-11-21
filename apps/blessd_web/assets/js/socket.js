// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket;

if (window.currentUserToken != "") {
  socket = new Socket("/socket", {params: {token: window.currentUserToken}});
  socket.connect();
}

export default socket
