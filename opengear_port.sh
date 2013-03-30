#!/bin/bash

if [ `whoami` == "root" ]
then
echo ""
echo "Cannot run as root. Configuration file stored in your home directory contains password!"
exit 0
fi


if [ ! -f ~/.opengear_port.cfg ]
then

echo "Config File not Found!"
echo "Generating..."

echo "Enter your username"
read username
echo "Enter your password"
 stty -echo
read password
 stty echo

echo "username=$username" > ~/.opengear_port.cfg
echo "password=$password" >> ~/.opengear_port.cfg
chmod 700 ~/.opengear_port.cfg

fi

source ~/.opengear_port.cfg

if [ "$1" != "" ]
then
sleep 0
else
echo "opengear_port.sh"
echo "Usage: opengear_port.sh [interactive (yes/no)?] [hostname] [port] [speed (96, 19, 38, 57, 115)]"
exit 0
fi

if [ "$1" == "no" ]
then	

if test -z "$4"
	then
		exit 0
	fi

opengear_hostname=$2
port_num=$3
speed_num=$4


fi

if [ "$1" == "yes" ]
then

echo ""
echo "OpenGear hostname (e.g. bil1-con02)"
read opengear_hostname
echo "Desired Port?"
read port_num
echo "Port Speed?"
echo "1) 9600"
echo "2) 19200"
echo "3) 38400"
echo "4) 57600"
echo "5) 115200"
echo ""
read speed_num

fi

if [ $speed_num == "1" ]
then
speed=9600
elif [ $speed_num == "2" ]
then
speed=19200
elif [ $speed_num == "3" ]
then
speed=38400
elif [ $speed_num == "4" ]
then
speed=57600
elif [ $speed_num == "5" ]
then
speed=115200
elif [ $speed_num == "96" ]
then
speed=9600
elif [ $speed_num == "19" ]
then
speed=19200
elif [ $speed_num == "38" ]
then
speed=38400
elif [ $speed_num == "57" ]
then
speed=57600
elif [ $speed_num == "115" ]
then
speed=115200

fi

echo ""
echo "Speed set to $speed Baud, port $port_num on $opengear_hostname"
echo ""
echo "Please wait..."
terminal=vt100
curl -s -k --user $username:$password https://$opengear_hostname --cookie-jar /tmp/cookie --cookie /tmp/cookie --data "new.port$port_num=on&edit.port=$port_num&new.label=Port+$port_num&new.speed=$speed&new.charsize=8&new.parity=None&new.stop=1&new.flowcontrol=Hardware&new.protocol=RS232&new.mode=portmanager&new.loglevel=0&new.ssh=on&new.delay=&new.escapechar=&powerType=None&outletLabel=&new.power.username=&new.power.password=&new.power.confirm=&new.username=&new.password=&new.confirm=&new.terminal=$terminal&new.bridge.address=&new.bridge.port=&new.logfacility=Default&new.logpriority=Default&apply=Apply&outletLabels=&form=serialconfig" "https://$opengear_hostname/?form=serialconfig&action=edit&ports=$port_num" > /dev/null

echo "Done."
