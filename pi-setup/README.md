## Pi setup
I assume you know how to create a bootable SD card. More info can be found [here](https://www.raspberrypi.com/software/).
<br />Don't forget to change the setting and for the first time set up the ssh connection with the username and password.
<br />If you try multiple OSs and install a new version and get an error, try:
```bash
ssh-keygen -R pi5@ip-address-of-pi
```
First, use a SD card. Install the linux version that you want. Then, run:
```bash
sudo apt update
sudo apt full-upgrade -y
sudo rpi-eeprom-update -a # update EEPROM/bootloader
sudo reboot
# After reboot:
vcgencmd bootloader_version # should be 2025 or later
```

My SSD shows 4096-byte logical sectors (4Kn):
```
Sector size (logical/physical): 4096B/4096B
```

Right now the Pi bootloader can’t USB-boot from 4Kn devices (typical symptom: solid green LED). <br />
It can boot from devices that present 512-byte logical sectors (512e), which is why your USB stick works. <br />
This is a known limitation tracked by the Pi team (4K-sector USB boot support not yet implemented). <br />
We can keep a tiny SD for /boot, put the whole OS on the SSD.
This gives us SSD speed/reliability for the OS and data, with the SD only holding the ~500 MB boot files.

## The next steps were written by ChatGPT (not tested). Be careful:

Re-use the SD boot backup (boot-firmware-YYYYMMDD.tgz)

You can turn any SD (or tiny USB stick) into a boot card from that tarball.

1) Prepare the card (one FAT32 partition, label it FIRMWARE):

### Replace /dev/SDX with the correct device for the *target* card
```bash
lsblk
sudo umount /dev/SDX* 2>/dev/null || true
sudo wipefs -a /dev/SDX
sudo parted /dev/SDX --script mklabel msdos
sudo parted /dev/SDX --script mkpart primary fat32 1MiB 100%
sudo mkfs.vfat -F32 -n FIRMWARE /dev/SDX1
```

2) Restore your backup onto it:
```bash
sudo mkdir -p /mnt/newboot
sudo mount /dev/SDX1 /mnt/newboot
```

### adjust the file name if different
```bash
cd ~
sudo tar -C /mnt/newboot -xzf boot-firmware-*.tgz

# sanity check (should show config.txt, cmdline.txt, start*.elf, kernel*.img, overlays, etc.)
ls -l /mnt/newboot | head -n 20
```

3) Ensure cmdline.txt points to your SSD root PARTUUID:
```bash
SSD_ROOT_UUID=$(sudo blkid -s PARTUUID -o value /dev/sda2)
echo "SSD_ROOT_UUID=$SSD_ROOT_UUID"

# make cmdline a clean single line:
sudo tee /mnt/newboot/cmdline.txt >/dev/null <<EOF
console=serial0,115200 console=tty1 root=PARTUUID=${SSD_ROOT_UUID} rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
EOF
cat /mnt/newboot/cmdline.txt
```

4) Your running system’s /etc/fstab must mount /boot from the card (by label):
```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo tee /etc/fstab >/dev/null <<'EOF'
LABEL=FIRMWARE  /boot/firmware  vfat  defaults,flush,umask=0022  0  2
PARTUUID=d7d1d81a-3bc2-48f8-ab82-7f501730aa9c  /  ext4  defaults,noatime  0  1
EOF

cat /etc/fstab
```

5) Unmount and use it:
```bash
sudo sync
sudo umount /mnt/newboot
```

Pop it into the Pi’s SD slot and boot (SSD stays attached). Done.