#!/bin/sh
set -e
set -x

# Is CUPSADMIN set? If not, set to default
if [ -z "$CUPSADMIN" ]; then
    CUPSADMIN="cupsadmin"
fi

# Is CUPSPASSWORD set? If not, set to $CUPSADMIN
if [ -z "$CUPSPASSWORD" ]; then
    CUPSPASSWORD=$CUPSADMIN
fi

if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    useradd -G lpadmin --no-create-home $CUPSADMIN
fi
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

# restore default cups config in case user does not have any
if [ ! -f /etc/cups/cupsd.conf ]; then
    echo "***************************************"
    echo "* Copying default configuration files *"
    echo "***************************************"
    cp -rpnv /cups-config-default/* /etc/cups/
fi

/usr/sbin/avahi-daemon --daemonize
/root/printer-update.sh &
exec /usr/sbin/cupsd -f
