"""custom server"""

import asyncio
import json
import socket
import logging
from homeassistant.helpers import discovery
from homeassistant.helpers.entity import Entity

DOMAIN = "custom_server"

logger = logging.getLogger(__name__)

logger.info("reading server config file")
with open("/config/custom_components/custom_server/serverConfig.json", 'r') as file:
    data = file.read()
config_dict = json.loads(data)
logger.info("Config Dictionary: \n%s", json.dumps(config_dict, indent=4))

async def async_setup(hass, config):
    # Start your socket server in a background task
    logger.info("Initializing Custom Server")
    hass.loop.create_task(socket_server(hass))
    return True

async def socket_server(hass):
    logger.debug("socket_server func has been called")
    host = '0.0.0.0'
    port = config_dict['port'] # Change to your desired port

    server = await asyncio.start_server(
        lambda r, w: handle_client(r, w, hass),
        host,
        port
    )

    async with server:
        await server.serve_forever()

async def handle_client(reader, writer, hass):
    logger.info("Handling Client")

    # Receive credentials
    credentials = await reader.read(100)
    credentials = json.loads(credentials.decode())
    username = credentials.get("username")
    password = credentials.get("password")

    if username in config_dict["users"] and config_dict["users"][username]["pass"] == password:
        writer.write("Authentication successful".encode())
        await writer.drain()
    else:
        writer.write("Authentication failed".encode())
        await writer.drain()
        writer.close()
        await writer.wait_closed()
        return


    while True:
        data = await reader.read(100)
        if not data:
            break
        message = data.decode()
        # Assuming you want to create an event in Home Assistant
        await update_helper(hass, message)
        #hass.bus.async_fire('from_custom_server', {"message": message})
    writer.close()
    await writer.wait_closed()


async def update_helper(hass, message):
    # Update the input_text helper with the received message
    await hass.services.async_call(
        'input_text',
        'set_value',
        {
            'entity_id': 'input_text.your_component_helper',
            'value': message
        }
    )
