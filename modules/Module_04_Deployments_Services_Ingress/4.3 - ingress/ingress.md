# Deploying the nginx ingress controller
======================================

```
https://github.com/nginxinc/kubernetes-ingress

https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-manifests/


git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.3.2
kubernetes-ingress/deployments/deployment

https://github.com/kubernetes/ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

kubectl get pods -n ingress-nginx
```