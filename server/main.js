const WebSockets = require('./libs/node_modules/ws/index.js')

const wss = new WebSockets.WebSocketServer({ port:443 })

function main() {
	wss.on('connection', WebSocketConnected)
	wss.on('message', data => (WebSocketMessage(ws, data)))
}

function WebSocketConnected(ws) {
	ws.send("Hello from websocket server")
}

function WebSocketMessage(ws, data) {
	console.log("Message from client websocket: " + data)
}

main()

