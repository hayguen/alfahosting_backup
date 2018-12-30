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


D="/dev/shm/$(whoami)_${SITE}_alfahosting_backup"
rm -rf "${D}"
mkdir "${D}"
pushd "${D}"

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


POST_STR="selectAll=1"
if [ "${BUP_HTML}"  -ne 0 ]; then  POST_STR="${POST_STR}&backup%5B%5D=html"  ; fi
if [ "${BUP_FILES}" -ne 0 ]; then  POST_STR="${POST_STR}&backup%5B%5D=files" ; fi
if [ "${BUP_MYSQL}" -ne 0 ]; then  POST_STR="${POST_STR}&backup%5B%5D=mysql" ; fi
POST_STR="${POST_STR}&action=backup&destination=%2Fbackup"

echo "POST STR = <${POST_STR}>"

echo ""
echo "$(date):"
echo "running wget login .. errs to errLogin.txt"
wget --save-cookies cookies.txt \
     --keep-session-cookies \
     --post-data "username=${CONFIXXUSER}&password=${CONFIXXPWD}" \
     https://${ALFAHOST}/login.php \
     2>errLogin.txt

echo "running wget post of POST_STR .. errs to err_tools_backup2.txt"
wget --load-cookies cookies.txt \
     --post-data "${POST_STR}" \
     https://${ALFAHOST}/user/${CONFIXXUSER}/tools_backup2.php \
     2>err_tools_backup2.txt

echo "running wget logout .. errs to errLogout.log"
wget --load-cookies cookies.txt \
     https://${ALFAHOST}/logout.php?user=${CONFIXXUSER} \
     2>errLogout.log

