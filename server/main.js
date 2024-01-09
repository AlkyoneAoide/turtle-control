const WebSockets = require('./libs/node_modules/ws/index.js')

const wss = new WebSockets.WebSocketServer({ port:8080 })

function main() {
	wss.on('connection', WebSocketConnected)
}

function WebSocketConnected(ws) {
	console.log("Client connected.")
	ws.on('error', console.error)
	ws.on('message', data => WebSocketMessage(ws, data))
	ws.send("Hello from websocket server")
}

function WebSocketMessage(ws, data) {
	console.log("Message from client websocket: " + data)
}

main()

