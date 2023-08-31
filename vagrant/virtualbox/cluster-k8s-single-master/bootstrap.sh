#!/bin/bash


K8S_VERSION="1.25.0"

sudo su -

echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.56.201   kmaster-1.lv.com     kmaster-1
192.168.56.211   kworker-1.lv.com     kworker-1
192.168.56.212   kworker-2.lv.com     kworker-2
EOF


echo "[TASK 2] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a


echo "[TASK 3] Disable SELINUX"
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
setenforce 0


echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter


echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1


echo "[TASK 6] Install containerd runtime"
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install --allowerasing -y containerd 
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false$/SystemdCgroup = true/'  /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd



# Follow this linke for latest K8s releases - https://kubernetes.io/releases/
echo "[TASK 7] Install kubernetes components"
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf install -y kubelet-$K8S_VERSION kubeadm-$K8S_VERSION kubectl-$K8S_VERSION
systemctl enable kubelet


echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd


echo "[TASK 9] Set root password"
echo -e "root123\nroot123" | passwd root >/dev/null 2>&1


echo "[TASK 10] Create user"
useradd -p $(openssl passwd -1 k8s1234) k8s
echo 'k8s        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers


echo "[TASK 11] Enable auto-complete for kubectl"
dnf install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

echo "[TASK 12] Configure git"
dnf install -y git
mkdir -p ~/projects/github-lalindrait
cat >>~/.gitconfig<<EOF
[user]
        name = lalindra
        email = lalindrait@gmail.com
[alias]
        st = status
        a  = add .
        cm = commit -m
        pu = push
        co = checkout
        br = branch
        lv = log --oneline
        lvv = log --all --decorate --oneline --graph
        lvvv = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'
        lvvvv = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'
EOF