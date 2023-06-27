
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