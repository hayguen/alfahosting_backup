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


echo "possible sftp commands: cd, ls, get, bye"
echo "trying sftp .."
SSHPASS="${SFTPPWD}" sshpass -e sftp -oBatchMode=no -o "User=${SFTPUSER}" "${SFTPHOST}"
