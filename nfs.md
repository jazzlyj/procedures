# NFS Server and Client Setup


## Installing the NFS server 
```
sudo apt update
sudo apt install nfs-kernel-server
```


### Verify
```
sudo cat /proc/fs/nfsd/versions
```



## Creating file systems

### create the root directory and the share mount points:
```
sudo mkdir -p /usr2/home
```

### Bind mount an existing directory (or create a new one)  to the share mount point:
```
sudo mount --bind /mnt/home /usr2/home
```


### Make mount permanent 
```
sudo vi /etc/fstab
```



### create and activate the export
`sudo vi /etc/exports` add lines. `CIDR` example is: 192.168.1.0/24

```
/mnt        CIDR(rw,sync,no_subtree_check,crossmnt,fsid=0)
/mnt/home   CIDR(rw,sync,no_subtree_check)
```



* activate
`sudo exportfs -ar`


### Verify exports
```
sudo exportfs -v
```


## Client side
```
sudo apt install nfs-common
sudo mkdir -p /usr2/home
sudo mount -t nfs -o vers=4 u8:/mnt/home /usr2/home
```

`sudo vi /etc/fstab` add the lines:
```
u8:/mnt/home /usr2/home     nfs  defaults,timeo=900,retrans=5,_netdev 0 0
```



