#!/bin/bash
export LANG=en_US.UTF-8
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
bblue='\033[0;34m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}

username="yourusername"
password="yourpassword"
port=2000

[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit

if [[ -f /etc/redhat-release ]]; then
  release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
  release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
  release="Ubuntu"
else 
  red "不支持你当前系统，请选择使用Ubuntu,Debian,Centos系统。" && exit
fi

cpu=amd64

if [ ! -f xuiyg_update ]; then
  update
  packages=("curl" "openssl" "tar" "wget" "cron")
  for package in "${packages[@]}"
  do
    if ! command -v "$package" &> /dev/null; then
      if [ -x "$(command -v apt-get)" ]; then
        apt-get install -y "$package" 
      elif [ -x "$(command -v yum)" ]; then
        yum install -y "$package"
      fi
    fi
  done
fi

cd /usr/local/
curl -sSL -o /usr/local/x-ui-linux-${cpu}.tar.gz --insecure https://gitlab.com/rwkgyg/x-ui-yg/raw/main/x-ui-linux-${cpu}.tar.gz
tar zxvf x-ui-linux-${cpu}.tar.gz
rm x-ui-linux-${cpu}.tar.gz -f
cd x-ui
chmod +x x-ui bin/xray-linux-${cpu}
cp -f x-ui.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable x-ui
systemctl start x-ui

/usr/local/x-ui/x-ui setting -username ${username} -password${password} 
/usr/local/x-ui/x-ui setting -port $port
