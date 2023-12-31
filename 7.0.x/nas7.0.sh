#!/bin/bash
# by looha

user="root"
port="22"
sourceSecureWebmanFile="webman/"
sourceSecureMobileFile="mobile/"
sourceFile="tmp/"
loginFileBackup="./"
                
nasFileBackup="/usr/syno/synoman/login-backup.gz"
nasFile="/usr/syno/synoman/"

echo -e "\n---- One click optimization plan for synology 7.0.x login. by looha ----\n"

if [ "$(ls -A $sourceSecureWebmanFile)" ]; then
     echo -e "Webman Files are ready"
else
    echo "\nxxxxx- Error: Webman Files is not ready xxxxx-"
    exit 1
fi

if [ "$(ls -A $sourceSecureMobileFile)" ]; then
     echo "mobile Files are ready"
else
    echo -e "\nxxxxx- Error: mobile Files is not ready xxxxx-\n"
    exit 1
fi

#start
echo -e "\n*****************************************************************"
echo -e "* You are about to enter the synology IP and root password      *"
echo -e "* Please ensure that synology has enabled SSH login             *"
echo -e "* enabled the root account, and set the root account password   *"
echo -e "*****************************************************************\n"


read -p "Please enter the synology IP：
for example 192.168.1.1 : " host
read -p "Please enter the correct password for the synology root :
" passwd

if [ -n "$host" -a -n "$passwd" ]
then
    echo -e "\n**** Synology's IP is $host, and the root password is $passwd ****"
else
    echo "\nxxxxx- Error: Synology IP or root password not entered xxxxx-"
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
spawn -noecho ssh -p $port $user@$host
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
            "$user@" {
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


echo -e "\n********************** start **************************************\n"

#Prepare the documents
if [ "$(ls -A $tmp)" ]; then rm -rf tmp; fi
mkdir $sourceFile
cp -r $sourceSecureWebmanFile $sourceSecureMobileFile $sourceFile

find . -name '*.DS_Store' -type f -delete

#--------------------------------------------------------------
echo -e "\n***************** upload resources ... ****************\n"
expect -c "
set timeout 30
spawn -noecho scp -r $sourceFile $user@$host:$nasFile
expect {
\"*yes/no\" { send \"yes\r\"; exp_continue }
\"*?assword:\" { send \"$passwd\r\" }
}
interact
"
echo -e "\n\n***************** Resource upload completed *****************\n"

echo -e "\n **** login in $user@$host *****\n"
echo -e "***************** processing files  *****************\n"

expect -c "
set timeout 30
spawn -noecho ssh $user@$host
expect {
\"*yes/no\" { send \"yes\r\"; exp_continue }
\"*?assword:\" { send \"$passwd\r\" }
}
expect \"#\"

send \"mkdir /usr/syno/synoman/login-backup \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/css \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/assets \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/images \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/images/1x \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/images/2x \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn/images \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn/images/1x \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn/images/2x \r\"
send \"mkdir /usr/syno/synoman/login-backup/mobile \r\"
send \"mkdir /usr/syno/synoman/login-backup/mobile/ui \r\"

send \"cd /usr/syno/synoman/webman \r\"
send \"cp login-vue.js login-vue.js.gz /usr/syno/synoman/login-backup/webman \r\"
send \"rm login-vue.js login-vue.js.gz \r\"
send \"cd /usr/syno/synoman/tmp/webman \r\"
send \"cp login-vue.js /usr/syno/synoman/webman \r\"
send \"cd /usr/syno/synoman/webman \r\"
send \"gzip -c login-vue.js > login-vue.js.gz \r\"

send \"cd /usr/syno/synoman/webman/login/css \r\"
send \"cp login.css login.css.gz /usr/syno/synoman/login-backup/webman/login/css \r\"
send \"rm login.css login.css.gz \r\"
send \"cd /usr/syno/synoman/tmp/webman/login/css \r\"
send \"cp login.css /usr/syno/synoman/webman/login/css \r\"
send \"cd /usr/syno/synoman/webman/login/css \r\"
send \"gzip -c login.css > login.css.gz \r\"

send \"cd /usr/syno/synoman/webman/login/assets \r\"
send \"cp 1bc43875501e55e5e741e427ca50dbdf.png 1119db90544274a328d02d53bc45fc49.png 20839ea8a3aad9fb3f308aacbf7271ab.png /usr/syno/synoman/login-backup/webman/login/assets \r\"
send \"rm 1bc43875501e55e5e741e427ca50dbdf.png 1119db90544274a328d02d53bc45fc49.png 20839ea8a3aad9fb3f308aacbf7271ab.png \r\"
send \"cd /usr/syno/synoman/tmp/webman/login/assets \r\"
send \"cp 1bc43875501e55e5e741e427ca50dbdf.png 1119db90544274a328d02d53bc45fc49.png 20839ea8a3aad9fb3f308aacbf7271ab.png /usr/syno/synoman/webman/login/assets \r\"

send \"cd /usr/syno/synoman/webman/login/images/1x \r\"
send \"cp icn_password.png /usr/syno/synoman/login-backup/webman/login/images/1x \r\"
send \"rm icn_password.png \r\"
send \"cd /usr/syno/synoman/tmp/webman/login/images/1x \r\"
send \"cp icn_password.png /usr/syno/synoman/webman/login/images/1x \r\"

send \"cd /usr/syno/synoman/webman/login/images/2x \r\"
send \"cp icn_password.png /usr/syno/synoman/login-backup/webman/login/images/2x \r\"
send \"rm icn_password.png \r\"
send \"cd /usr/syno/synoman/tmp/webman/login/images/2x \r\"
send \"cp icn_password.png /usr/syno/synoman/webman/login/images/2x \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"cp SecureSignInLogin.css SecureSignInLogin.css.gz /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn \r\"
send \"rm SecureSignInLogin.css SecureSignInLogin.css.gz \r\"
send \"cd /usr/syno/synoman/tmp/webman/3rdparty/SecureSignIn \r\"
send \"cp SecureSignInLogin.css /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"gzip -c SecureSignInLogin.css > SecureSignInLogin.css.gz \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/1x \r\"
send \"cp icn_32_approve_sign_in.png icn_32_Key.png /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn/images/1x \r\"
send \"rm icn_32_approve_sign_in.png icn_32_Key.png \r\"
send \"cd /usr/syno/synoman/tmp/webman/3rdparty/SecureSignIn/images/1x \r\"
send \"cp icn_32_approve_sign_in.png icn_32_Key.png /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/1x \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/2x \r\"
send \"cp icn_32_approve_sign_in.png icn_32_Key.png /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn/images/2x \r\"
send \"rm icn_32_approve_sign_in.png icn_32_Key.png \r\"
send \"cd /usr/syno/synoman/tmp/webman/3rdparty/SecureSignIn/images/2x \r\"
send \"cp icn_32_approve_sign_in.png icn_32_Key.png /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/2x \r\"

send \"cd /usr/syno/synoman/mobile/ui \r\"
send \"cp style.css style.css.gz mobile.js mobile.js.gz /usr/syno/synoman/login-backup/mobile/ui \r\"
send \"rm style.css style.css.gz mobile.js mobile.js.gz \r\"
send \"cd /usr/syno/synoman/tmp/mobile/ui \r\"
send \"cp style.css mobile.js /usr/syno/synoman/mobile/ui \r\"
send \"cd /usr/syno/synoman/mobile/ui \r\"
send \"gzip -c style.css > style.css.gz \r\"
send \"gzip -c mobile.js > mobile.js.gz \r\"

send \"rm -rf /usr/syno/synoman/tmp \r\"

send \"cd /usr/syno/synoman \r\"
send \"rm login-backup.gz \r\"
send \"tar -czvf login-backup.gz login-backup \r\"
send \"rm -rf /usr/syno/synoman/login-backup \r\"

send \"exit \r\"

interact
"

echo -e "\n\n***************** saving backup files  *****************\n"
expect -c "
set timeout 30
spawn -noecho scp -r $user@$host:$nasFileBackup $loginFileBackup
expect {
\"*yes/no\" { send \"yes\r\"; exp_continue }
\"*?assword:\" { send \"$passwd\r\" }
}
interact
"

echo -e "\n***** successfully saved the backup file, Path: ./login-backup.gz *****\n"


rm -rf $sourceFile


echo -e "\n****** Congratulations，Succeeded, Please enjoy it！ ******\n"

echo -e "\n********************** end **************************************\n"

