apt-get install iptables -y

iptables -A INPUT -p tcp --dport ssh --source server-a.deploy-test_default -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -j DROP