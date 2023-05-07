import asyncio
import websockets
import json
import random

async def ofs_websocket_test():
    async with websockets.connect('ws://localhost:8080/ofs') as websocket:
        welcome_msg = await websocket.recv()
        print(welcome_msg)
        for i in range(10):
            await websocket.send(json.dumps({
                "type": "command",
                "name": "add_action",
                "data": {
                    "at": 0.5*i,
                    "pos": random.randint(0, 99)
                }
            }))

        await asyncio.sleep(1)

        for _ in range(1000):
            msg = await websocket.recv()
            print(msg)
            await websocket.send(json.dumps({
                "type": "command",
                "name": "user_data_01",
                "data": {
                    "source": "test",
                    "message": "Hello World"
                }
            }))


asyncio.get_event_loop().run_until_complete(ofs_websocket_test())
