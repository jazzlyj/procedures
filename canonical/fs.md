
## delete a partition
sudo fdisk /dev/sdb

## make a partition
sudo parted -l
* sudo parted /dev/sdb
    * select /dev/sdb
    * mklabel gpt
    * print
    * mkpart primary ext4 1MB 2699GB
    * PRINT
    * quit                                                            

## format
sudo mkfs -t ext4 /dev/sdb1

## Mount
sudo mount -t auto /dev/sdb1 /local/mnt

## mount permanently
sudo vi /etc/fstab
    /dev/sdb1 /local/mnt  ext4 defaults 0 1 



Model: DELL PERC H310 (scsi)
Disk /dev/sdb: 2699GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  2699GB  2699GB  ext4         primary

(parted) quit
Information: You may need to update /etc/fstab.

sudo mkfs -t ext4 /dev/sdb1
mke2fs 1.45.5 (07-Jan-2020)
/dev/sdb1 contains a zfs_member file system labelled 'poolzfs'
Proceed anyway? (y,N) y
Creating filesystem with 658832896 4k blocks and 164708352 inodes
Filesystem UUID: 13eb5ea7-ec2d-483d-a482-92124553ffcf
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000, 214990848, 512000000, 550731776, 644972544

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done       










sudo apt install zfsutils-linux

sudo fdisk -l
Disk /dev/loop0: 63.28 MiB, 66347008 bytes, 129584 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop1: 63.29 MiB, 66355200 bytes, 129600 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop2: 49.85 MiB, 52248576 bytes, 102048 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop3: 67.83 MiB, 71106560 bytes, 138880 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop4: 91.85 MiB, 96292864 bytes, 188072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 278.9 GiB, 299439751168 bytes, 584843264 sectors
Disk model: PERC H310       
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 487F7228-A676-4713-8B25-208E34890DC5

Device       Start       End   Sectors   Size Type
/dev/sda1     2048      4095      2048     1M BIOS boot
/dev/sda2     4096   4198399   4194304     2G Linux filesystem
/dev/sda3  4198400 584841215 580642816 276.9G Linux filesystem


Disk /dev/sdb: 2.47 TiB, 2698581639168 bytes, 5270667264 sectors
Disk model: PERC H310       
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 7251E1BA-2D01-584E-8292-F0BBC879D002

Device          Start        End    Sectors  Size Type
/dev/sdb1        2048 5270648831 5270646784  2.5T Solaris /usr & Apple ZFS
/dev/sdb9  5270648832 5270665215      16384    8M Solaris reserved 1


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 100 GiB, 107374182400 bytes, 209715200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ubuntu--vg-lv--0: 176 GiB, 188978561024 bytes, 369098752 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


u2 09:23:09 ~{47} df -hT
Filesystem                        Type      Size  Used Avail Use% Mounted on
udev                              devtmpfs   71G     0   71G   0% /dev
tmpfs                             tmpfs      15G  2.1M   15G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4       98G   15G   79G  16% /
tmpfs                             tmpfs      71G     0   71G   0% /dev/shm
tmpfs                             tmpfs     5.0M     0  5.0M   0% /run/lock
tmpfs                             tmpfs      71G     0   71G   0% /sys/fs/cgroup
/dev/sda2                         ext4      2.0G  205M  1.6G  12% /boot
/dev/loop0                        squashfs   64M   64M     0 100% /snap/core20/1778
/dev/mapper/ubuntu--vg-lv--0      ext4      173G  1.1G  163G   1% /home
/dev/loop1                        squashfs   64M   64M     0 100% /snap/core20/1822
/dev/loop2                        squashfs   50M   50M     0 100% /snap/snapd/17950
/dev/loop4                        squashfs   92M   92M     0 100% /snap/lxd/24061
/dev/loop3                        squashfs   68M   68M     0 100% /snap/lxd/22753
tmpfs                             tmpfs      15G     0   15G   0% /run/user/1000
tmpfs                             tmpfs     1.0M     0  1.0M   0% /var/snap/lxd/common/ns

u2 09:25:21 ~{48} sudo zfs get all

u2 09:26:22 ~{49} sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME                      FSTYPE        SIZE MOUNTPOINT        LABEL
loop0                     squashfs     63.3M /snap/core20/1778 
loop1                     squashfs     63.3M /snap/core20/1822 
loop2                     squashfs     49.8M /snap/snapd/17950 
loop3                     squashfs     67.8M /snap/lxd/22753   
loop4                     squashfs     91.9M /snap/lxd/24061   
sda                                   278.9G                   
├─sda1                                    1M                   
├─sda2                    ext4            2G /boot             
└─sda3                    LVM2_member 276.9G                   
  ├─ubuntu--vg-ubuntu--lv ext4          100G /                 
  └─ubuntu--vg-lv--0      ext4          176G /home             
sdb                                     2.5T                   
├─sdb1                    zfs_member    2.5T                   poolzfs
└─sdb9                                    8M                   
sr0                                    1024M                   
u2 09:39:02 ~{50} lsblk -P -o KNAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
KNAME="loop0" FSTYPE="squashfs" SIZE="63.3M" MOUNTPOINT="/snap/core20/1778" LABEL="" MODEL=""
KNAME="loop1" FSTYPE="squashfs" SIZE="63.3M" MOUNTPOINT="/snap/core20/1822" LABEL="" MODEL=""
KNAME="loop2" FSTYPE="squashfs" SIZE="49.8M" MOUNTPOINT="/snap/snapd/17950" LABEL="" MODEL=""
KNAME="loop3" FSTYPE="squashfs" SIZE="67.8M" MOUNTPOINT="/snap/lxd/22753" LABEL="" MODEL=""
KNAME="loop4" FSTYPE="squashfs" SIZE="91.9M" MOUNTPOINT="/snap/lxd/24061" LABEL="" MODEL=""
KNAME="sda" FSTYPE="" SIZE="278.9G" MOUNTPOINT="" LABEL="" MODEL="PERC_H310"
KNAME="sda1" FSTYPE="" SIZE="1M" MOUNTPOINT="" LABEL="" MODEL=""
KNAME="sda2" FSTYPE="ext4" SIZE="2G" MOUNTPOINT="/boot" LABEL="" MODEL=""
KNAME="sda3" FSTYPE="LVM2_member" SIZE="276.9G" MOUNTPOINT="" LABEL="" MODEL=""
KNAME="sdb" FSTYPE="" SIZE="2.5T" MOUNTPOINT="" LABEL="" MODEL="PERC_H310"
KNAME="sdb1" FSTYPE="zfs_member" SIZE="2.5T" MOUNTPOINT="" LABEL="poolzfs" MODEL=""
KNAME="sdb9" FSTYPE="" SIZE="8M" MOUNTPOINT="" LABEL="" MODEL=""
KNAME="sr0" FSTYPE="" SIZE="1024M" MOUNTPOINT="" LABEL="" MODEL="HL-DT-ST_DVD-ROM_DU60N"
KNAME="dm-0" FSTYPE="ext4" SIZE="100G" MOUNTPOINT="/" LABEL="" MODEL=""
KNAME="dm-1" FSTYPE="ext4" SIZE="176G" MOUNTPOINT="/home" LABEL="" MODEL=""
u2 09:40:06 ~{51} lsblk -P -o KNAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL