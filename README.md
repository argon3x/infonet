# infonet

***this script displays local network connection information***

- *Give permission of execution*

        chmod u+x infonet.sh

- *Run script*

        ./infonet.sh

### Nota

*for its correct execution, the following dependencies must be in place *ifconfig* and *netstat*.*
  
- install the ifconfig and netstat dependency run
  
        sudo apt install net-tools

- later a symbolic link of the route command must be created. 

        sudo ln -s /usr/sbin/route /usr/bin/route
