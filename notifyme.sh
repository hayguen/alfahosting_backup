#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: $0 [To <CC>] <subject> <msg>"
  exit 0
fi

# config file should set variables name, email and jabber
source "${HOME}/.config/notifyme.conf"

if [ "$1" = "To" ]; then
  mto="$2"
  shift
  shift
else
  mto=""
fi

subject="$1"
msg="$2"
from="$(hostname)"

if [ -z "${subject}" ] && [ -z "${msg}" ]; then
  echo "usage: $0 <subject> <message>"
  exit 10
fi

if [ ! -z "${email}" ]; then
  # send via email
  if [ -z "$mto" ]; then
    mhdr="From: ${from} <${email}>\nTo: ${email}\nSubject: ${subject}"
  else
    mhdr="From: ${from} <${email}>\nTo: ${email}, ${mto}\nSubject: ${subject}"
  fi
  echo -e "${mhdr}\n\n${msg}\n" \
      | /usr/sbin/ssmtp "${email}" "${mto}"
fi

if [ ! -z "${jabber}" ]; then
  # send via jabber/xmpp
  echo -e "from: ${from}\nsubject: ${subject}\n\n${msg}" \
    | /usr/bin/sendxmpp -a /etc/ssl/certs/ -t -s "${subject}" "${jabber}"
fi

