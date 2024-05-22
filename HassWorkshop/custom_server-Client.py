import socket
import json
import time
import base64

def xor_encrypt(text, key):
    encrypted = []
    for i in range(len(text)):
        encrypted.append(chr(ord(text[i]) ^ ord(key[i % len(key)])))
    return ''.join(encrypted)

def send_message(base_message, host='127.0.0.1', port=9999):
    """
    Connects to the server at the specified host and port, sends credentials and a message,
    and closes the connection.

    :param message: The message to send to the server.
    :param host: The server's hostname or IP address. Defaults to localhost.
    :param port: The server's port. Defaults to 9999.
    """
    
    try:
        # Create a socket object
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # Connect to the server
            s.connect((host, port))
            print(f"Connected to {host}:{port}")
            username = input("Enter username: ")
            password = input("Enter password: ")

             # Process challenge from server
            challenge = s.recv(1024).decode()
            response = xor_encrypt(challenge, password)
            
            encrypted_password = xor_encrypt(password, password)

            # Base64 encode the encrypted password and response
            encrypted_password_base64 = base64.b64encode(encrypted_password.encode()).decode()
            response_base64 = base64.b64encode(response.encode()).decode()


            credentials = {
                "username": username,
                "password": encrypted_password_base64,
                "response": response_base64
            }

           

            # Send credentials
            s.sendall(json.dumps(credentials).encode())

            # Receive authentication response
            response = s.recv(1024).decode()
            if response != "Authentication successful":
                print("Authentication failed. Disconnecting...")
                return

            print("Authentication successful. Sending message...")

            counter = 0

            # Send the message every second with an appended count
            while counter <= 100:
                message = f"{base_message} {counter}"
                s.sendall(message.encode())
                print(f"Sent: {message}")
                counter += 1
                time.sleep(1)
            print("Counter reached 100. Closing connection.")
            s.sendall("Client Conection Closed".encode())
            
    except ConnectionRefusedError:
        print(f"Could not connect to server at {host}:{port}. Is it running?")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
if __name__ == "__main__":
    host = '192.168.68.79'  # Replace with your Home Assistant IP address if necessary
    port = 9999             # Make sure this matches the port used in your custom component
    base_message = "fat belly"

    send_message(base_message, host, port)
