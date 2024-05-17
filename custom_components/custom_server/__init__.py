"""custom server to toggle a helper input boolean"""

import socket
import asyncio
from homeassistant.helpers import entity
from homeassistant.helpers.entity import async_update_entity
from homeassistant.const import STATE_ON, STATE_OFF

DOMAIN = "socket_server"

async def async_setup_platform(hass, config, async_add_entities, discovery_info=None):
    server = CustomServer(hass, async_add_entities)
    await server.async_run_server()

class CustomServer:
    def __init__(self, hass, async_add_entities):
        self.hass = hass
        self.async_add_entities = async_add_entities

    async def async_run_server(self):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.bind(('localhost', 12345))
        server.listen(5)

        while True:
            client_socket, address = server.accept()
            await self.handle_client(client_socket)

    async def handle_client(self, client_socket):
        while True:
            data = client_socket.recv(1024).decode()
            if not data:
                break

            if data == 'turn on':
                await self.hass.helpers.entity.async_set_state('input_boolean.custom_server_switch', STATE_ON)
            elif data == 'turn off':
                await self.hass.helpers.entity.async_set_state('input_boolean.custom_server_switch', STATE_OFF)

        client_socket.close()
