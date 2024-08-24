import paramiko
import time

def ssh_to_server():
    host = "your_vm_ip"  # Replace with your server's IP
    username = "your_username"  # Replace with your SSH username
    password = "your_password"  # Replace with your SSH password

    # Initialize the SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    # Connect to the server
    ssh.connect(host, username=username, password=password)

    # Open an interactive shell session
    channel = ssh.invoke_shell()

    # Execute the sudo su command
    channel.send('sudo su\n')
    time.sleep(1)
    channel.send(password + '\n')
    time.sleep(1)  # Give it some time to switch users

    # Read the output of the commands
    while channel.recv_ready():
        output = channel.recv(1024).decode('utf-8')
        print(output)

    # Interactive loop to keep the session open
    while True:
        command = input("Enter command (type 'exit' to close): ")
        if command.lower() == "exit":
            break
        channel.send(command + '\n')
        time.sleep(1)  # Wait for the command to execute

        while channel.recv_ready():
            output = channel.recv(1024).decode('utf-8')
            print(output)

    # Close the connection
    channel.close()
    ssh.close()

# Run the function
ssh_to_server()
