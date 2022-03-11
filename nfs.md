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



#
```
```


#
```
```



#
```
```


#
```
```

#
```
```



#
```
```

#
```
```
