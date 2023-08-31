#!/bin/bash


echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd


echo "[TASK 9] Set root password"
echo -e "root123\nroot123" | passwd root >/dev/null 2>&1


echo "[TASK 10] Create user"
useradd -p $(openssl passwd -1 k8s1234) k8s
echo 'k8s        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers