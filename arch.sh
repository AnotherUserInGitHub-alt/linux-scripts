#!/bin/bash

# Welcome message
echo "Welcome to the Arch Linux installation script!"

# Set the keyboard layout
loadkeys es

# Set the time zone
timedatectl set-timezone America/Lima

# Update the system clock
timedatectl set-ntp true

# Set up the disk
cfdisk /dev/sda

# Format the partitions
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2

# Mount the file system
mount /dev/sda1 /mnt

# Install the base packages
pacstrap /mnt base linux linux-firmware sudo git nano

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into the new file system
arch-chroot /mnt

# Set the hostname
echo "arch" > /etc/hostname

# Set the time zone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Set the locales
sed -i 's/#es_PE.UTF-8 UTF-8/es_PE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_PE.UTF-8" > /etc/locale.conf

# Set the console locale

echo "KEYMAP=es" > /etc/vconsole.conf

# Edit the sudo tool

nano /etc/sudoers

# Set the root password
passwd

# Install the GRUB boot loader
pacman -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Reboot the system
reboot
