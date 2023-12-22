
# Kubernetes Cluster - Backup & Restore

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
