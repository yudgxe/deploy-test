#!/bin/bash

Blue='\033[0;34m'
NC='\033[0m'

START=$(date +%s)

echo -e "${Blue}Generating keys for root${NC}"

expect -c "spawn ssh-keygen -f /root/.ssh/id_rsa
           expect \"*(empty for no passphrase):\" { send \"\r\" }
           expect \"*?nter same passphrase again:\" { send \"\r\" }
           expect eof"

expect -c "spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@server-b
           expect \"*(yes/no*)?*\" { send \"yes\r\" }
           expect \"*?assword:\" { send \"123456789\r\"}
           expect eof"

echo -e "${Blue}Generating keys for devops${NC}"

mkdir -p /home/devops/.ssh
expect -c "spawn ssh-keygen -f /home/devops/.ssh/id_rsa 
           expect \"*(empty for no passphrase):\" { send \"\r\" }
           expect \"*?nter same passphrase again:\" { send \"\r\" }
           expect eof"

cat /home/devops/.ssh/id_rsa.pub | ssh root@server-b "mkdir -p /home/devops/.ssh && tee -a /home/devops/.ssh/authorized_keys"

echo -e "${Blue}Create a user and disable password authentication${NC}"

ssh root@server-b "useradd -r -d /home/devops -s /bin/bash devops && \
                   usermod -aG sudo devops && \
                   sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
                   echo \"devops ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

echo -e "${Blue}Installation and configuration postgres${NC}"

ssh -i /home/devops/.ssh/id_rsa devops@server-b "sudo apt-get install postgresql -y && \
                                                 sudo service postgresql start && \
                                                 sudo -u postgres createdb myapp && \
                                                 sudo -u postgres createdb myauth && \
                                                 sudo -u postgres psql -c \"CREATE ROLE developer WITH LOGIN PASSWORD '1234';\" && \
                                                 sudo -u postgres psql -d myauth -c \"ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO developer;\" && \
                                                 sudo -u postgres psql -d myapp -c \"ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO developer;\"
                                                 sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/g\" /etc/postgresql/12/main/postgresql.conf && \
                                                 echo "host  all developer   server-c.deploy-test_default    md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf && \
                                                 sudo service postgresql restart"

echo -e "${Blue}Checking the availability of postgres from the c-server ${NC}"

expect -c "spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@server-c
           expect \"*(yes/no*)?*\" { send \"yes\r\" }
           expect \"*?assword:\" { send \"123456789\r\"}
           expect eof"

ssh root@server-c "PGPASSWORD=1234 psql -U developer -h server-b -d myapp -c \"\conninfo\""

if [ $? = 0 ] 
then
    echo -e "${Blue}Successfully${NC}";
fi

END=$(date +%s)
DIFF=$(( $END - $START ))

echo -e "${Blue}Script runtime: ${DIFF} seconds${NC}"
