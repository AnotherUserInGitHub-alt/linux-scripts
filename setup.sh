#!/bin/bash

# Ask the user for keyboard language
echo "Welcome to the Arch Linux install script. please select your keyboard locale (en, es):"
read locale
loadkeys $locale

timedatectl set-ntp true

# Ask the user for disk partitioning
echo "Input the name of the disks to be partitioned:"
read disks
cfdisk  $disks

# Display partitions

echo "Giving you enough time to check on the partitions..."
sleep 5
fdisk -l
sleep 6

# Format the disks
echo "Insert the number/location of the root partition:"
read root
mkfs.ext4 /dev/$root
echo "Insert the name/location of the swap partition (if any):"
read swap
mkswap /dev/$swap
swapon /dev/$swap

# Mount the disks

mount /dev/$root /mnt

# Pacstraping time

echo "Type the name of the additional packages to install during pacstrap:"
read install_to_root
pacstrap /mnt base base-devel linux $install_to_root

# Generate the fs-tab

genfstab -U /mnt >> /mnt/etc/fstab

# Hostname

echo "Name for the new host:"
read host
echo "$host" >> /mnt/etc/hostname

echo "Where are you located?"
read location
ln -sf /usr/share/zoneinfo/America/$location /mnt/etc/locatime

# Set the hardware clock

arch-chroot /mnt hwclock --systohc

# Set locale

echo "What is your locale? in uppercase:"
read lang
sed -i '/$lang.UTF-8 UTF-8/s/^#//' /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

# Set language

echo "LANG=$lang.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=$locale" > /mnt/etc/vconsole.conf

# Install dhcpcd and doas

echo "Installing DHCPCD and doas, please wait..."
pacstrap /mnt dhcpcd doas
arch-chroot /mnt systemctl enable dhcpcd
echo "permit persist :wheel" >> /mnt/etc/doas.conf

# Add the hostname to /etc/hosts
echo "127.0.0.1		localdomain" >> /mnt/etc/hosts
echo "::1		localdomain" >> /mnt/etc/hosts
echo "127.0.1.1		$host.localdomain $host" >> /mnt/etc/hosts

# Install grub

pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /mnt/boot/grub/grub.cfg

# Set password for the new root

arch-chroot /mnt passwd root

# unmount the filesystems

umount -R /mnt

# Reboot

echo "Rebooting in 5..."
sleep 1
echo "Rebooting in 4..."
sleep 1
echo "Rebooting in 3..."
sleep 1
echo "Rebooting in 2..."
sleep 1
echo "Rebooting in 1..."
sleep 1
echo "Rebooting to the new system..."
sleep 2
reboot
