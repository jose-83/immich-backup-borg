# on linux
# Show effective Samba config (look for the [media] section and its "path = ...")
sudo testparm -s | sed -n '/^\[media\]/,/^\[/p'

# Or grep directly for "path =" lines:
sudo grep -R "^\s*path\s*=" /etc/samba/smb.conf /etc/samba/smb.conf.d/* 2>/dev/null

# See top-level mount points to guess where "media" might live:
df -hT | column -t


# 0) (once) ensure your account is in sambashare
id hossein | grep sambashare || sudo usermod -aG sambashare hossein

# 1) create the tree Immich expects
sudo install -d -m 2775 -o hossein -g sambashare \
  /home/hossein/immich-app/library \
  /home/hossein/immich-app/library/{encoded-video,library,profile,thumbs,backups,upload}

# 2) fix ownership/permissions recursively for safety
sudo chown -R hossein:sambashare /home/hossein/immich-app
sudo find /home/hossein/immich-app -type d -exec chmod 2775 {} \;
sudo find /home/hossein/immich-app -type f -exec chmod 0664 {} \;

# 3) (recommended) default ACLs so new files/dirs stay writable
sudo setfacl -R -m u:hossein:rwx,g:sambashare:rwx /home/hossein/immich-app
sudo setfacl -R -d -m u:hossein:rwx,g:sambashare:rwx /home/hossein/immich-app

# 4) reload Samba config (no restart needed)
sudo smbcontrol all reload-config || sudo systemctl reload smbd || sudo service smbd reload