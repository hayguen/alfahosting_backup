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

# conf needs to define environment variables: SSHHOST, SSHUSER, SSHPWD
source "${HOME}/.config/alfahosting_backup/${SITE}.conf"


echo "possible ssh commands: cd, ls, exit"
echo "going to try ssh over sshpass .."
echo "in case nothing happens, try following command with configured password '${SSHPWD}'"
echo "  ssh "${SSHUSER}"@${SSHHOST}"
echo "now trying .."
SSHPASS="${SSHPWD}" sshpass -e ssh "${SSHUSER}"@${SSHHOST}
