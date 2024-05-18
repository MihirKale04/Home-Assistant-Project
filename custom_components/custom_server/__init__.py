import socket

def send_message(message, host='127.0.0.1', port=6969):
    """
    Connects to the server at the specified host and port, sends a message,
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

            # Send the message
            s.sendall(message.encode())
            print(f"Sent: {message}")

    except ConnectionRefusedError:
        print(f"Could not connect to server at {host}:{port}. Is it running?")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
if __name__ == "__main__":
    host = '192.168.68.79'  # Replace with your Home Assistant IP address if necessary
    port = 6969             # Make sure this matches the port used in your custom component
    message = "Rahul is a huge individual"

    send_message(message, host, port)
