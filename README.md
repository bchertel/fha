# fha - NTPc
`./ntpc.sh -ip <ip address> -[s|c]`  

**Note:** *weird things happen when -ip is not specified as the first arguement.*

## Basic Usage
**-ip**  
Used to set the IP address for `-s | -c` options. When used with the `-s` option,
the provided IP address will become the broadcast ip address. Similarly, when
used with the `-c` option, the provided IP address will be where the client looks
for the NTP server to sync.

**-s | --server**  
Use for node that will be fetching remote time and distributing it locally.

**-c | --client**  
Use for node that will be syncing with the server/controller.

**-l | --log**  
Only use if you would like to disable logging of statistics. Logging is on by default.

**-b | --backup**  
Only use if you do not wish to create a backup file of the current ntp.conf file. Backup
is enable by default.

## Example
`./ntpc.sh -ip 10.0.0.1 -s`  

The above script, with specified arguements, will configure Raspbian to act as NTP server, broadcasting from ip address `10.0.0.1`.  A client on the same network could be configured to use the server created in the above command via the following:

`./ntpc.sh -ip 10.0.0.1 -c`

**NOTE:** *it is likely a good idea to configure the server first.*