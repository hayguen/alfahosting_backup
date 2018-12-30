#!/bin/bash

# config file should set variables name, email and jabber
source "${HOME}/.config/notifyme.conf"

subject="$1"
msg="$2"
from="$(hostname)"

if [ -z "${subject}" ] && [ -z "${msg}" ]; then
  echo "usage: $0 <subject> <message>"
  exit 10
fi

if [ ! -z "${email}" ]; then
  # send via email
  echo -e "From: ${from} <${email}>\nTo: ${email}\nSubject: ${subject}\n\n${msg}\n" \
    | /usr/sbin/ssmtp "${email}"
fi

if [ ! -z "${jabber}" ]; then
  # send via jabber/xmpp
  echo -e "from: ${from}\nsubject: ${subject}\n\n${msg}" \
    | /usr/bin/sendxmpp -a /etc/ssl/certs/ -t -s "${subject}" "${jabber}"
fi

