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