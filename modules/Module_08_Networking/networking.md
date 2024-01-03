5.1 - Networking
---------------------------------


basic networking commands


ip addr
ip link
route -n
cat /proc/sys/net/ipv4/ip_forward
nslookup
dig




Network Understand Stack - Demo
===============================


kubectl get nodes --show-labels
kubectl label nodes master-1 nodename=master-1
kubectl label nodes worker-1 nodename=worker-1
kubectl label nodes worker-2 nodename=worker-2




Installing Calico - Using Manifest
===================================
https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises

# Go to Install Calico and then "Manifest" tab

curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/calico.yaml -O

# change the CALICO_IPV4POOL_CIDR to reflect the pod network CIDR

 - name: CALICO_IPV4POOL_CIDR
              value: "10.244.0.0/16"

# change the cpu request if necessary for containers from the default value

           requests:
              cpu: 100m
              #cpu: 250m





Installing Calico
=================
https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart


# open ports on all nodes 
firewall-cmd --permanent --add-port=179/tcp
firewall-cmd --reload
firewall-cmd --list-ports


wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
kubectl create -f tigera-operator.yaml

wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/custom-resources.yaml
### Change the ipPools: --> cidr to the pod network range
kubectl apply -f custom-resources.yaml

kubectl get pods -n calico-system



https://docs.tigera.io/archive/v3.8/reference/node/configuration#ip-setting


nc -v 192.168.1.231 31000






















Network check
======================

kubectl run mybusybox1 -it --image busybox -- sh
kubectl run mybusybox1 -it --rm --image busybox -- sh
kubectl run mybusybox2 -it --rm --image busybox -- sh
kubectl run mybusybox3 -it --rm --image busybox -- sh



ip netns
dnf install bridge-utils
brctl show


brctl showmacs cni0

p link show type veth
ip link show type bridge
bridge link show


cat /proc/sys/net/ipv4/icmp_echo_ignore_all


iptables --policy FORWARD ACCEPT



netstat -nr
route add -net 10.244.2.0 netmask 255.255.255.0 eth1
route add -net 10.244.2.0 netmask 255.255.255.0 gw 10.244.2.0

route del -net 10.244.1.0 netmask 255.255.255.0 gw 10.244.1.0
route del -net 10.244.1.0 netmask 255.255.255.0 eth1





kubectl logs -n kube-flannel kube-flannel-ds-6ftct



Calico
===========================


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



kubectl delete -f calico.yaml
kubectl get pods -A


kubectl delete pod -n kube-system --grace-period=0 --force calico-kube-controllers-786b679988-2gzvl



ps -ef | grep "cluster-cidr"



kubectl logs -n kube-system calico-node-7f5hw

https://docs.tigera.io/calico/latest/networking/ipam/ip-autodetection#change-the-autodetection-method





Weave Net
=================================================

curl "http://127.0.0.1:6784/status"





Flannel issue on Virtual Box having 2 interface - Nat interface
===============================================================

https://devpress.csdn.net/k8s/62fd6149c67703293080371c.html


### above did not work but following works
https://serverfault.com/questions/1043827/kubernetes-pod-to-pod-communication-cross-nodes


https://errindam.medium.com/taming-kubernetes-for-fun-and-profit-60a1d7b353de


kubectl logs -n kube-flannel  kube-flannel-ds-2lpsq | grep interface

systemctl stop kubelet; systemctl restart containerd; systemctl start kubelet



cat /run/flannel/subnet.env
cat /etc/cni/net.d/10-flannel.conflist





Solution - Add host firewall UDP rules for VXLAN traffic
--------------------------------------------------------
# Master
firewall-cmd --permanent --add-port=6443/tcp # Kubernetes API server
firewall-cmd --permanent --add-port=2379-2380/tcp # etcd server client API
firewall-cmd --permanent --add-port=10250/tcp # Kubelet API
firewall-cmd --permanent --add-port=10251/tcp # kube-scheduler
firewall-cmd --permanent --add-port=10252/tcp # kube-controller-manager
firewall-cmd --permanent --add-port=8285/udp # Flannel
firewall-cmd --permanent --add-port=8472/udp # Flannel
firewall-cmd --add-masquerade --permanent
# only if you want NodePorts exposed on control plane IP as well
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload
systemctl restart firewalld


# Node
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=8285/udp # Flannel
firewall-cmd --permanent --add-port=8472/udp # Flannel
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload
systemctl restart firewalld




Flanell network issue - Solution - Not the right one should add udsp firewall rule sinstead
===========================================================================================

On worker worker-1
----------------
route add -net 10.244.2.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.2.0 netmask 255.255.255.0 gw 10.244.2.0

route add -net 10.244.0.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.0.0 netmask 255.255.255.0 gw 10.244.0.0

On worker worker-2
----------------
route add -net 10.244.1.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.1.0 netmask 255.255.255.0 gw 10.244.1.0

route add -net 10.244.0.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.0.0 netmask 255.255.255.0 gw 10.244.0.0

On worker master-1
----------------

route add -net 10.244.1.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.1.0 netmask 255.255.255.0 gw 10.244.1.0

route add -net 10.244.2.0 netmask 255.255.255.0 enp0s3
route add -net 10.244.2.0 netmask 255.255.255.0 gw 10.244.2.0


route table before and after - worker-1
----------------------------------------

[root@kworker-1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 flannel.1
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-1 ~]#
[root@kworker-1 ~]#
[root@kworker-1 ~]#
[root@kworker-1 ~]# route add -net 10.244.2.0 netmask 255.255.255.0 enp0s3
[root@kworker-1 ~]# route add -net 10.244.2.0 netmask 255.255.255.0 gw 10.244.2.0
[root@kworker-1 ~]#
[root@kworker-1 ~]#
[root@kworker-1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 flannel.1
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-1 ~]#
[root@kworker-1 ~]# route add -net 10.244.0.0 netmask 255.255.255.0 enp0s3
[root@kworker-1 ~]# route add -net 10.244.0.0 netmask 255.255.255.0 gw 10.244.0.0
[root@kworker-1 ~]#
[root@kworker-1 ~]#
[root@kworker-1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.0.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 flannel.1
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-1 ~]#




route table before and after - worker-2
---------------------------------------

[root@kworker-2 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-2 ~]#
[root@kworker-2 ~]#
[root@kworker-2 ~]#
[root@kworker-2 ~]# route add -net 10.244.1.0 netmask 255.255.255.0 enp0s3
[root@kworker-2 ~]# route add -net 10.244.1.0 netmask 255.255.255.0 gw 10.244.1.0
[root@kworker-2 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-2 ~]#
[root@kworker-2 ~]# route add -net 10.244.0.0 netmask 255.255.255.0 enp0s3
[root@kworker-2 ~]# route add -net 10.244.0.0 netmask 255.255.255.0 gw 10.244.0.0
[root@kworker-2 ~]#
[root@kworker-2 ~]#
[root@kworker-2 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.0.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.0.0      10.244.0.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kworker-2 ~]#
[root@kworker-2 ~]#


route table before and after - master-1
---------------------------------------

[root@kmaster-1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 flannel.1
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kmaster-1 ~]#
[root@kmaster-1 ~]#
[root@kmaster-1 ~]# route add -net 10.244.2.0 netmask 255.255.255.0 enp0s3
[root@kmaster-1 ~]# route add -net 10.244.2.0 netmask 255.255.255.0 gw 10.244.2.0
[root@kmaster-1 ~]#
[root@kmaster-1 ~]# route add -net 10.244.1.0 netmask 255.255.255.0 enp0s3
[root@kmaster-1 ~]# route add -net 10.244.1.0 netmask 255.255.255.0 gw 10.244.1.0
[root@kmaster-1 ~]#
[root@kmaster-1 ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG        0 0          0 enp0s3
10.244.0.0      0.0.0.0         255.255.255.0   U         0 0          0 cni0
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.1.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.1.0      10.244.1.0      255.255.255.0   UG        0 0          0 flannel.1
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 enp0s3
10.244.2.0      0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
10.244.2.0      10.244.2.0      255.255.255.0   UG        0 0          0 flannel.1
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 enp0s3
[root@kmaster-1 ~]#











