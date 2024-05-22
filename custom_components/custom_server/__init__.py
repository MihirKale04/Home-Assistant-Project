"""custom server"""

import asyncio
import json 
import socket
import random
import logging
import base64
from homeassistant.helpers import discovery
from homeassistant.helpers.entity import Entity

DOMAIN = "custom_server"

logger = logging.getLogger(__name__)

logger.info("reading server config file")
with open("/config/custom_components/custom_server/serverConfig.json", 'r') as file:
    data = file.read()
config_dict = json.loads(data)
logger.info("Config Dictionary: \n%s", json.dumps(config_dict, indent=4))


# XOR decryption function
def xor_decrypt(encrypted_text, key):
    decrypted = []
    for i in range(len(encrypted_text)):
        decrypted.append(chr(ord(encrypted_text[i]) ^ ord(key[i % len(key)])))
    return ''.join(decrypted)


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

    # Generate a random challenge message
    challenge = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', k=10))
    writer.write(challenge.encode())
    await writer.drain()
    logger.info("Challenge sent to client %s", challenge)

    # Receive credentials and challenge resepose
    data = await reader.read(1024)
    data = json.loads(data.decode())
    username = data.get("username")
    encrypted_password_base64 = data.get("password")
    response_base64 = data.get("response")


    encrypted_password = base64.b64decode(encrypted_password_base64).decode()
    response = base64.b64decode(response_base64).decode()

    logger.info("before decryption %s", encrypted_password)
    actual_password = config_dict["users"].get(username, {}).get("pass", "")
    decrypted_password = xor_decrypt(encrypted_password, actual_password)
    logger.info("after decryption %s", decrypted_password)

    if username in config_dict["users"] and decrypted_password == actual_password:
        if challenge == xor_decrypt(response, actual_password):
            writer.write("Authentication successful".encode())
            await writer.drain()
        else:
            writer.write("Challenge response mismatch".encode())
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
