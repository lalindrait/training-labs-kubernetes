# Creting network policies

## Usefull commands

```
kubectl get nodes --show-labels
kubectl label nodes worker-1 nodename=worker-1
kubectl label nodes worker-2 nodename=worker-2
kubectl get nodes --show-labels

kubectl run mybusybox1 -it --image busybox -- sh
kubectl run mybusybox1 -it --rm --image busybox -- sh
```

## Checking network connectivity between 2 pods
```
kubectl apply -f lvnginx-pod1.yml
kubectl apply -f lvnginx-pod2.yml
kubectl get pods -o wide

kubectl exec -it  lvnginx1 -- bash
kubectl exec -it  lvnginx2 -- bash

#From inside the pod verify connectivity 
ip a
ping 10.244.2.36
curl http://10.244.2.36
```

## Create a network policy

```
kubectl apply -f ngninx-network-policy.yml
kubectl get networkpolicies
kubectl describe networkpolicies nginx-block

# Check the access to lvnginx2 http is not restricted
curl http://10.244.133.195

kubectl delete networkpolicies nginx-block
```







