
# Enable PSA for namespaces

```
kubectl get ns
kubectl create ns nonsecure
kubectl apply -f lvnginx-pod-priv.yml -n nonsecure
kubectl get pods -n nonsecure

kubectl label --dry-run=server --overwrite ns nonsecure pod-security.kubernetes.io/enforce=restricted
kubectl label --dry-run=server --overwrite ns nonsecure pod-security.kubernetes.io/enforce=baseline
kubectl label --dry-run=server --overwrite ns nonsecure pod-security.kubernetes.io/enforce=privileged
kubectl get pods -n nonsecure

kubectl label --overwrite ns nonsecure pod-security.kubernetes.io/enforce=baseline
kubectl describe ns nonsecure
kubectl delete pod lvnginx-priv -n nonsecure
kubectl apply -f lvnginx-pod-priv.yml -n nonsecure

kubectl label --overwrite ns nonsecure pod-security.kubernetes.io/enforce=privileged
kubectl get pods -n nonsecure
kubectl apply -f lvnginx-pod-priv.yml -n nonsecure
kubectl get pods -n nonsecure
kubectl delete pod lvnginx-priv -n nonsecure

kubectl label --overwrite ns nonsecure pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/warn=baseline
kubectl describe ns nonsecure
kubectl apply -f lvnginx-pod-priv.yml -n nonsecure
kubectl get pods -n nonsecure
kubectl delete pod lvnginx-priv -n nonsecure
```










