#!/bin/bash

sudo apt update -y

sudo apt install xfsprogs -y

sudo mkfs -t xfs /dev/xvdba

sudo mkdir -p /mnt/disks/attached-disk

sudo mount /dev/xvdba /mnt/disks/attached-disk

BLK_ID=$(sudo blkid /dev/xvdba | cut -f2 -d" ")

if [[ -z $BLK_ID ]]; then
  echo "Hmm ... no block ID found ... "
  exit 1
fi

echo "$BLK_ID     /mnt/disks/attached-disk   xfs    defaults   0   2" | sudo tee --append /etc/fstab

sudo mount -a

echo "Bootstrapping Complete!"