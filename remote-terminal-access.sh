# 1. Set up SSH on Linux
# On your Linux machine:
$ sudo apt update
$ sudo apt install openssh-server -y

# Check if the SSH service is running:
$ systemctl status ssh

# It should say active (running). For the first time it is disabled by default.
# If it is not active, activate it:
$ sudo systemctl enable --now ssh

# 2. Find the Linux machine’s IP
# On the Linux machine:
$ hostname -I
# Example output: 192.168.1.42

# 3. Connect via SSH from your Mac
# On another machine's terminal:
$ ssh username@192.168.1.42
# The username should be the username (ex. john) that you use to login into your linux machine.
# First time, you’ll be asked to accept the host key. And you need to pass the password of the user of the Linux machine.

# Copy a file from Mac → Xubuntu
scp myfile.txt username@192.168.1.42:/home/username/
# Copy a file from Xubuntu → Mac
scp username@192.168.1.42:/home/username/file.txt ~/Downloads/