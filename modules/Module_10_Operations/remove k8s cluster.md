# Remove and clean up a k8s cluster

```
kubectl drain worker-1 --delete-emptydir-data  --force --ignore-daemonsets
kubectl drain worker-2 --delete-emptydir-data  --force --ignore-daemonsets

kubeadm reset
rm -rf ~/.kube

# remove packages using dnf
# reboot all nodes before another cluster init

```





