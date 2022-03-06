# Building a Node inside of MAAS

 1. make sure node is set to pxe boot 

 2. power on node, it PXE boots and gets an IP from MAAS which is the DHCP server -- now in New state

 3. set host name and IP address of/on only one network (the primary VLAN)

 4. commission node

 4. acquire node

 5. setup all VLANs
    * if LXD host:
        * do NOT setup all VLANs 
    * else:
        * setup VLANs 

 6. deploy node 
* cloud-init:
    * if the node is going to be a LXD host: 
        do NOT use cloud init.
    * else: use cloud-init and apply user-data 
