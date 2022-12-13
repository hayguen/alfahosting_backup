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
H=$(hostname)


export PATH="${HOME}/bin:${PATH}"
DATE_FILENAME_PATTERN="+%Y-%m-%d_%a"
D=$( date ${DATE_FILENAME_PATTERN} )

SSHPASS="${SSHPWD}" sshpass -e ssh "${SSHUSER}"@${SSHHOST} \
  "ls -1lh backup/" &>/dev/shm/alfahosting_${SITE}_list.txt

echo "remote directory listing via ssh:"
cat /dev/shm/alfahosting_${SITE}_list.txt

M="$( cat /dev/shm/alfahosting_${SITE}_list.txt )"

L="/dev/shm/backup_${SITE}_${H}"
mkdir ${L} &>/dev/null
cat - >>${L}/msg  <<EOF
$(date "+%Y-%m-%d %H:%M:%S %a"): check of backup status for ${SITE} from host ${H}
${M}

EOF
