sudo apt install -y lm-sensors
sudo sensors-detect
# Answer "yes" to probing; it will suggest kernel modules (e.g., coretemp, k10temp).
# Load them now or reboot once; either way is fine:
sudo service kmod start || true