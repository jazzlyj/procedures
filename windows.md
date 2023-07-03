# windows
install open ssh 
https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse


# activate ssh-agent
```
Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service
```

```
start-ssh-agent.cmd
```

# microk8s
https://wsl.dev/wsl2-microk8s/


# create a bootable USB stick
* start powershell or cmd.exe as an administrator
```
PS C:\Windows\System32> diskpart

Microsoft DiskPart version 10.0.22000.1

Copyright (C) Microsoft Corporation.
On computer: W1

DISKPART> list disk

  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          XXX GB      0 B        *
  Disk 1    Online         YYYY MB      0 B

DISKPART> select disk 1

Disk 1 is now the selected disk.

DISKPART> clean

DiskPart succeeded in cleaning the disk.

DISKPART> create partition primary

DiskPart succeeded in creating the specified partition.

DISKPART> select partition 1

Partition 1 is now the selected partition.

DISKPART> format fs=fat32 quick

  100 percent completed

DiskPart successfully formatted the volume.

DISKPART> active

DiskPart marked the current partition as active.

DISKPART> exit

Leaving DiskPart...
