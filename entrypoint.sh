#!/bin/sh

# Setup Forward Lookup Name Servers
NS1="${NS1:-8.8.8.8}"
NS2="${NS2:-8.8.4.4}"

sed -i "s/server=.* # NS1.*/server=$NS1 # NS1/" /etc/dnsmasq.conf
sed -i "s/server=.* # NS2.*/server=$NS2 # NS2/" /etc/dnsmasq.conf

# Set the containers name servers - so it can download the blacklist even if the host is using this container as DNS.
echo "nameserver $NS1" > /etc/resolv.conf
echo "nameserver $NS2" >> /etc/resolv.conf

# Enable/Disable Debug Mode
if [[ "$DEBUG" -eq "1" ]]; then
  sed -i "s/.*log-queries.*/log-queries/" /etc/dnsmasq.conf
elif [[ "$DEBUG" -eq "2" ]]; then
  sed -i "s/.*log-queries.*/log-queries=extra/" /etc/dnsmasq.conf
else
  sed -i "s/.*log-queries.*/#log-queries/" /etc/dnsmasq.conf
fi

# Enable/Disable DNSSEC
if [[ "$DNSSEC" -eq "1" ]]; then
  sed -i "s/.*dnssec/dnssec/" /etc/dnsmasq.conf
else
  sed -i "s/.*dnssec/#dnssec/" /etc/dnsmasq.conf
fi

# Download the latest blocklist
/sbin/update.sh

# Enable/Disable Auto Update Mode
AUTO_UPDATE="${AUTO_UPDATE:-1}"

if [[ "$AUTO_UPDATE" -eq "1" ]]; then
  echo "0	*	*	*	*	/sbin/update.sh" > /var/spool/cron/crontabs/root
  /usr/sbin/crond -b
else
  > /var/spool/cron/crontabs/root
fi

exec "$@"
