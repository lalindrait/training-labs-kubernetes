# Deployements

## Running your first deployment

```
kubectl apply -f first-deployment.yml
kubectl get all -o wide

kubectl get deploy
kubectl get deploy -o wide
kubectl get deploy lv-web-app

kubectl describe deploy lv-web-app
kubectl describe lv-web-app-56dd85556c

kubectl get rs
kubectl get rs -o wide


### Can access the website from the pod network
kubectl exec --it lv-web-app-56dd85556c-hwfst -- bash
curl http://10.244.226.72


# scale up and down replicas
kubectl scale deploy lv-web-app --replicas=3
kubectl get rs
kubectl scale deploy lv-web-app --replicas=2


## Roll out and Roll back updates


### change the deployement yaml to new image version
kubectl apply -f first-deployment.yml
kubectl get pods -l app=lv-web

kubectl rollout history deployment.apps/lv-web-app
kubectl rollout status deployment.apps/lv-web-app

kubectl rollout pause deployment.apps/lv-web-app
kubectl rollout resume deployment.apps/lv-web-app

kubectl set image deployment.apps/lv-web-app lvnginx=lalindrait/lvnginx:1.1
watch kubectl get rs -o wide
watch kubectl get rs -o wide -l app=lv-web

#annotating change-cause - 2 Ways to do annotate or edit
kubectl annotate deployment.apps/lv-web-app kubernetes.io/change-cause="version 1.1"
kubectl edit deployment.apps/lv-web-app

kubectl rollout history deployment.apps/lv-web-app


### Roll back updates
kubectl rollout undo deploy lv-web-app
kubectl rollout undo --to-revision=1 deploy lv-web-app
```


## Ausotcaling

```
Horizontal Pod Autoscaling
kubectl get hpa
kubectl describe hpa lv-web-app-6454dc9c85
kubectl get rs lv-web-app-6454dc9c85 --min=2 --max=5 --cpu-percent=80
```


## Affinity and Anti-Affinity
```
kubectl get nodes --show-labels
kubectl label nodes worker-1 pci-dss=true
```




