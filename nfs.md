# NFS Server and Client Setup


## Installing the NFS server 
```bash
sudo apt update
sudo apt install nfs-kernel-server
```


### Verify
```bash
sudo cat /proc/fs/nfsd/versions
```



## Creating file systems

### create the root directory and the share mount points:
```bash
sudo mkdir -p /usr2/home
```

### Bind mount an existing directory (or create a new one)  to the share mount point:
```bash
sudo mount --bind /usr2/home /usr2/home
```


### Make mount permanent 
```bash
sudo vi /etc/fstab
# add the line 
/usr2/home /usr2/home none bind 0 0 
```




### create and activate the export
```bash
sudo vi /etc/exports
# add lines: `CIDR` example is: 192.168.1.0/24
/usr2        CIDR(rw,sync,no_subtree_check,crossmnt,fsid=0)
/usr2/home   CIDR(rw,sync,no_subtree_check)
```



* activate
```bash
sudo exportfs -ar
```


### Verify exports
```bash
sudo exportfs -v
```


## Client side
```bash
sudo apt install nfs-common
sudo mkdir -p /usr2/home
sudo mount -t nfs -o vers=4 jayu22:/usr2/home /usr2/home
```


```bash
sudo vi /etc/fstab
#add the lines:
jayu22:/usr2/home /usr2/home     nfs  defaults,timeo=900,retrans=5,_netdev 0 0
```



