#!/bin/bash

# See also:
# http://autoshun.org/
# http://doc.emergingthreats.net/bin/view/Main/EmergingFirewallRules
# http://adityamukho.com/blog/2014/06/18/using-ipset-manage-blacklists-firewall/
# http://daemonkeeper.net/781/mass-blocking-ip-addresses-with-ipset/
# http://www.stopforumspam.com/downloads/toxic_ip_cidr.txt

# Require git
apt-get -qq --assume-yes install curl git > /dev/null

if [[ ! -e /usr/local/bin/autorestart-services.sh ]]; then

	git clone https://github.com/cdg46/services-auto-restart.git
	cd services-auto-restart

	# Install in system
	mv autorestart-services.sh /usr/local/bin/
	chmod +x /usr/local/bin/autorestart-services.sh

	cd ../
	rm -R services-auto-restart
fi

# Create a CRON script that runs each day to update our blacklists
if [[ ! -e /etc/cron.h/autorestart-services ]]; then
cat > /etc/cron.h/autorestart-services <<END
# Run every 10 minutes
*/10 * * * *      root /usr/local/bin/autorestart-services.sh
END

fi
# Done
