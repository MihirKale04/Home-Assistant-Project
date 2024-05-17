import socket
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(filename='server.log', level=logging.DEBUG, format='%(message)s %(asctime)s', datefmt='%m/%d/%Y %I:%M:%S %p', filemode = "w")

host = socket.gethostname()
port = 6969

server_socket = socket.socket()
server_socket.bind((host, port))

server_socket.listen(2)

conn, address = server_socket.accept()

logger.info("Connection from: " + str(address))

while True:
  data = conn.recv(1024).decode()
  if not data:
    break
  logger.info("From Client: " + str(data))
  if str(data) == "turn on":
    data = "turning on lights"
  elif str(data) == "turn off":
    data = "turning off lights" 
  else:
    data = "Invalid input"
  conn.send(data.encode())
  logger.info("To Client: " + str(data))

conn.close()
