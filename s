#!/bin/bash

# Function to install sendmail
install_sendmail() {
  echo "Checking if sendmail is installed..."

  # Check if sendmail is already installed
  if ! command -v sendmail &>/dev/null; then
    echo "sendmail is not installed. Installing now..."

    # Detect OS and install sendmail
    if [ -f /etc/debian_version ]; then
      # Debian/Ubuntu
      sudo apt update && sudo apt install -y sendmail
    elif [ -f /etc/redhat-release ]; then
      # CentOS/RHEL
      sudo yum install -y sendmail
    else
      echo "Unsupported OS. Please install sendmail manually."
      exit 1
    fi

    echo "sendmail installation complete."
  else
    echo "sendmail is already installed."
  fi
}

# Function to start sendmail service
start_sendmail() {
  echo "Starting sendmail service..."
  if command -v systemctl &>/dev/null; then
    # For systemd systems
    sudo systemctl start sendmail
    sudo systemctl enable sendmail
  else
    # For systems without systemd (e.g., SysVinit)
    sudo service sendmail start
    sudo chkconfig sendmail on
  fi
  echo "sendmail service started."
}

# Function to send a test email
send_test_email() {
  local recipient=$1
  echo "Sending test email to $recipient..."
  echo "Subject: Test Email" | sendmail "$recipient"
  echo "Test email sent to $recipient."
}

# Install sendmail if necessary
install_sendmail

# Start the sendmail service
start_sendmail

# Optional: Send a test email
send_test_email "your-email@example.com"
