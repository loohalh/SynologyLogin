#!/bin/bash
# by looha

port="22"

echo -e "\n---- One click activation of synology root account login. by looha ----\n"

echo -e "\n*****************************************************************"
echo -e "* You are about to enter the synology IP and username password      *"
echo -e "* Please ensure that synology has enabled SSH login             *"
echo -e "* enabled the root username, and set the username account password   *"
echo -e "*****************************************************************\n"

read -p "Please enter the synology IP：
for example 192.168.1.1 : " host

read -p "Please enter the synology username：
" username

read -p "Please enter the synology username passwd ：
" passwd

read -p "Please set a password for the root account
" rootPwd

if [ -n "$host" -a -n "$username" -a -n "$passwd" -a -n "$rootPwd" ]
then
    echo -e "\n**** Synology's IP is $host, the username is $username, the username password is $passwd, and the root account password will be set to $rootPwd ****"
else
    echo "xxxxx- Error: There is an error in the information input. Please carefully check and rerun xxxxx-"
    exit 1
fi

ssh-keygen -R "$host"

# Check for connectivity
echo -e "\n*********** Check synology connection status ***********\n"
ping -c 1 $host > /dev/null

if [ $? -eq 0 ]; then
  echo "The synology connect is ok"
else
  echo -e "\nxxxxx- Error: The synology cannot connect. Please ensure that the synology is turned on and port 22 is open xxxxx-\n"
  exit
fi

echo -e "\n*********** Verifying account password ***********\n"

expect << EOF
spawn -noecho ssh -p $port $username@$host
expect {
    "*assword:" {
        send "$passwd\r"
        expect {
            "Permission denied" {
                exit 1
            }
            "*yes/no*" {
                send "yes\r"
                exp_continue
            }
            "$username@" {
                send "exit\r"
            }
            timeout {
                exit 1
            }
        }
    }
    "*yes/no*" {
        send "yes\r"
        exp_continue
    }
    
    timeout {
        exit 1
    }
}

EOF

#Verification results
if [ $? -eq 1 ]; then
    echo -e "\nxxxxx- Error: Account password error xxxxx-\n"
    exit 0
fi



echo -e "\n\n***************** Opening the root account *****************\n"
echo -e "\n**** login in $username@$host *****\n"

expect << EOF
set timeout -1
spawn -noecho ssh -p $port $username@$host

expect "assword: "
send "$passwd\r"

expect "$ "
send "sudo -i\r"

expect "Password: "
send "$passwd\r"

expect "# "
send "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \r"
send "sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/g' /etc/ssh/sshd_config \r"
send "sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/g' /etc/ssh/sshd_config \r"
send "synouser --setpw root $rootPwd \r"

expect "# "
send "systemctl restart sshd.service\r"

expect "# "
send "exit\r"

expect "$ "
send "exit\r"

expect eof
EOF

echo -e "\n****** Congratulations，Succeeded, Please enjoy it！ ******\n"

echo -e "\n********************** end **************************************\n"
