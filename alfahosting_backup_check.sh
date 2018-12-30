#!/bin/bash

if [ -z "$1" ]; then
  SITE="default"
else
  SITE="$1"
  shift
fi

if [ ! -f "${HOME}/.config/alfahosting_backup/${SITE}.conf" ]; then
  echo "Error: config file '${HOME}/.config/alfahosting_backup/${SITE}.conf' is missing."
  exit 10
fi

source "${HOME}/.config/alfahosting_backup/${SITE}.conf"


export PATH="${HOME}/bin:${PATH}"
DATE_FILENAME_PATTERN="+%Y-%m-%d_%a"
D=$( date ${DATE_FILENAME_PATTERN} )

SSHPASS="${SFTPPWD}" sshpass -e sftp -oBatchMode=no -b - -o "User=${SFTPUSER}" "${SFTPHOST}" &>/dev/shm/alfahosting_${SITE}_status.txt <<EOF
  cd backup
  ls -lh
  bye
EOF

M="$( grep -v "^sftp>" /dev/shm/alfahosting_${SITE}_status.txt )"
notifyme.sh "${D}:${SITENAME}_Alfahosting_Backup_Check" "$M"

echo -e "sent notification mail with following content:\n$M"
