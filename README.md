# NixOS configuration

## Installing

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
# Create 100Gb root partition (optional)
lvcreate -L 200G -n root vg-name
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
mkdir /mnt/home
mount /dev/vg-name/home /mnt/home
```

Connect to internet:
```
sudo systemctl start wpa_supplicant
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

# Get nix config file from dotfiles

nixos-install
```

Reboot, login as root and change the user password

Thanks to :
https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134

