# Building a Node inside of MAAS

 1. make sure node is set to pxe boot 

 2. power on node and let it get a DHCP IP address from MAAS and then pxe boot

 3. set the host name, and IP address, all NICs VLANs etc in MAAS

 4. acquire node

 5. deploy node 
* if the node is going to be a LXD host: 
    do NOT use cloud init.
* else: use cloud-init and apply user-data 
