# Networking


## useful host networking commands
```
ip addr
ip link
route -n
cat /proc/sys/net/ipv4/ip_forward
nslookup
dig
```


## undestading Kubernetes Networking
```
# to view node level ports
netstat -ntlp

# to view node network settings
ip addr
netstat -nr
ip netns

dnf install bridge-utils -y
brctl show
brctl showmacs cni0

# easiest way to start a pod for testing
kubectl run mybusybox1 -it --image busybox -- sh

# --rm will delete the pod when exit from the shell
kubectl run mybusybox1 -it --rm --image busybox -- sh
kubectl run mybusybox2 -it --rm --image busybox -- sh
kubectl run mybusybox3 -it --rm --image busybox -- sh

ip link show type veth
ip link show type bridge
bridge link show

cat /proc/sys/net/ipv4/icmp_echo_ignore_all
iptables --policy FORWARD ACCEPT
```

## Undestand kube-proxy
```
curl -v localhost:10249/proxyMode

kubectl get svc -A
kubectl get ep -A
kubectl describe ep kube-dns -n kube-system

kubectl apply -f deployment.yml
kubectl apply -f service.yml

kubectl get svc
kubectl get ep

# port will not be visible in netstat output but connecting to the port will work
netstat -ntlp
nc -v 192.168.1.231 30001

iptables -t nat -L PREROUTING
iptables -t nat -L KUBE-SERVICES
iptables -t nat -L KUBE-SVC-OZP6WJPMWJS2CJ2N
iptables -t nat -L KUBE-SEP-CRK6GJGX4WQL55H6

# service discovery
kubectl exec -it lv-web-app-99fb57875-7mwnm -- bash
cat /etc/resolv.conf
nslookup lv-nginx-svc
nslookup lv-nginx-svc.default.svc.cluster.local

# to view for IPVS rules
ipvsadm -Ln
```

## Installing Flannel

```
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

#If you node has multiple interface and you want to pin flannel to a specific interface use the following 
# After the line  - --kube-subnet-mgr add the following line 
vi kube-flannel.yml
- --iface=eth1 

kubectl apply -f kube-flannel.yml
```




## Installing Calico - Using Manifest

```
# Calico Documentation - https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises

# Go to Install Calico and then "Manifest" tab
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/calico.yaml -O

# change the CALICO_IPV4POOL_CIDR to reflect the pod network CIDR
 - name: CALICO_IPV4POOL_CIDR
              value: "10.244.0.0/16"

# change the cpu request if necessary for containers from the default value
           requests:
              cpu: 100m
              #cpu: 250m


kubectl delete -f calico.yaml
kubectl get pods -A

kubectl delete pod -n kube-system --grace-period=0 --force calico-kube-controllers-786b679988-2gzvl

ps -ef | grep "cluster-cidr"
kubectl logs -n kube-system calico-node-7f5hw

https://docs.tigera.io/calico/latest/networking/ipam/ip-autodetection#change-the-autodetection-method
```

## Installing Calico - Using Operator
```
# Calico Documentation - https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart

# open ports on all nodes 
firewall-cmd --permanent --add-port=179/tcp
firewall-cmd --reload
firewall-cmd --list-ports

wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
kubectl create -f tigera-operator.yaml

wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/custom-resources.yaml
### Change the ipPools: --> cidr to the pod network range
kubectl apply -f custom-resources.yaml

# to change default IP setting use the following documentation
# https://docs.tigera.io/archive/v3.8/reference/node/configuration#ip-setting

kubectl get pods -n calico-system
```

## Calico CLI
```
https://github.com/projectcalico/calicoctl/releases


wget https://github.com/projectcalico/calicoctl/releases/download/v3.20.6/calicoctl-linux-amd
mv calicoctl-linux-amd64 calicoctl
chmod +x calicoctl
mv calicoctl /usr/bin/
calicoctl version

calicoctl get nodes --allow-version-mismatch
calicoctl --allow-version-mismatch get node -o wide
calicoctl get ippools --allow-version-mismatch
calicoctl --allow-version-mismatch node status



```
