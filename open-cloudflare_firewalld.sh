#!/usr/bin/env bash

# Instructions:
#
# 1) Place this script in the /root/ directory, give it proper permissions.
#    $ sudo chmod +x /root/open-cloudflare.sh
#
# 2) Open the cron job editor
#    $ sudo crontab -e
#
# 3) Add the following to the last line
#    12 0 * * * root /root/open-cloudflare.sh

# Actual script:

function valid_ip() {
  local ip=$1
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    local IFS=.
    local octets=($ip)
    if [[ ${octets[0]} -le 255 && ${octets[1]} -le 255 && ${octets[2]} -le 255 && ${octets[3]} -le 255 ]]; then
      echo "Valid IP address"
      return 0
    else
      echo "Invalid IP address: Octet value out of range"
      return 1
    fi
  else
    echo "Invalid IP address: Incorrect format"
    return 1
  fi
}

# Cygnus IPv4 SSH
if [ -n "$1" ]; then
  if [ $1 = 'cygnus-ssh-ipv4' ]; then
    if [ -n "$2" ]; then
      echo "adding Cygnus IPv4 SSH"
      cygnus_ssh_ipv4="$2"

      if valid_ip "$cygnus_ssh_ipv4"; then
        sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv4" source address="'$cygnus_ssh_ipv4'" port port=22 protocol=tcp accept'
      else
        echo "Cygnus SSS ipv4 $cygnus_ssh_ipv4 is invalid"
      fi
    fi
  fi
else
  # remove all public rules first
  IFS=$'\n'
  for i in $(sudo firewall-cmd --list-rich-rules --zone=public); do
    echo "removing rule: '$i'"
    sudo firewall-cmd --permanent --zone=public --remove-rich-rule "$i"
  done

  # remove all public services
  for i in $(sudo firewall-cmd --list-services); do
    echo "removing service: '$i'"
    sudo sudo firewall-cmd --permanent --zone=public --remove-service="$i"
  done

  #echo "reloading..."
  #sudo firewall-cmd --reload
  #exit 1

  # add new rules
  # CloudFlare IPv4 HTTP
  echo "adding CloudFlare IPv4 HTTP"
  for i in $(curl "https://www.cloudflare.com/ips-v4"); do
    echo "adding IPv4 HTTP address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv4" source address="'$i'" port port=80 protocol=tcp accept'
  done

  # CloudFlare IPv4 HTTPS
  echo "adding CloudFlare IPv4 HTTPS"
  for i in $(curl "https://www.cloudflare.com/ips-v4"); do
    echo "adding IPv4 HTTPS address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv4" source address="'$i'" port port=443 protocol=tcp accept'
  done

  # CloudFlare IPv4 SSH
  echo "adding CloudFlare IPv4 SSH"
  for i in $(curl "https://www.cloudflare.com/ips-v4"); do
    echo "adding IPv4 SSH address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv4" source address="'$i'" port port=22 protocol=tcp accept'
  done

  # CloudFlare IPv6 HTTP
  echo "adding CloudFlare IPv6 HTTP"
  for i in $(curl "https://www.cloudflare.com/ips-v6"); do
    echo "adding IPv6 HTTP address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv6" source address="'$i'" port port=80 protocol=tcp accept'
  done

  # CloudFlare IPv6 HTTPS
  echo "adding CloudFlare IPv6 HTTPS"
  for i in $(curl "https://www.cloudflare.com/ips-v6"); do
    echo "adding IPv6 HTTPS address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv6" source address="'$i'" port port=443 protocol=tcp accept'
  done

  # CloudFlare IPv6 SSH
  echo "adding CloudFlare IPv6 SSH"
  for i in $(curl "https://www.cloudflare.com/ips-v6"); do
    echo "adding IPv6 SSH address: '$i'"
    sudo firewall-cmd --permanent --zone=public --add-rich-rule 'rule family="ipv6" source address="'$i'" port port=22 protocol=tcp accept'
  done

fi

echo "reloading..."
sudo firewall-cmd --reload