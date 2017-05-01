#!/bin/sh
# Robert Bennett 8 March 2013
#


export PATH=/bin:/usr/bin:/etc:/usr/sbin:/sbin
export HOST=`(hostname | awk -F . '{print $1}')`
export DATE=`(date --rfc-3339 date)`

export DOCSYS_FILE=/tmp/docsys.$HOST.$DATE
echo > $DOCSYS_FILE
echo "Docsys:" >> $DOCSYS_FILE
echo "------------" >> $DOCSYS_FILE

export REMIND_FILE=/tmp/docsys.$HOST.remind.$DATE
echo > $REMIND_FILE
echo "Reminders:" >> $REMIND_FILE
echo "------------" >> $REMIND_FILE

exit_gracefully() {
#rm $REMIND_FILE
exit 0
}

remind() {
echo $1 >> $REMIND_FILE
echo "---" >> $REMIND_FILE
}

trap "exit_gracefully" SIGTERM SIGINT 

dateit () {
echo "Date:"
echo "--------"
date
echo
}

modelit () {
echo
echo "<A NAME="Model">Model:</A>"
echo "--------"
dmidecode | awk '/0x0001/{x=NR+6;next}(NR<=x){print}' | grep -v Version | grep -v Serial
}


hostit () {
echo
echo "<A NAME="Hosts_it">Hosts it:</A>"
echo "--------"
cat /etc/hosts
}

sup_info () {
echo
echo "<A NAME="Support_info">Support info:</A>"
echo "-------------"
if [ -f /etc/support ] ; then
   cat /etc/support
else
   echo The /etc/support file needs to be created.
   remind "The /etc/support file needs to be created."
fi
}

load () {
echo
echo "<A NAME="Load_Avg">Load Avg:</A>"
echo "-------------"
uptime | awk '{print $8, $9, $10, $11, $12}'
}


sys_info () {
# List The system
echo
echo "<A NAME="System_info">System info:</A>"
echo "---------------"
hostname
uname -a
}

umask_info () {
# umask
echo
echo "<A NAME="Umask">umask:</A>"
echo "--------"
umask
}

hostname_info () {
# hostname
echo 
echo "<A NAME="Hostname">Hostname:</A>"
echo "-----------"
hostname
}

swap_info () {
# Swap info
echo
echo "<A NAME="Swapinfo">Swapinfo:</A>"
echo "-----------"
/root/bin/swap_mon.sh
}

mem_info () {
# Memory Size
TOT=`cat /proc/meminfo | grep MemTotal: | awk '{print $2}'`
TOTMB=$[ $TOT / 1024 ]
echo
echo "<A NAME="Real_Memory_Size">Real memory Size:</A>"
echo "------------------"
echo "Total Real Memory: $TOTMB MB"
}

slab_info () {
# Memory Slab Information
echo
echo "<A NAME="Memory_slab_info">Memory Slab Info:</A>"
echo "------------------"
cat /proc/slabinfo
}

kernel_parms () {
# OS kernel parms
echo
echo "<A NAME="Kernel_Parms">Kernel Parms:</A>"
echo "-------------------------"
REL=`(uname -r)`
cat /boot/config-$REL
}

system_start () {
# System Startup
echo
echo "<A NAME="System_Startup_Shutdown">System Startup/Shutdown:</A>"
echo "-------------------------"
echo /etc/inittab
cat /etc/inittab | grep -v '#'
echo
echo "<A NAME="chkconfig">chkconfig:</A>"
echo "-------------------------"
echo chkconfig
chkconfig
echo
if [ -s /etc/shutdown.allow ] ; then
        echo "/etc/shutdown.allow"
        echo "---------------------"
        cat /etc/shutdown.allow
fi
}

cron_info () {
# crontab
echo
echo "<A NAME="Cron_stuff">Cron stuff:</A>"
echo "root crontab:"
echo "--------------------------------------"
crontab -l
echo
echo "The allow and/or deny files will be shown followed by their contents (if any)."
echo "------------------------------------------------------"
if [ -s /etc/cron.allow ]; then
		echo "/etc/cron.allow"
		echo "-------------------------"
		cat /etc/cron.allow
fi

if [ -s /etc/cron.deny ]; then
		echo "/etc/cron.deny"
		echo "-------------------------"
		cat /etc/cron.deny
fi

if [ -s /etc/at.allow ]; then
		echo "/etc/at.allow"
		echo "-------------------------"
		cat /etc/at.allow
fi

if [ -s /etc/at.deny ]; then
		echo "/etc/at.deny"
		echo "-------------------------"
		cat /etc/at.deny
fi
}


ager_info () {
# ager
echo
echo "<A NAME="Ager_Info">Ager Info:</A>"
echo "-------------------------"
if [ -f /root/bin/agelist ] ; then
	echo /root/bin/agelist
	/usr/bin/cat /root/bin/agelist
fi
}


lan_info () {
# List the Lan Info.
echo
echo "<A NAME="Lan_Info">Lan Info:</A>"
echo "----------------"
ifconfig
echo
echo "/etc/sysconfig/network parms"
echo "------------------------------"
cat /etc/sysconfig/network

# Netstat
echo
echo "<A NAME="Netstat_-i">Netstat -i:</A>"
echo "---------------"
netstat -i
echo
echo "<A NAME="Netstat_-r">Netstat -r:</A>"
echo "---------------"
netstat -r

#ifcfg
echo
echo "<A NAME="ifcfg">ifcfg:</A>"
echo "---------------"
for i in $(netstat -i | grep -e bond -e eth | awk '{print $1}'); do
		echo
		cat /etc/sysconfig/network-scripts/ifcfg-$i
		echo "---------------"
done

# bonding.conf
echo
echo "<A NAME="bonding.conf">bonding.conf:</A>"
echo "---------------"
cat /etc/modprobe.d/bonding.conf
echo

# sysctl.conf
echo
echo "<A NAME="sysctl.conf">sysctl.conf:</A>"
echo "---------------"
cat /etc/sysctl.conf
echo

}


ns_info () {
# nsswitch.conf
echo
echo "<A NAME="nsswitch.conf">nsswitch.conf:</A>"
if [ -f /etc/nsswitch.conf ] ; then
        echo
        echo "/etc/nsswitch.conf was found. Here it is:</A>"
        echo "------------------------------------------"
        cat /etc/nsswitch.conf
else
        echo "No /etc/nsswitch was found.</A>"
fi
}

dns_client_info () {
# DNS client config?
echo
echo "<A NAME="DNS_Client_Information_/etc/resolv.conf">DNS Client Information /etc/resolv.conf:</A>"
echo "--------------------------------------------"
if [ -f /etc/resolv.conf ] ; then
        cat /etc/resolv.conf
else
        echo "Doubt it."
        echo "/etc/resolv.conf does not exist on this system."
fi
}

dns_server_info () {
# DNS Server
echo
echo "<A NAME="DNS_Server">DNS Server:</A>"
echo "------------"
if [ -f /etc/named.boot ] ; then
        echo "Might be. Here is named.boot"
        cat /etc/named.boot
        remind "Print any files listed above if necessary"
else
        echo "/etc/named.boot does not exist on this system."
fi
}

inetd_info () {
echo
echo "<A NAME="/etc/xinetd.conf">/etc/xinetd.conf:</A>"
echo "---------------"
cat /etc/xinetd.conf
}

services_info () {
# /etc/services
echo
echo "<A NAME="/etc/services">/etc/services:</A>"
echo "-----------------"
cat /etc/services
}

dhcp_info () {
# dhcp
echo
echo "<A NAME="Looking_for_dhcpd">Looking for dhcpd:</A>"
echo "---------------------"
if ps -e|grep dhcpd ; then
        if [ -f /etc/dhcp/dhcp.conf ] ; then
                echo "/etc/dhcp/dhcp.conf"
                cat /etc/dhcp/dhcp.conf
        else
                echo "/etc/dhcp/dhcp.conf does not exist on this system."
        fi
else
        echo "The dhcp daemon is not running."
fi
}

xntpd_info () {
# xntpd
echo
echo "<A NAME="xntpd_config">xntpd config:</A>"
echo "---------------------"
if ps -e|grep xntpd ; then
        echo "xntpd looks to be running."
        if [ -f /etc/ntp.conf ] ; then
                echo "/etc/ntp.conf was found. May need to print it."
                remind "/etc/ntp.conf was found. May need to print it."
        else
                echo "/etc/ntp.conf was not found."
        fi
else
        echo "xntpd not running."

fi
}

user_info () {
echo
echo "<A NAME="/etc/passwd">/etc/passwd:</A>"
echo "---------------"
cat /etc/passwd
echo
echo "<A NAME="/etc/group">/etc/group:</A>"
echo "---------------"
cat /etc/group
}

tune_info () {
echo
echo "<A NAME="/etc/tune-profiles/active-profile" /etc/tune-profiles/active-profile:</A>"
if [ -f /etc/tune-profiles/active-profile ]; then
		cat /etc/tune-profiles/active-profile
else
		echo "/etc/tune-profiles/active-profile does not exist"
fi
}

nis_info () {
# NIS
echo
echo "<A NAME="Basic_NIS_info">Basic NIS info:</A>"
echo "---------------------"
if ps -e|grep "ypbind" ; then
        echo "Look to be running NIS."
        echo DOMAINNAME: `domainname`
        echo "Running ypwhich, bound to:" `ypwhich`
        if grep ^+ /etc/passwd ; then
                echo "Looks like you are using NIS in /etc/passwd."
                remind "Looks like you are using NIS in /etc/passwd."
        fi
        if grep ^+ /etc/group ; then
                echo "Looks like you are using NIS in /etc/group."
                remind "Looks like you are using NIS in /etc/group."
        fi
fi

if ps -e|grep "ypserv" ; then
        if ypcat -k ypservers|grep `hostname` ; then
                echo "System is running ypserv and this system is in the ypservers map."
                remind "System is running ypserv and this system is in the ypservers map."
                
        else
                echo "System is running ypserv, but not in ypservers map. Hmm... You may want to chec this out."
                remind "System is running ypserv, but not in ypservers map. Hmm... You may want to chec this out."
        fi
                
fi      

if ps -e|grep "yppasswdd" ; then
        echo "Look to be the NIS password daemon server."
        remind "Look to be the NIS password daemon server."
fi

}

nfs_info () {
# NFS
echo
echo "<A NAME="Any_NFS_exports_or_automounter_stuff">Any NFS exports or automunter stuff:</A>"
echo "---------------------"
echo /usr/sbin/exportfs
/usr/sbin/exportfs
if [ -f /etc/exports ] ; then
        echo "/etc/exports"
        cat /etc/exports
		echo
		echo showmount
		showmount
else
        echo "/etc/exports not found."
fi
echo "Running ps to see if automounter is running now."
if ps -e|grep automount ; then
        echo "Automount looks to be running. The info for automount should be gathered."
        remind "Automount looks to be running. The info for automount should be gathered."
else
        echo "Could not find the automounter running."
fi

echo
echo "<A NAME="/etc/sysconfig/nfs">/etc/sysconfig/nfs:</A>"
echo "---------------------"
cat /etc/sysconfig/nfs

}

        
sendmail_info () {
# Sendmail
echo
echo "<A NAME="Sendmail_Config">Sendmail Config:</A>"
echo "---------------------"
if ps -e|grep sendmail ; then
        echo "sendmail looks to be running."
				if [ -f /etc/mail/sendmail.cf ]; then
						echo "Print /etc/mail/sendmail.cf"
						cat /etc/mail/sendmail.cf
  				else
						echo "sendmail seems to be running, but I could not find a sendmail.cf file"
				fi
else
		echo "sendmail does not appear to be running"
fi 
}

shells_info () {
# /etc/shells
echo
echo "<A NAME="/etc/shells">/etc/shells:</A>"
echo "--------------"
if [ -f /etc/shells ] ; then
        echo "/etc/shells was found, here it is:"
        cat /etc/shells
else
        echo "No /etc/shells was found."
fi
}

disk_info () {
# List the disk drives with errorsj
echo
echo "<A NAME="The_system_Disk_Drives">The system Disk Drives:</A>"
echo "--------------------------------------------------------------"
/root/bin/diskreport.sh
cat /tmp/diskreport.txt
echo
/usr/local/bin/MegaCli64 -PDList -aAll | grep -e "Enclosure Device" -e "Slot Number" -e "Enclosure Position" -e "Device Id" -e "Sequence Number" -e Error | grep -v 0 | grep -B4 "Error"
echo
/usr/local/bin/MegaCli64 -PDList -aAll | grep -e "Enclosure Device" -e "Slot Number" -e "Enclosure Position" -e "Device Id" -e "Sequence Number"  -e Failure | grep -v 0 | grep -B4 "Failure"
}

lvm_info () {
echo
echo "<A NAME="LVM_Info">LVM Info:</A>"
echo "-----------------------"
lvm dumpconfig
echo
echo "<A NAME="pvs">pvs:</A>"
echo "----------------------------"
pvs
echo
echo "<A NAME="vgs">vgs:</A>"
echo "----------------------------"
vgs
echo
echo "<A NAME="lvs">lvs:</A>"
echo "----------------------------"
lvs
echo
echo "<A NAME="vgdisplay">vgdisplay:</A>"
echo "----------------------------"
vgdisplay -v
echo
}

fs_info () {
# List the mounted file systems
echo
echo "<A NAME="DF_Output">DF Output:</A>"
echo "----------------------------"
df
}

fstab_info () {
# List fstab
echo
echo "<A NAME="fstab_information">The fstab information:</A>"
echo "----------------------------"
echo
cat /etc/fstab
}

xfs_information () {
# xfs_information
echo
echo "<A NAME="xfs_information">The XFS Information:</A>"
echo "----------------------------"
echo
for i in $(more /etc/fstab | grep -i xfs | grep -v ^# | awk '{print $2}')
do 
echo $i
/usr/sbin/xfs_info $i
echo
done
}

fdisk_info () {
# List the fdisk info
echo
echo "<A NAME="The_fdisk_information">The fdisk information:</A>"
echo "----------------------------"
fdisk -l
echo
}

grub_info () {
# List grub.conf
echo
echo "<A NAME="grub.conf_information">The grub.conf information:</A>"
echo "----------------------------"
echo
cat /boot/grub/grub.conf
}

cpu_info () {
# cpuinfo
echo
echo "<A NAME="cpu_information">CPU Information:</A>"
echo "----------------------------"
echo
cat /proc/cpuinfo
}

io_info () {
# List all attached hardware
echo
echo "<A NAME="The_entire_IO_subsystem">The entire IO subsystem:</A>"
echo "---------------------------------------------------"
lspci
echo
lsusb
echo
lshal
}

sw_info () {
# List Installed SW
echo
echo "<A NAME="Installed_Software">Installed Software:</A>"
echo "-----------------------------------------"
rpm -qa
}

# Main Program
dateit
sys_info
sup_info
load
umask_info
hostname_info
modelit
swap_info
mem_info
slab_info
kernel_parms
system_start
chkconfig
cron_info
ager_info
lan_info
ns_info
dns_client_info
dns_server_info
inetd_info
dhcp_info
services_info
hostit
xntpd_info
user_info
tune_info
nis_info
nfs_info
sendmail_info
shells_info
lvm_info
disk_info
fs_info
fstab_info
xfs_information
fdisk_info
grub_info
cpu_info
io_info
sw_info 

cat $REMIND_FILE
exit_gracefully



