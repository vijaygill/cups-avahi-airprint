FROM ubuntu:latest

RUN apt update && apt upgrade && \
	apt install -y \
    cups \
    avahi-daemon \
	inotify-tools \
    printer-driver-brlaser \
    printer-driver-cups-pdf \
	python3 \
	python3-pip \
    python3-cups \
    python3-cupshelpers \
	rsync \
    unison \
	wget

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /print2pdf
VOLUME /cups-config
VOLUME /avahi-services

# Add scripts
ADD root /
RUN chmod +x /root/*

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/LogLevel warn/LogLevel debug/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing Yes/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
    sed -i -r -e "s:^(Out\s).*:\1/print2pdf:" /etc/cups/cups-pdf.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	echo "AnonDirName /print2pdf" >> /etc/cups/cups-pdf.conf && \
    mv /etc/cups /cups-config-default && \
    ln -sf /cups-config /etc/cups && \
    rm -rf /etc/avahi/services && \
    ln -sf /avahi-services /etc/avahi/services && \
    echo "All done!"

#Run Script
CMD ["/root/run_cups.sh"]
