# Accesing cluster as a custom user


## create new OS user and csr - requesting user

```
useradd mit
passwd mit 

openssl genrsa -out mit.key 2048
openssl req -new -key mit.key -out mit.csr -subj "/CN=mit/O=mitesp"
openssl req -in mit.csr -text -noout
# To get the encoded request
cat mit.csr | base64 | tr -d '\n'

# copy the encoded request to tmp - Equqls sending it to k8s admin
cat mit.csr | base64 | tr -d '\n' > mit-user-request.txt
cp mit-user-request.txt /tmp/


## Create certs - k8s admin
### Create the CertificateSigningRequest yaml
### must be adone as k8s admin account

cp /tmp/mit-user-request.txt .

kubectl apply -f mit-csr-request.yml
kubectl get csr
kubectl certificate approve user-request-mit
kubectl get csr

kubectl get csr user-request-mit -o jsonpath='{.status.certificate}' | base64 -d > mit-user.crt
openssl x509 -in mit-user.crt -text -noout

cp mit-user.crt /tmp/
```


## Create kubeconfig file - requesting user

```
cp /tmp/mit-user.crt .

kubectl config set-cluster kubernetes --insecure-skip-tls-verify=true --server=https://192.168.1.231:6443
kubectl config set-credentials mit --client-certificate=mit.crt --client-key=mit.key --embed-certs=true
kubectl config set-context default --cluster=kubernetes --user=mit
kubectl config use-context default

cat .kube/config
```


## Create ClusterRole & ClusterRoleBinding - k8s admin

```
# To get the shortname for api resources
kubectl api-resources | grep -i role

kubectl apply -f developer-clusterrole.yml
kubectl apply -f developer-rolebinding.yml

kubectl get ClusterRole | grep dev
kubectl get ClusterRoleBinding | grep dev
```


## Test access- requesting user

```
kubectl get pods
kubectl get pods -A
kubectl get ns
```



## Additional Commands

```
kubectl config view
```
