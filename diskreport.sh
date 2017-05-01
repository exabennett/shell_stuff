#!/bin/sh

OUTPUT=/tmp/diskreport.txt

if
    [ -f /tmp/diskreport.txt ]
then
    rm $OUTPUT
fi

date > $OUTPUT
echo "" >> $OUTPUT
echo "$HOSTNAME Disk Report" >> $OUTPUT

/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllinfo -aALL | grep -e Adapter -e "Device Present" -e "Virtual Drives" -e Degraded -e Offline -e "Physical Devices" -e Disks -e "Critical Disks" -e "Failed Disks" -e "Error Counters" -e "Memory Correctable" -e "Memory Uncorrectable" | grep -v "Any Offline" | grep -v "Supported Adapter" | grep -v "Force Offline" >> $OUTPUT

mail -s "$HOSTNAME Disk Report" exabennett@gmail.com < $OUTPUT

