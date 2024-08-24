import paramiko
import time
import readline
import glob

# Common shell commands to be suggested
SHELL_COMMANDS = ['cd', 'ls', 'mkdir', 'rm', 'cp', 'mv', 'cat', 'echo', 'sudo', 'exit']

def complete_path_and_commands(text, state):
    """Enhanced tab completion for paths and shell commands."""
    line = readline.get_line_buffer().split()

    if not line or len(line) == 1:
        # If it's the first word, complete from shell commands or file paths
        matches = [cmd for cmd in SHELL_COMMANDS if cmd.startswith(text)] + glob.glob(text + '*')
    else:
        # If it's not the first word, complete from file paths only
        matches = glob.glob(text + '*')
    
    try:
        return matches[state]
    except IndexError:
        return None

def detect_server_type(channel):
    """Detect the server type based on the presence of directories in /opt."""
    channel.send('cd /opt\n')
    time.sleep(1)
    channel.send('ls\n')
    time.sleep(1)
    
    server_types = ["springboot", "jboss", "splunk"]
    
    detected_type = "Regular"  # Default to regular

    if channel.recv_ready():
        output = channel.recv(1024).decode('utf-8').strip().splitlines()
        for line in output:
            for server_type in server_types:
                if server_type in line:
                    detected_type = server_type.capitalize()
                    break
            if detected_type != "Regular":
                break
    
    return detected_type

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

    # Detect server type based on directories in /opt
    server_type = detect_server_type(channel)
    print(f"Server Type Detected: {server_type}")

    # Set up tab-completion
    readline.set_completer(complete_path_and_commands)
    readline.parse_and_bind("tab: complete")

    # Interactive loop to keep the session open
    while True:
        try:
            # Input with tab-completion for file paths and commands
            command = input("Enter command (type 'exit' to close): ")
        except KeyboardInterrupt:
            continue  # Handle Ctrl+C
        except EOFError:
            break  # Handle Ctrl+D

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
