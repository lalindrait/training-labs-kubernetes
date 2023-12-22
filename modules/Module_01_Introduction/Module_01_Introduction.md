## Understading Kubernetes components


### View nodes & cluster components

```
# view nodes
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node master-1

# view pods
kubectl -n get pods -A
kubectl -n kube-system get pods
kubectl -n kube-system get pods -o wide
kubectl -n kube-system describe pod kube-apiserver-master-1
kubectl -n kube-system describe pod etcd-master-1

### view master & worker component ports
netstat -ntlp