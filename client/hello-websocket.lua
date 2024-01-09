local ws = assert(http.websocket("ws://vps.rosie.gg"))

ws.send("Hello from minecraft")
print(ws.receive())
ws.close()

