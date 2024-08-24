# Define your credentials and server IP
$Username = "your_username"
$Password = "your_password"
$ServerIP = "your_server_ip"

# Construct the plink command
$plinkCommand = "plink.exe -ssh $Username@$ServerIP -pw $Password -t 'sudo su'"

# Execute the plink command
Invoke-Expression $plinkCommand
====
# Define your credentials and server IP
$Username = "your_username"
$Password = "your_password"
$ServerIP = "your_server_ip"

# Build the plink command that will log in and elevate to root
$plinkCommand = "plink.exe -ssh $Username@$ServerIP -pw $Password -t 'echo $Password | sudo -S su'"

# Execute the plink command
Invoke-Expression $plinkCommand
