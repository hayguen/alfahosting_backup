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

if [ "${BUP_HTML}"  -ne 0 ]; then  GET_HTML="get html.tar.gz"   ; else GET_HTML=""  ; fi
if [ "${BUP_FILES}" -ne 0 ]; then  GET_FILES="get files.tar.gz" ; else GET_FILES="" ; fi
if [ "${BUP_MYSQL}" -ne 0 ]; then  GET_MYSQL="get mysql.tar.gz" ; else GET_MYSQL="" ; fi


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

echo ""
echo "$(date):"
echo "getting backup files to ${SAVEDIR}/${D} .."
cd "${SAVEDIR}/${D}"

SSHPASS="${SFTPPWD}" sshpass -e sftp -oBatchMode=no -b - -o "User=${SFTPUSER}" "${SFTPHOST}" <<EOF
  cd backup
  ls
  ${GET_HTML}
  ${GET_FILES}
  ${GET_MYSQL}
  bye
EOF

echo "listing of ${SAVEDIR}/${D} after sftp:"
ls -alh ${SAVEDIR}/${D}/

pushd "${SAVEDIR}/${D}" &>/dev/null
M="$( echo "${SITENAME} site backuped to ${SAVEDIR}/${D}:\n$(stat --printf='%11s %n\n' *)" )"
notifyme.sh "${D}:${SITENAME}_Alfahosting_Backup_SUCCESS" "$M"
popd &>/dev/null
