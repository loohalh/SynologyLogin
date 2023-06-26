#!/bin/bash

user="root"
sourceSecureSignInFile="SecureSignIn/"
sourceSecureLoginFile="login/"
sourceFile="tmp/"
loginFileBackup="./"

nasFileBackup="/usr/syno/synoman/webman/login-backup.gz"
nasFile="/usr/syno/synoman/webman/"

echo -e "\n---- One click optimization plan for synology 7.2 login. by looha ----\n"

if [ "$(ls -A $Login)" ]; then
     echo -e "Login Files are ready"
else
    echo "xxxxx- Login Files is not ready xxxxx-"
    exit 1
fi

if [ "$(ls -A $SecureSignIn)" ]; then
     echo "SecureSignIn Files are ready"
else
    echo -e "xxxxx- SecureSignIn Files is not ready xxxxx-\n"
    exit 1
fi

find . -name '*.DS_Store' -type f -delete


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
cp -r $sourceSecureSignInFile $sourceSecureLoginFile $sourceFile

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

send \"mkdir /usr/syno/synoman/webman/login-backup \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/login \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/login/dist \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/login/dist/assets \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/SecureSignIn \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/SecureSignIn/images \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/SecureSignIn/images/1x \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/SecureSignIn/images/2x \r\"
send \"mkdir /usr/syno/synoman/webman/login-backup/SecureSignIn/login-dist \r\"

send \"cd /usr/syno/synoman/webman/login/dist \r\"
send \"cp style.css style.css.gz 207.style.css 207.style.css.gz 586.style.css 586.style.css.gz dsm.login.bundle.b55fe1527944f266747a.1.js dsm.login.bundle.b55fe1527944f266747a.1.js.gz dsm.login.bundle.js dsm.login.bundle.js.gz /usr/syno/synoman/webman/login-backup/login/dist \r\"
send \"rm style.css style.css.gz 207.style.css 207.style.css.gz 586.style.css 586.style.css.gz dsm.login.bundle.b55fe1527944f266747a.1.js dsm.login.bundle.b55fe1527944f266747a.1.js.gz dsm.login.bundle.js dsm.login.bundle.js.gz \r\"
send \"cd /usr/syno/synoman/webman/tmp/login/dist \r\"
send \"cp style.css 207.style.css 586.style.css dsm.login.bundle.b55fe1527944f266747a.1.js dsm.login.bundle.js /usr/syno/synoman/webman/login/dist \r\"
send \"cd /usr/syno/synoman/webman/login/dist \r\"

send \"gzip -c style.css > style.css.gz \r\"
send \"gzip -c 207.style.css > 207.style.css.gz \r\"
send \"gzip -c 586.style.css > 586.style.css.gz \r\"
send \"gzip -c dsm.login.bundle.b55fe1527944f266747a.1.js > dsm.login.bundle.b55fe1527944f266747a.1.js.gz \r\"
send \"gzip -c dsm.login.bundle.js > dsm.login.bundle.js.gz \r\"

send \"cd /usr/syno/synoman/webman/login/dist/assets \r\"
send \"cp 0e6ee22eee14be537471.png 3a236916275f306825d5.png 29e0c870c4932c96ed18.png 4368a7914ca986f4a78a.png 44186a343f9925a2e1a5.png fbfeb823259b714c6c23.png dd4d99313e7d895f16a4.png f1835d0150bbc44c8775.png  /usr/syno/synoman/webman/login-backup/login/dist/assets \r\"
send \"rm 0e6ee22eee14be537471.png 3a236916275f306825d5.png 29e0c870c4932c96ed18.png 4368a7914ca986f4a78a.png 44186a343f9925a2e1a5.png fbfeb823259b714c6c23.png dd4d99313e7d895f16a4.png f1835d0150bbc44c8775.png \r\"
send \"cd /usr/syno/synoman/webman/tmp/login/dist/assets \r\"
send \"cp 0e6ee22eee14be537471.png 3a236916275f306825d5.png 29e0c870c4932c96ed18.png 4368a7914ca986f4a78a.png 44186a343f9925a2e1a5.png fbfeb823259b714c6c23.png dd4d99313e7d895f16a4.png f1835d0150bbc44c8775.png /usr/syno/synoman/webman/login/dist/assets \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/1x \r\"
send \"cp icn_32_Key.png icn_32_approve_sign_in.png /usr/syno/synoman/webman/login-backup/SecureSignIn/images/1x \r\"
send \"rm icn_32_approve_sign_in.png icn_32_Key.png \r\"
send \"cd /usr/syno/synoman/webman/tmp/SecureSignIn/images/1x \r\"
send \"cp icn_32_Key.png icn_32_approve_sign_in.png /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/1x \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/2x \r\"
send \"cp icn_32_Key.png icn_32_approve_sign_in.png /usr/syno/synoman/webman/login-backup/SecureSignIn/images/2x \r\"
send \"rm icn_32_approve_sign_in.png icn_32_Key.png \r\"
send \"cd /usr/syno/synoman/webman/tmp/SecureSignIn/images/2x \r\"
send \"cp icn_32_Key.png icn_32_approve_sign_in.png /usr/syno/synoman/webman/3rdparty/SecureSignIn/images/2x \r\"

send \"cd /usr/syno/synoman/webman/3rdparty/SecureSignIn/login-dist \r\"
send \"cp 902.SecureSignInLogin.css /usr/syno/synoman/webman/login-backup/SecureSignIn/login-dist \r\"
send \"rm 902.SecureSignInLogin.css \r\"
send \"cd /usr/syno/synoman/webman/tmp/SecureSignIn/login-dist \r\"
send \"cp 902.SecureSignInLogin.css /usr/syno/synoman/webman/3rdparty/SecureSignIn/login-dist \r\"


send \"rm -rf /usr/syno/synoman/webman/tmp \r\"

send \"cd /usr/syno/synoman/webman \r\"
send \"rm login-backup.gz \r\"
send \"tar -czvf login-backup.gz login-backup \r\"
send \"rm -rf /usr/syno/synoman/webman/tmp \r\"
send \"rm -rf /usr/syno/synoman/webman/login-backup \r\"

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

