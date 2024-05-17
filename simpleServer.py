import socket

host = socket.gethostname()
port = 6969

server_socket = socket.socket()
server_socket.bind((host, port))

server_socket.listen(2)

conn, address = server_socket.accept()

print("Connection from: " + str(address))

while True:
  data = conn.recv(1024).decode()
  if not data:
    break
  print("from connected user: " + str(data))
  if str(data) == "turn on":
    data = "turning on lights"
  elif str(data) == "turn off":
    data = "turning off lights" 
  else:
    data = "Invalid input"
  conn.send(data.encode())

conn.close()

