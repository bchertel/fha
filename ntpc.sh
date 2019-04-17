#!/bin/bash

# Bare bones Bash script to help config server/clint side NTP

# Must be executed with sudo permissions
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi


#parse args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
BACKUP="True"
LOGGING="True"

case $key in
    -s|--server)
    ROLE="S"
    shift # past argument
    shift # past value
    ;;
    -c|--client)
    ROLE="C"
    shift # past argument
    shift # past value
    ;;
    -l|--log)
    LOGGING="False"
    shift # past argument
    shift # past value
    ;;
    -ip)
    IP="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--mask)
    MASK="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--backup)
    BACKUP="False"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo ROLE     = "${ROLE}"
echo LOGGING  = "${LOGGING}"
echo IP       = "${IP}"
echo MASK     = "${MASK}"
echo BACKUP   = "${BACKUP}"
echo ""

if [ "${BACKUP}" = "False" ]; then
   echo "BACKUP: OFF" >&2
else
    if [ -f /etc/ntp.conf.bak ]; then #Test if /etc/ntp.conf.bak already exists
        echo "BACKUP alread exists" >&2
    else 
        cp /etc/ntp.conf /etc/ntp.conf.bak #Create backup of /etc/ntp.conf
        echo "BACKUP: ON - see /etc/ntp.conf.bak" >&2
    fi
fi

sed -i -e '1!d' /etc/ntp.conf #Delete all but the first line in /etc/ntp.conf
echo "driftfile /var/lib/ntp/ntp.drift" >> /etc/ntp.conf
echo "restrict -4 default kod notrap nomodify nopeer noquery" >> /etc/ntp.conf
echo "restrict -6 default kod notrap nomodify nopeer noquery" >> /etc/ntp.conf
echo "restrict 127.0.0.1" >> /etc/ntp.conf
echo "restrict ::1" >> /etc/ntp.conf

if [ "${LOGGING}" = "False" ]; then
   echo "LOGGING: OFF" >&2
else
    sed -i -e '/statsdir/d' /etc/ntp.conf
    echo "statsdir /var/log/ntpstats/" >> /etc/ntp.conf #Modify /etc/ntp.conf to log stats
    echo "statistics loopstats peerstats clockstats" >> /etc/ntp.conf
    echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf
    echo "filegen peerstats file peerstats type day enable" >> /etc/ntp.conf
    echo "filegen clockstats file clockstats type day enable" >> /etc/ntp.conf

    echo "LOGGING: ON" >&2
fi

if [ "${ROLE}" = "C" ]; then
   echo "server ${IP}" >> /etc/ntp.conf
   #service ntp restart
   echo "CLIENT: CONFIGURED" >&2
elif [ "${ROLE}" = "S" ]; then
    echo "server 0.debian.pool.ntp.org iburst" >> /etc/ntp.conf
    echo "server 1.debian.pool.ntp.org iburst" >> /etc/ntp.conf
    echo "server 2.debian.pool.ntp.org iburst" >> /etc/ntp.conf
    echo "server 3.debian.pool.ntp.org iburst" >> /etc/ntp.conf
    echo "broadcast ${IP}" >> /etc/ntp.conf
    #service ntp restart
    echo "SERVER: CONFIGURED" >&2
else
    echo "NO ROLE: CONFIGURED" >&2
fi