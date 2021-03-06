#!/bin/bash



source /root/keystonerc_admin

## Get all VMs are running
openstack server list > /tmp/instance_list.h2
#vms_run=$(cat /tmp/instance_list.h2 | awk  '{ print $3 }' FS="|")
instances=$(cat /tmp/instance_list.h2 | awk  '{ print $3 }' FS="|" | egrep -v "^$|^ Name" | cut -d " " -f 2)
## Show usage statitics for instances

for instance in $instances
do
	nova diagnostics $instance > /tmp/us_$instance.h2 2&1>
	if [ ! -d /etc/check_mk/plugin/check_vm-$instance ]
		then 
			echo "OPENSTACK-VM-$instance /etc/check_mk/plugin/check_vm-$instance" >> /etc/check_mk/mrpe.cfg		
	fi
	f=$(cat /tmp/us_$instance.h2 | egrep "^ERROR|CommandError")
	if [ -z "$f" ]
	then
		memory=$(expr `cat /tmp/us_$instance.h2 | grep -w memory | head -n 1 | awk -F "|" {'print $3'} | cut -d " " -f 2` / 1024)
		txs=`cat /tmp/us_$instance.h2 | grep "_tx" | awk -F "|" {'print $2'} | cut -d " " -f 2`
		# for tx in $txs
		# do
			
		# done
		
		echo -e "echo \"$instance is UP.\"\nexit 0" > /etc/check_mk/plugin/check_vm-$instance
		chmod +x /etc/check_mk/plugin/check_vm-$instance
	else
		echo -e "echo \"$instance is DOWN\"\nexit 2" > /etc/check_mk/plugin/check_vm-$instance
		chmod +x /etc/check_mk/plugin/check_vm-$instance				
	fi	
done 

