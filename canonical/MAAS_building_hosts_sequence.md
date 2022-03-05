# Building a Node inside of MAAS

 1. make sure node is set to pxe boot 

 2. power on node and let it get a DHCP IP address from MAAS and then pxe boot
control
 3. set the host name and IP address of/on only one network

 4. acquire node

 5. setup all VLANs

 6. deploy node 
* if the node is going to be a LXD host: 
    do NOT use cloud init.
* else: use cloud-init and apply user-data 
