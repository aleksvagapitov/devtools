#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

# Add user and add to group wheel
useradd -m user -s /bin/bash
echo root:root | chpasswd
echo user:user | chpasswd
usermod -aG sudo user

# Copy ssh keys to user
cd /home/user && mkdir .ssh && touch .ssh/authorized_keys && cat ~/.ssh/authorized_keys > .ssh/authorized_keys
cd /home/user && chmod 700 .ssh && chown user:user .ssh && chmod 600 .ssh/authorized_keys && chown user:user .ssh/authorized_keys

#To directly modify sshd_config.
sed -i '$ a AllowUsers user' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(PubkeyAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitEmptyPasswords\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config

# Fix Ubuntu 22.04 Unattended Installation 
echo "\$nrconf{restart} = 'a';" | tee /etc/needrestart/conf.d/50local.conf

while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 5; done;
apt-get update
apt-get install -y mosh

#Check the exit status of the last command
systemctl restart sshd

exit 0
