lsblk
sudo parted -a optimal /dev/sdb mklabel msdos
sudo parted -a optimal /dev/sdb mkpart primary ext4 0% 100%
sudo parted -a optimal /dev/sdb set 1 raid on
sudo parted -a optimal /dev/sdb print
sudo parted -a optimal /dev/sdc mklabel msdos
sudo parted -a optimal /dev/sdc mkpart primary ext4 0% 100%
sudo parted -a optimal /dev/sdc set 1 raid on
sudo parted -a optimal /dev/sdc print
sudo apt install mdadm
reb
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
sudo mdadm --detail /dev/md0
sudo mdadm --examine /dev/sd[bc]1
sudo cat /proc/mdstat
sudo mkfs.ext4 /dev/md0
sudo mount /dev/md0 /mnt/
df -hT -P /mnt/
sudo vi /etc/fstab
sudo mdadm --detail --scan
sudo vim /etc/mdadm/mdadm.conf
sudo update-initramfs -u
