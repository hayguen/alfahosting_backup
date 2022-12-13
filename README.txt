
trigger.sh     - triggers start of backup on server. this takes some minutes.
check.sh       - check/list backuped files on server
get.sh         - downloads the prepared backup files from server ..
manual_ssh.sh  - prepare/test 'trigger.sh'


required package:
  $ sudo apt-get install sshpass

create and edit config file in $HOME/.config/alfahosting_backup/default.conf or site.conf :
  $ mkdir ~/.config/alfahosting_backup
  $ cp default.conf ~/.config/alfahosting_backup/
  $ chmod 600 ~/.config/alfahosting_backup/default.conf
  $ nano ~/.config/alfahosting_backup/default.conf


notification with notifyme:
copy adjust the configuration file $HOME/.config/notifyme.conf
copy notifyme.sh into the PATH, e.g. $HOME/bin
  it will be called with 2 arguments: subject and message
requires the package ssmtp:
  $ sudo apt-get install ssmtp

run 'manual_sftp.sh' once to save hostkey of server in local hosts.
  this also tests function of get_files

optionally add to crontab with
  $ crontab -e
