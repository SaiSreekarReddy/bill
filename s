#!/usr/bin/expect -f
set timeout -1
spawn putty.exe -ssh your_username@your_server_ip
expect "password:"
send "your_password\r"
expect "$ "
send "sudo su\r"
expect "password for your_username:"
send "your_password\r"
interact
