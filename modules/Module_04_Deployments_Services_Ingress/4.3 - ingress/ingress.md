# Deploying the nginx ingress controller
======================================

## nginx ingress contoller repos
```
OSS ingress-nginx repo
https://github.com/kubernetes/ingress-nginx/tree/main
https://github.com/kubernetes/ingress-nginx/tree/main/deploy/static/provider
https://github.com/kubernetes/ingress-nginx/blob/main/deploy/static/provider/baremetal/deploy.yaml


#Official nginx company repo
For nginx ingress controller & nginx plus ingress controller
https://github.com/nginxinc/kubernetes-ingress#
```


## Installing ingress controller
Official OSS GitHub repo - https://github.com/kubernetes/ingress-nginx/tree/main

```
wget https://github.com/kubernetes/ingress-nginx/blob/main/deploy/static/provider/baremetal/deploy.yaml
dos2unix deploy.yaml
kubectl apply -f deploy.yaml

# verify the installation
kubectl get ns
kubectl -n ingress-nginx get pods -o wide
kubectl -n ingress-nginx get svc
```


## Configure ingress objects
```
# create pods, services and ingress object
kubectl apply -f test-ingress.yaml
kubectl apply -f fruit-ingress.yaml

# check connectivity
# since ingress controller is nodeport type must use nodeports to test connectivity
curl http://192.168.1.241:31376/banana
```


## Configure Haproxy
```
vi /etc/haproxy/haproxy.cfg
frontend k8s-ingress
    bind 192.168.1.101:80
    default_backend ingress-nodeports

backend ingress-nodeports
    server nginx1 192.168.1.241:31376
    server nginx1 192.168.1.242:31376

systemctl restart haproxy

curl http://192.168.1.101/banana
```



## Sample outputs
```
[lalindra@master-1 nginx-ingress]$ kubectl apply -f deploy.yaml
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
serviceaccount/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
configmap/ingress-nginx-controller created
service/ingress-nginx-controller created
service/ingress-nginx-controller-admission created
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
[lalindra@master-1 nginx-ingress]$
[lalindra@master-1 nginx-ingress]$ kubectl -ningress-nginx get pods -o wide
NAME                                        READY   STATUS      RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-qg68t        0/1     Completed   0          87s   10.244.1.123   worker-1   <none>           <none>
ingress-nginx-admission-patch-2kn7w         0/1     Completed   0          87s   10.244.1.124   worker-1   <none>           <none>
ingress-nginx-controller-55754d7d8b-zqpbl   1/1     Running     0          87s   10.244.1.125   worker-1   <none>           <none>
[lalindra@master-1 nginx-ingress]$
[lalindra@master-1 nginx-ingress]$ kubectl -n ingress-nginx get svc
NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.105.169.224   <none>        80:31376/TCP,443:32328/TCP   4m46s
ingress-nginx-controller-admission   ClusterIP   10.104.45.90     <none>        443/TCP                      4m46s
[lalindra@master-1 nginx-ingress]$
[lalindra@master-1 nginx-ingress]$ kubectl get svc -A
NAMESPACE       NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
cert-manager    cert-manager                         ClusterIP   10.107.236.116   <none>        9402/TCP                     67d
cert-manager    cert-manager-webhook                 ClusterIP   10.104.195.161   <none>        443/TCP                      67d
cka             svc-3                                NodePort    10.111.158.153   <none>        80:32759/TCP                 22h
default         apple-service                        ClusterIP   10.102.55.230    <none>        5678/TCP                     38m
default         banana-service                       ClusterIP   10.100.27.159    <none>        5678/TCP                     38m
default         kubernetes                           ClusterIP   10.96.0.1        <none>        443/TCP                      67d
ingress-nginx   ingress-nginx-controller             NodePort    10.105.169.224   <none>        80:31376/TCP,443:32328/TCP   4h37m
ingress-nginx   ingress-nginx-controller-admission   ClusterIP   10.104.45.90     <none>        443/TCP                      4h37m
kube-system     kube-dns                             ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       67d
kube-system     metrics-server                       ClusterIP   10.99.163.194    <none>        443/TCP                      63d
[lalindra@master-1 nginx-ingress]$
[lalindra@master-1 4.3 - ingress]$ kubectl get svc,ep
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/apple-service    ClusterIP   10.102.55.230   <none>        5678/TCP   61m
service/banana-service   ClusterIP   10.100.27.159   <none>        5678/TCP   61m
service/kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP    68d

NAME                                                      ENDPOINTS            AGE
endpoints/apple-service                                   10.244.1.131:5678    61m
endpoints/banana-service                                  10.244.1.132:5678    61m
endpoints/cluster.local-nfs-subdir-external-provisioner   <none>               67d
endpoints/kubernetes                                      192.168.1.231:6443   68d
[lalindra@master-1 4.3 - ingress]$
[lalindra@master-1 4.3 - ingress]$ kubectl describe ingress fruit-ingress
Name:             fruit-ingress
Labels:           <none>
Namespace:        default
Address:          192.168.1.241
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /apple    apple-service:5678 (10.244.1.131:5678)
              /banana   banana-service:5678 (10.244.1.132:5678)
Annotations:  <none>
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    47m (x2 over 48m)  nginx-ingress-controller  Scheduled for sync
[lalindra@master-1 4.3 - ingress]$


```