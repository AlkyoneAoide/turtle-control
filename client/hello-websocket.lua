ws = assert(http.websocket("ws://vps.rosie.gg:8080"))

local res, resIsBin = ws.receive()
print(res)

ws.send("Hello from Minecraft!")

ws.close()

