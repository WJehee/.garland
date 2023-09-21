# Installing NixOS

Become root:
```
sudo su
```

Create 2 partitions:
- EFI boot: 512 MB
- Main: the rest of the space

```
cryptsetup luksFormat /dev/main-part
cryptsetup luksOpen /dev/main-part main
```

Setup LVM:
```
pvcreate /dev/mapper/pv-name
vgcreate vg-name /dev/mapper/pv-name

# Create 8Gb swap (optional)
lvcreate -L 8G -n swap vg-name
# Use rest for home partition
lvcreate -l 100%FREE -n home vg-name
```

Format:
```
mkfs.fat -F 32 /dev/boot-part
mkfs.ext4 /dev/vg-name/root
mkfs.ext4 /dev/vg-name/home
mkswap /dev/vg-name/swap
```

Mounting:
```
mount /dev/vg-name/root /mnt
mkdir /mnt/boot
mount /dev/boot-disk /mnt/boot
swapon /dev/vg-name/swap
```

Connect to internet (wireless):
```
systemctl start wpa_supplicant
wpa_cli
add_network
set_network 0 ssid "ssid of the network"
set_network 0 psk "the password"
set_network 0 key_mgmt WPA-PSK
enable_network 0
quit
```

Install NixOS:
```
nixos-generate-config --root /mnt
nix-shell -p git
git clone https://github.com/wjehee/.dotfiles-nix
cp /mnt/etc/nixos/hardware-configuration.nix ~/.dotfiles-nix/hosts/HOSTNAME/
```

Use `lsblk -f | grep DISKNAME | awk '{print $4 }'` to get the UUID of the disk
Then replace in configuration.nix for the respective host:  
boot.initrd.luks.devices.nixos.device = "/dev/disk/by-uuid/UUID";

```
git add .
nixos-install --flake .#HOSTNAME
```

# Enter as root and change user password, then reboot
```
nixos-enter --root /mnt
passwd USERNAME
reboot
```

Thanks to :
https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134

