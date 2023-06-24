#!/bin/bash

user="root"
sourceSecureWebmanFile="webman/"
sourceSecureMobileFile="mobile/"
sourceFile="tmp/"
loginFileBackup="./"
                
nasFileBackup="/usr/syno/synoman/login-backup.gz"
nasFile="/usr/syno/synoman/"

echo -e "\n---- One click optimization plan for synology 7.0 login. by looha ----\n"

if [ "$(ls -A $sourceSecureWebmanFile)" ]; then
     echo -e "Webman Files are ready"
else
    echo "xxxxx- Webman Files is not ready xxxxx-"
    exit 1
fi

if [ "$(ls -A $sourceSecureMobileFile)" ]; then
     echo "mobile Files are ready"
else
    echo -e "xxxxx- mobile Files is not ready xxxxx-\n"
    exit 1
fi

echo -e "\n*****************************************************************"
echo -e "* You are about to enter the synology IP and root password      *"
echo -e "* Please ensure that synology has enabled SSH login             *"
echo -e "* enabled the root account, and set the root account password   *"
echo -e "*****************************************************************\n"


read -p "Please enter the synology IP：
for example 192.168.1.1 : " host
read -p "Please enter the correct password for the synology root : " passwd
if [ -n "$host" -a -n "$passwd" ]
then
    echo -e "\n**** Synology's IP is $host, and the root password is $passwd ****"
else
    echo "xxxxx- Synology IP or root password not entered xxxxx-"
    exit 1
fi


echo -e "\n********************** start **************************************\n"


if [ "$(ls -A $tmp)" ]; then rm -rf tmp; fi
mkdir $sourceFile

echo -e "\n***************** upload resources ... ****************\n"
cp -r $sourceSecureWebmanFile $sourceSecureMobileFile $sourceFile

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
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/css \r\"
send \"mkdir /usr/syno/synoman/login-backup/webman/login/assets \r\"
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

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"cp SecureSignInLogin.css SecureSignInLogin.css.gz /usr/syno/synoman/login-backup/webman/3rdparty/SecureSignIn \r\"
send \"rm SecureSignInLogin.css SecureSignInLogin.css.gz \r\"
send \"cd /usr/syno/synoman/tmp/webman/3rdparty/SecureSignIn \r\"
send \"cp SecureSignInLogin.css /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn \r\"
send \"gzip -c SecureSignInLogin.css > SecureSignInLogin.css.gz \r\"

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

