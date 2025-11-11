sudo apt update
sudo apt install samba

# 1- Create a folder to share (Linux side)
# pick a path for your share
sudo mkdir -p /srv/samba/media

# make your user the owner, and keep group ownership on new files
sudo chown -R {username}:sambashare /srv/samba/media
sudo chmod -R 2775 /srv/samba/media
# (setgid bit 2 keeps group = sambashare on new files/dirs)

# or simply ignore above and share /home/{username}

# 2) Add your user to Samba
# ensure you're in the sambashare group
sudo usermod -aG sambashare {username}

# set a Samba password (this is what macOS will ask for)
sudo smbpasswd -a {username}

# 3) Edit /etc/samba/smb.conf
# Open the file:
sudo nano /etc/samba/smb.conf

# and paste:
#======================= Global Settings =======================

[global]
   workgroup = WORKGROUP
   server string = Xubuntu SMB
   security = user

   # Modern SMB only (no SMB1)
   server min protocol = SMB2_02
   server max protocol = SMB3
   smb encrypt = desired

   # Optional: bind to your interfaces (adjust names to your system)
   # interfaces = lo, enp*, wl*
   # bind interfaces only = yes

   # macOS-friendly metadata/filename handling
   vfs objects = catia fruit streams_xattr
   fruit:metadata = stream
   fruit:posix_rename = yes
   fruit:aapl = yes
   ea support = yes

# === Private share (use your Linux user + smbpasswd) ===
[media]
   path = /home/{username} # or any folder that you created in step 1
   browseable = yes
   read only = no
   valid users = @sambashare
   force group = sambashare
   create mask = 0664
   directory mask = 2775

# Save and test:
testparm
sudo systemctl restart smbd

# 4) Open the firewall (if UFW is enabled)
sudo ufw allow "Samba"

# 5) Connect from your Mac
# Finder → Go → Connect to Server…
# Enter: smb://192.168.x.x/
# Choose Registered User → Username: username → Password: the one you set with smbpasswd.
# Optionally tick Remember this password in keychain.
