#!/bin/bash
# check apache,mysql, proftpd thread and auto reboot system

ip_address=`ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
hostanme=`hostname`
mail_doxer()
{
  mail -s "Message de la VM $hostname ($ip_address)" ianbogda@gmail.com</tmp/result.txt
}

check_status()
{
    local  __service=$1
    if [[ "$__service" ]]; then
        echo `ps -u$__service -Lf | wc -l`
    fi
}

# apache
ApacheThread=`check_status apache` 

# mysql
MysqldThread=`check_status mysql`

# proftpd
ProftpThread=`check_status proftpd`

echo ''>/tmp/result.txt
sendMail=0

if [ "$ApacheThread" -eq "0" ]; then
  echo "Le serveur apache était arrêté, il a été redémarré le $(date +"%y-%m-%d") à $(date +"%H:%M:%S")\n">>/tmp/result.txt
  $sendMail=1
  /etc/init.d/apache2 start
fi

if [ "$MysqldThread" -eq "0" ]; then
  echo "Le serveur MySQL était arrêté, il a été redémarré le $(date +"%y-%m-%d") à $(date +"%H:%M:%S")\n">>/tmp/result.txt
  $sendMail=1
  /etc/init.d/mysql start
fi

if [ "$ProftpThread" -eq "0" ]; then
  echo "Le serveur ProFTPd était arrêté, il a été redémarré le $(date +"%y-%m-%d") à $(date +"%H:%M:%S")\n">>/tmp/result.txt
  $sendMail=1
  /etc/init.d/proftpd start
fi

# En cas de surnombre de process, on redémarre la VM
MaxApacheThread=30
MaxMysqlThread=250
MaxProftpdThread=30

NeedReboot=0

if [ $ApacheThread -gt $MaxApacheThread ]
then
  NeedReboot=1
fi

if [ $MysqldThread -gt $MaxMysqlThread ]
then
  NeedReboot=1
fi

if [ $ProftpThread -gt $MaxProftpdThread ]
then
  NeedReboot=1
fi

if [ $NeedReboot -eq 1 ]
then
  date_reboot=$(date +"%y-%m-%d %H:%M:%S")
  echo "La VM est en surcharge, voici le nombre de process par service,\nApache : $ApacheThread/$MaxApacheThread;\nMySQL : $MysqldThread/$MaxMysqlThread;\nProFTPd : $ProftpThread/$MaxProftpdThread.\nConclusion, je redémarre la VM le $date_reboot">>/tmp/result.txt
  $sendMail=1
  reboot
fi

if [ $sendMail -eq 1 ]; then
  mail_doxer
fi
