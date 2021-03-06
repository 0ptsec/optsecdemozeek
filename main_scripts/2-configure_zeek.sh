#!/bin/bash

echo -e "$(tput setaf 3)$(tput bold)===============================Running configure_zeek.sh=================================$(tput sgr0)\n"

echo -e "$(tput setaf 1)$(tput bold)*****Make sure both NICs are plugged in and up or Bro will not see all interfaces!*****$(tput sgr0)\n"
read -n 1 -s -r -p "$(tput setaf 1)$(tput bold)Press any key to continue or ctrl+c to cancel.$(tput sgr0)"
echo -e "\n"


#Configure Zeek ================

#Configure node.cfg
sudo /usr/local/bin/gen-node-cfg.sh
#node.cfg change cores from 2 to 3
sudo sed -i.bak -e 's@^lb_procs.*@lb_procs=3@' /opt/zeek/etc/node.cfg

sudo sed -i.bak2 -e 's@^lb_method.*@lb_method=pf_ring\npin_cpus=1,2,3@' /opt/zeek/etc/node.cfg


if ! grep -q '^10\.0\.0\.0/8' /opt/zeek/etc/networks.cfg ; then
        echo '10.0.0.0/8      Private IP space' | sudo tee -a /opt/zeek/etc/networks.cfg >/dev/null
fi
if ! grep -q '^172\.16\.0\.0/12' /opt/zeek/etc/networks.cfg ; then
        echo '172.16.0.0/12      Private IP space' | sudo tee -a /opt/zeek/etc/networks.cfg >/dev/null
fi
if ! grep -q '^192\.168\.0\.0/16' /opt/zeek/etc/networks.cfg ; then
        echo '192.168.0.0/16      Private IP space' | sudo tee -a /opt/zeek/etc/networks.cfg >/dev/null
fi


if grep -q '^ZeekArgs' /opt/zeek/etc/zeekctl.cfg ; then
        echo "WARNING: /opt/zeek/etc/zeekctl.cfg contains a ZeekArgs line already, please manually insert the BPF filter." >&2
else
        echo "ZeekArgs = -f '(port 53 or not ((src net 10.0.0.0/8 or src net 172.16.0.0/12 or src net 192.168.0.0/16 or src net 169.254.0.0/16) and (dst net 10.0.0.0/8 or dst net 172.16.0.0/12 or dst net 192.168.0.0/16 or dst net 169.254.0.0/16)) )'" | sudo tee -a /opt/zeek/etc/zeekctl.cfg >/dev/null
        #No need to do a sudo zeekctl deploy here - we do it unconditionally below
fi

echo "$(tput setaf 1)$(tput bold)Please review config files to ensure accuracy$(tput sgr0)"
sudo cat /opt/zeek/etc/node.cfg | sudo tee zeek_cpus_used.txt
sudo cat /opt/zeek/etc/networks.cfg | sudo tee zeek_networks_config.txt

echo -e "$(tput setaf 3)$(tput bold)=====================done======================$(tput sgr0)\n"
read -n 1 -s -r -p "$(tput setaf 3)$(tput bold)Press any key to continue to script 3 or ctrl+c to cancel.$(tput sgr0)"
echo -e "\n"
SCRIPT_PATH="$(pwd)/3-install_ja3_plugin.sh"
if [ ! -f $SCRIPT_PATH ]
then
       echo "File does not exist!"
else
      echo "$(tput setaf 3)$(tput bold)=====================Running $SCRIPT_PATH=======================$(tput sgr0)\n"

     "$SCRIPT_PATH"

fi
