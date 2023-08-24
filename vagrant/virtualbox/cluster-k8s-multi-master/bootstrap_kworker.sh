#!/bin/bash

sudo su -

echo "[TASK 1] Open firewall ports"
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8285/udp                    # Flannel VXLAN Traffic
firewall-cmd --permanent --add-port=8472/udp                    # Flannel VXLAN Traffic
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload


echo "[TASK 1] Join node to Kubernetes Cluster"
dnf install -y sshpass >/dev/null 2>&1
sshpass -p "root123" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master-1:/root/joincluster-worker.sh /root/joincluster-worker.sh 2>/dev/null
bash /root/joincluster-worker.sh >/dev/null 2>&1