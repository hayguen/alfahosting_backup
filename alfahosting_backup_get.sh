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

# conf needs to define environment variables: SSHHOST, SSHUSER, SSHPWD,
#  BUP_HTML, BUP_FILES, BUP_MYSQL  each 0 or 1
#  SAVEMNT, SAVEDIR
source "${HOME}/.config/alfahosting_backup/${SITE}.conf"
H=$(hostname)


export PATH="${HOME}/bin:${PATH}"
DATE_FILENAME_PATTERN="+%Y-%m-%d_%a"
D=$( date ${DATE_FILENAME_PATTERN} )

if [ ! -z "${SAVEMNT}" ]; then
  MOUNTED=$( mount |grep -c "${SAVEMNT}" )
  if [ $MOUNTED -eq 0 ]; then
    mount "${SAVEMNT}"
    MOUNTED=$( mount |grep -c "${SAVEMNT}" )
  fi
  if [ $MOUNTED -eq 0 ]; then
    notifyme.sh "${D}:${SITENAME}_Alfahosting_Backup_FAILed" "backup failed: error mounting ${SAVEMNT}"
    exit 10
  fi
fi


if [ -z "$1" ]; then
  echo "usage: $0 [<site>] [html] [files] [mysql]"
  echo "  defaulting to backup parts specified in config - without arguments"
else
  BUP_HTML=0
  BUP_FILES=0
  BUP_MYSQL=0
  while [ ! -z "$1" ]; do
    if [ "$1" == "html"  ]; then BUP_HTML=1  ; fi
    if [ "$1" == "files" ]; then BUP_FILES=1 ; fi
    if [ "$1" == "mysql" ]; then BUP_MYSQL=1 ; fi
    shift
  done
fi

# remove files older than 30 days
for d in `seq 31 38` ; do
  D=$( date -d "-${d} days" ${DATE_FILENAME_PATTERN} )
  echo "removing backup directory ${SAVEDIR}/${D}"
  if [ -d "${SAVEDIR}/${D}" ]; then
    rm -rf "${SAVEDIR}/${D}"
  fi
done

D=$( date ${DATE_FILENAME_PATTERN} )

if [ ! -d "${SAVEDIR}/${D}" ]; then
  mkdir -p "${SAVEDIR}/${D}"
fi

L="/dev/shm/backup_${SITE}_${H}"
mkdir ${L} &>/dev/null
cat - >>${L}/msg  <<EOF
$(date "+%Y-%m-%d %H:%M:%S %a"): download start of backup files for ${SITE} from host ${H}
EOF


echo ""
echo "$(date):"
echo "getting backup files to ${SAVEDIR}/${D} .."
cd "${SAVEDIR}/${D}"

if [ "${BUP_MYSQL}" -ne 0 ]; then  GET_MYSQL="mysql.tar.gz" ; else GET_MYSQL="" ; fi
if [ "${BUP_FILES}" -ne 0 ]; then  GET_FILES="files.tar.gz" ; else GET_FILES="" ; fi
if [ "${BUP_HTML}"  -ne 0 ]; then  GET_HTML="html.tar.gz"   ; else GET_HTML=""  ; fi

for f in $(echo ${GET_MYSQL} ${GET_FILES} ${GET_HTML}) ; do
  echo "get backup/${f} .."
  SSHPASS="${SSHPWD}" sshpass -e scp "${SSHUSER}"@${SSHHOST}:backup/${f} ./
done

echo "listing of ${SAVEDIR}/${D} after download via scp:"
ls -alh ${SAVEDIR}/${D}/

pushd "${SAVEDIR}/${D}" &>/dev/null

L="/dev/shm/backup_${SITE}_${H}"
mkdir ${L} &>/dev/null
cat - >>${L}/msg  <<EOF
$(date "+%Y-%m-%d %H:%M:%S %a"): download end of backup files for ${SITE} from host ${H} complete:
listing of ${SAVEDIR}/${D} :
$(ls -gGh --time-style=+)

EOF

notifyme.sh "${D} backup summary for ${SITENAME} from ${H}" "$( cat ${L}/msg )"


popd &>/dev/null
