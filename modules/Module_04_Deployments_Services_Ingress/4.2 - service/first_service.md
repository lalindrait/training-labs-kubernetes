## Running your first service

```
kubectl apply -f first-service.yml
kubectl get svc

kubectl get all -o wide
kubectl describe service/lv-nginx-svc
kubectl describe service lv-nginx-svc

kubectl delete service lv-nginx-svc

kubectl get endpointslices
kubectl describe endpointslice lv-nginx-svc-j55qx

nc 192.168.1.242 30001

firewall-cmd --permanent --add-port=30001/tcp
firewall-cmd --reload
firewall-cmd --list-ports

curl http://192.168.56.211:30001
curl http://192.168.56.212:30001
curl http://192.168.56.213:30001
```



