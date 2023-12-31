#!/bin/bash

K8S_VERSION="1.28.0"

sudo su - 

echo "[TASK 1] Open firewall ports"
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8285/udp                    # Flannel VXLAN Traffic
firewall-cmd --permanent --add-port=8472/udp                    # Flannel VXLAN Traffic
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload


echo "[TASK 2] Pull required containers"
kubeadm config images pull --kubernetes-version $K8S_VERSION >/dev/null 2>&1


HOSTNAME=$(hostname)
if [ "$HOSTNAME" = "master-1" ]; then
    echo "[TASK 3] Initialize Kubernetes Cluster"
    kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint 192.168.56.201:6443 --apiserver-advertise-address=192.168.56.201 --kubernetes-version $K8S_VERSION  >> /root/kubeinit.log 2>/dev/null
    kubeadm token create --print-join-command > /root/joincluster-worker.sh 2>/dev/null
    kubeadm token create --print-join-command --certificate-key $(kubeadm init phase upload-certs --upload-certs | grep -v upload-certs) > /root/joincluster-master.sh 2>/dev/null
else
    echo "[TASK 4] Join node to Kubernetes Cluster"
    dnf install -y sshpass >/dev/null 2>&1
    sshpass -p "root123" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master-1:/root/joincluster-master.sh /root/joincluster-master.sh 2>/dev/null
    bash /root/joincluster-master.sh >/dev/null 2>&1
fi

echo "[TASK 5] Deploy Flannel network"
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
sed '/        - --kube-subnet-mgr/a \ \ \ \ \ \ \ \ - --iface=eth1' kube-flannel.yml > flannel.yml
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f flannel.yml >/dev/null 2>&1


# echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
# kubeadm token create --print-join-command > /root/joincluster.sh 2>/dev/null


echo "[TASK 6] Add kube config"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config