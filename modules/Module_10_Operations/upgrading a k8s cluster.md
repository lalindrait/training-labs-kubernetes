
# Upgrading a Kubernetes Cluster

## Check k8s component versions

```
# versions of k8s images
kubeadm config images list

# kubectl versions
kubectl version
kubectl version -o yaml
# client version: version of the kubectl client installed on your local
# server version: version of the Kubernetes cluster itself that you are connected to

# kubelet versions - VERSION column
kubectl get nodes
# node specific compoenent versions
kubectl get nodes -o yaml

# rpm versions
dnf list installed | grep -i kube

# kubeadm version
kubeadm version
kubeadm version -o yaml

# check kubeadm configs
kubectl -n kube-system get cm kubeadm-config -o yaml
```


## Upgrading the cluster

***Note : Always backup the cluster before an upgrade***

### Step 1 - Upgrade the master node

**Steps to follow**
1. Upgrade kubeadm on the Control Plane node
2. Drain the Control Plane node
3. Plan the upgrade - kubeadm upgrade plan
4. Apply the upgrade - kubeadm upgrade apply
5. Upgrade kubelet & kubectl on the control Plane node
6. Uncordon the Control Plane node

```
# View the upgrade plan
kubeadm upgrade plan

# Upgrade kubeadm on the Control Plane node
dnf upgrade -y kubeadm-1.25.11
kubeadm version
kubeadm version -o yaml
dnf list installed | grep  kubeadm
dnf info kubeadm

# Drain the Control Plane node
kubectl get nodes
kubectl drain kmaster-1 --ignore-daemonsets --delete-emptydir-data
kubectl get nodes
kubectl get pods -A -o wide  			            # coredns will be moved to worker nodes

# Upgrade kubelet & kubectl on the control Plane node
kubeadm upgrade plan v1.28.5
kubeadm upgrade apply v1.28.5

kubectl get nodes
kubectl get pods -A -o wide  			

# Upgrade kubelet & kubectl on the control Plane node
kubectl version -o yaml
dnf upgrade -y kubelet-1.25.11  kubectl-1.25.11
systemctl daemon-reload
systemctl restart kubelet

# Uncordon the Control Plane node 
kubectl uncordon kmaster-1
kubectl get nodes

# If you want to verify the cluster operaitons
kubectl run mybusybox -it --image busybox -- sh
```


### Step 2 - Upgrade the worker node

**Steps to follow**
1. Drain the node
2. Upgrade kubeadm on the node
3. Upgrade the kubelet configuration
4. Upgrade kubelet & kubectl
5. Uncordon the node



kubectl apply -f nginx-deployment.yml
kubectl get pods -o wide

kubectl get nodes
kubectl get pods -o wide

```
# Drain the node - From master node
kubectl drain kworker-1 --ignore-daemonsets

# Upgrade kubeadm on the node
dnf upgrade -y kubeadm-1.25.11

# Upgrade the kubelet configuration
kubeadm upgrade node
dnf upgrade -y kubelet-1.25.11  kubectl-1.25.11

systemctl daemon-reload
systemctl restart kubelet

# Uncordon the node - From master node
kubectl uncordon kworker-1
```


## Kubernetes Cluster - Backup & Restore

### Kubernetes Configuration Backup
```
# get a full configuration backup of a cluster
kubectl get all --all-namespaces -o yaml > k8s-resource-config-bkp.yaml
```
### etcd database backup
You have to do this as root as only root has access to key files

**Steps to follow**
1. Take a backup of the etcd database
2. Take a full backup of the etcd k8s directory - /etc/kubernetes/pki/etcd


**Install the etcdctl CLI**
```
wget https://github.com/etcd-io/etcd/releases/download/v3.5.10/etcd-v3.5.10-linux-amd64.tar.gz
tar -zxf etcd-v3.5.10-linux-amd64.tar.gz
cd etcd-v3.5.10-linux-amd64/
mv etcd* /usr/local/bin/
chmod +x /usr/local/bin/etcd*
etcdctl version
```

**Connecting to etcd database**
```
vi .bash_profile
source .bash_profile

export ETCDCTL_API=3 
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

etcdctl member list
etcdctl endpoint status
etcdctl endpoint health
```

**Take the snapshop**
```
etcdctl snapshot save snapshot-16062023.db
etcdctl --write-out=table snapshot status snapshot-16062023.db
```

**Backup the etcd k8s directory**
```
tar -zcvf etcd.tar.gz /etc/kubernetes/pki/etcd
```

**Restore the etcd database**
```
# restore the database from the snapshot
ETCDCTL_API=3 etcdctl --data-dir="/var/lib/etcd-backup" \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot restore etcd-backup.db

# change the etcd cluster manifest to directo to the new data dir
# change the following to the new resotred dir
vi /etc/kubernetes/manifests/etcd.yaml
  - hostPath:
      path: /var/lib/etcd                   # change this to "/var/lib/etcd-backup"
      type: DirectoryOrCreate
    name: etcd-data
```
