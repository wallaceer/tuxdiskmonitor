#!/bin/sh
# Purpose: Monitor Linux disk space and send an email alert to $ADMIN
#CONFIGURATION
ALERT=90 # alert level 
ALERTDISK="/dev/sda1"
EMAILTO="ws@waltersanti.info" # dev/sysadmin email ID
SERVERNAME=$(hostname -f)
SUBJECT="[$SERVERNAME] - ℹ️ Disk space usage "
SUBJECT_ALARM="[$SERVERNAME] - ⚠️ ADisk space usage alarm"

# =============================
# Modalità test
# =============================
TEST_MODE=false
if [[ "$1" == "--test" ]]; then
    TEST_MODE=true
fi

# =============================
# Raccolta dati
# =============================
if $TEST_MODE; then
    CPU_USAGE=95
    RAM_USAGE=92
    DISK_USAGE=97
else
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk -F. '{print $1}')
    RAM_USAGE=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
fi

#Grep informations
#Grep disk space value for disk selected
sda1=$(df -H | grep -i -w '^/dev/sda1' | awk '{ print $5 }' | cut -d'%' -f1)

if [ "$sda1" -gt "$ALERT" ]; then
	wsalert="ALERT: $ALERTDISK quota is greater than $ALERT, the value is $sda1%"
else
	wsalert="No alert!"
fi

sda1_output=$(df -H | grep -i -w '^/dev/sda1' | awk '{ print $1 " " $2 " " $3 " " $4 " " $5 }')

#=============================

wsoutput=$(df -H) 

echo "$wsoutput\r\n$wsalert" | mail -s "$SUBJECT " "$EMAILTO"

