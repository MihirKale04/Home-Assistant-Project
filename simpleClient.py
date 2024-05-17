import socket



host = socket.gethostname()
port = 6969

client_socket = socket.socket()  # instantiate
client_socket.connect((host, port))  # connect to the server

message = input(" -> ")

while message.lower().strip() != 'bye':
  client_socket.send(message.encode())  # send message
  data = client_socket.recv(1024).decode()  # receive response

  print('Server: ' + data)  # show in terminal

  message = input(" -> ")  # again take input

client_socket.close()  # close the connection
