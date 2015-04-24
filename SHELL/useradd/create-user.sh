#!/bin/bash

### Yapodu
### Ryo Tamura
### 2015/04/07

USER="yapodu"
GROUP="yapodu"
PASSWORD="changeme1234"
ADDUID="4600"
ADDGID="4600"
DATE=`date +%Y%m%d%H%M`
USER_DIR=~${USER}
CREATE_LOG="create-user.sh.log"

USER_SSH_DIR=".ssh"
USER_SSH_AUTHKEY="authorized_keys"
USER_SSH_AUTHPATH=${USER_SSH_DIR}/${USER_SSH_AUTHKEY}

TMP_SSH_DIR="/tmp/.ssh"

SSHD_CONFIG="/etc/ssh/sshd_config"

SUDOERS="/etc/sudoers"

# ユーザー存在確認と作成
grep ${USER} /etc/passwd

if [ "$?" -eq 0 ]
then 
	echo "yapodu not create ${DATE}" >> ~yapodu/${CREATE_LOG}
else
	groupadd -g ${ADDGID} ${GROUP}
	useradd -g ${ADDGID} -u ${ADDUID} ${USER}
	echo ${USER}:${PASSWORD} | chpasswd
	echo "yapodu create ${DATE}" >> ~yapodu/${CREATE_LOG}
fi

# ユーザーSSHディレクトリ設定
if [ -e ~yapodu/${USER_SSH_DIR} ] ; then 
	if [ -e ~yapodu/${USER_SSH_AUTHPATH} ] ; then
###		cp ~yapodu/${USER_SSH_AUTHPATH} ~yapodu/${USER_SSH_AUTHPATH}.${DATE}
###		cp ${USER_SSH_AUTHPATH} ~yapodu/${USER_SSH_AUTHPATH}
		mv ~yapodu/${USER_SSH_AUTHPATH} ~yapodu/${USER_SSH_AUTHPATH}.${DATE}
		mv ${TMP_SSH_DIR}/${USER_SSH_AUTHKEY} ~yapodu/${USER_SSH_AUTHPATH}
		echo "Change Authorized_keys ${DATE}" >> ~yapodu/${CREATE_LOG}

	else 
###		cp ./${USER_SSH_AUTHPATH} ~yapodu/${USER_SSH_AUTHPATH}
		mv ${TMP_SSH_DIR}/${USER_SSH_AUTHKEY} ~yapodu/${USER_SSH_AUTHPATH}
		echo "Copy Authorized_keys ${DATE}" >> ~yapodu/${CREATE_LOG}
	fi
else
###	cp -pr SHELL/useradd/${USER_SSH_DIR} ~yapodu/			
###	mv ${TMP_SSH_DIR} ~yapodu/${USER_SSH_DIR}
	mv ${TMP_SSH_DIR} ~yapodu/.ssh
	echo "Copy .ssh dir  ${DATE}" >> ~yapodu/${CREATE_LOG}
fi

chmod 700 ~yapodu/${USER_SSH_DIR}
chmod 600 ~yapodu/${USER_SSH_AUTHPATH}
chown ${USER}:${GROUP} ~yapodu/${USER_SSH_DIR}
chown ${USER}:${GROUP} ~yapodu/${USER_SSH_AUTHPATH}

# sshd設定変更

grep  ^AllowUsers ${SSHD_CONFIG} | grep ${USER}

if [ "$?" -eq 0 ]
then 
	echo "not change sshd_config AllowUsers ${DATE}" >> ~yapodu/${CREATE_LOG}
else
	grep ^AllowUsers ${SSHD_CONFIG} 

	if [ "$?" -eq 0 ]
	then
		sed -i.${DATE} -e "/^AllowUsers/ s/$/ ${USER}/g"  ${SSHD_CONFIG}
		echo "add sshd_config AllowUsers ${DATE}" >> ~yapodu/${CREATE_LOG}
		# sshd reload 
		service sshd reload
	else
		echo "do not use sshd_config AllowUsers ${DATE}" >> ~yapodu/${CREATE_LOG}
	fi

fi


# sudoers設定変更
# シェルスクリプト内で visudo を実行する方法もあるが /etc/sudoers の編集で実施する

grep  ${USER} ${SUDOERS}

if [ "$?" -eq 0 ]
then 
	echo "not change sudoers ${DATE}" >> ~yapodu/${CREATE_LOG}
else
	cp -p ${SUDOERS} ${SUDOERS}.${DATE}
	echo "yapodu ALL=(ALL) NOPASSWD:ALL" >> ${SUDOERS}
	echo "add yapodu ${SUDOERS} ${DATE}" >> ~yapodu/${CREATE_LOG}
fi


exit



