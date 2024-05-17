import socket
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(filename='client.log', level=logging.DEBUG, format='%(message)s %(asctime)s', datefmt='%m/%d/%Y %I:%M:%S %p', filemode = "w")

host = socket.gethostname()
port = 6969

client_socket = socket.socket()  # instantiate
client_socket.connect((host, port))  # connect to the server

message = input("To Server: ")

while message.lower().strip() != 'bye':
  client_socket.send(message.encode())  # send message
  logger.info("Message sent to server: %s", message)
  
  data = client_socket.recv(1024).decode()  # receive response
  logger.info("Message recieved from server: %s", data)
  print('From Server: ' + data)  # show in terminal

  message = input("To Server: ")  # again take input

client_socket.close()  # close the connection
