1. Update APT Repository Cache

sudo apt update
 

2. install VNC server on Ubuntu 20.04 | 18.04

sudo apt install tigervnc-standalone-server tigervnc-xorg-extension
sudo apt install xserver-xorg-core

sudo apt install ubuntu-gnome-desktop

3. Set VNC password
```
vncpasswd
```
 

4. Run VNC server on Ubuntu 20.04 or 18.04
```
vncserver
```
Output in our case:

New 'h2s-VirtualBox:1 (h2s)' desktop at :1 on machine h2s-VirtualBox

Starting applications specified in /home/h2s/.vnc/xstartup
Log file is /home/h2s/.vnc/h2s-VirtualBox:2.log

Use xtigervncviewer -SecurityTypes VncAuth -passwd /home/h2s/.vnc/passwd :1 to connect to the VNC server.
Once you see something like above, that means the server is running without any error:


Kill the server:
```
vncserver -kill :*
```

5. Configure Desktop environment for VNC Server

Back up your original XStartup file.
```
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
```
* Create a new one:
```
vim ~/.vnc/xstartup
# Add the following code in the file:

#!/bin/sh 
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
```

 

6. Start VNC server
```
vncserver -localhost no -geometry 800x600 -depth 24
```

7. Access remote system using VNC viewer
Enter the IP address along with port 5901 
 

7. Access VNC Server securely over SSH
Install the OpenSSH server on the remote Ubuntu server that you want to access over SSH.

```
sudo apt install openssh-server -y
```
ssh server-user@server-ipaddress -C -L 5901:127.0.0.1:5901
Replace server-user and server-IP-address with ones you have on your Ubuntu installed with the VNC server.

After that, again open the VNC viewer app on your local system, and instead of using ip-address:5901, use localhost:5901

VNC viewer Connection details

 

8. Create Systemd service file VNC server (optional)
Those who are interested in using the VNC server as a background service can create a Systemd file for it.

* First, kill any existing running instances of the server part:
```
vncserver -kill :*
```
* Create a new service file:

```
sudo nano /etc/systemd/system/vncserver@.service
 Paste the following code:

[Unit]
Description= Tiger VNC Server service
After=syslog.target network.target

[Service]
Type=forking
User=h2s

ExecStartPre=/usr/bin/vncserver -kill :%i > /dev/null 2>&1 
ExecStart=/usr/bin/vncserver -geometry 800x600 -depth 24 -localhost no :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
Save the file by pressing Ctrl+O, Enter key, and then Ctrl+X.
```
Note: Replace h2s with your current user

 

9. Start and enable VNC server service on Ubuntu 20.04 | 18.04 (optional)
Once done, start your server as a service:

Here @1 means vncserver :1 – display 1

```
sudo systemctl start vncserver@1
sudo systemctl enable vncserver@1
To check status:
```

```
sudo systemctl status vncserver@1
# Tiger VNC server Systemd service file

```
To stop 

```
sudo systemctl stop vncserver@1
```