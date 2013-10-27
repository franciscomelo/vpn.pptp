#!/bin/bash -x
#
# OwnCloud.pt / VPN (PPTP) CentOS
#
#
# @version VPN 1.0

(

VPN_IP=`curl ipv4.icanhazip.com`

VPN_USERNAME="vpn.user"
VPN_PASSWORD="vpn.pass"

VPN_LOCAL="192.168.0.150"
VPN_REMOTE="192.168.0.151-200"

yum -y groupinstall "Development Tools"
rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
yum -y install policycoreutils policycoreutils
yum -y install ppp pptpd
yum -y update

echo "1" > /proc/sys/net/ipv4/ip_forward
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network

echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd # Google DNS Primary
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd # Google DNS Secondary


echo "$VPN_USERNAME pptpd $VPN_PASSWORD *" >> /etc/ppp/chap-secrets

service iptables start
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
service iptables restart

service pptpd restart
chkconfig pptpd on

echo -e '\E[37;44m'"\033[1m Installation Log: /var/log/vpn-installer.log \033[0m"
echo -e '\E[37;44m'"\033[1m You can now connect to your VPN via your external IP ($VPN_IP)\033[0m"

echo -e '\E[37;44m'"\033[1m Username: $VPN_USERNAME\033[0m"
echo -e '\E[37;44m'"\033[1m Password: $VPN_PASSWORD\033[0m"

) 2>&1 | tee /var/log/vpn-installer.log
