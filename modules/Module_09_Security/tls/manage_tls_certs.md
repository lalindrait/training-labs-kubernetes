# Managing TLS Certificates

kubectl api-resources --sort-by name -o wide


## View Certificate Details

```
#To view *.conf certs and keys
cd /etc/kubernetes/
ls -l
cat controller-manager.conf


#To view CA, API Server, ETCD certs and keys
cd /etc/kubernetes/pki
ls -l 
openssl x509 -in apiserver.crt -text -noout

kubeadm certs check-expiration

```



## Acessing k8s API thorugh curl

```
cat /etc/kubernetes/admin.conf
# put the data fileds in to a seperate fileds

cat encoded-admin.crt | base64 --decode > admin.crt
cat encoded-admin.key | base64 --decode > admin.key
cat encoded-ca.crt | base64 --decode > ca.crt

kubectl cluster-info 
curl https://192.168.1.231:6443/api/v1/pods --key admin.key --cert admin.crt --cacert ca.crt

```


## Renew Certificates

```
#Execute following as root
kubeadm certs check-expiration
kubeadm certs --help
kubeadm certs renew --help

kubeadm certs renew apiserver
echo | openssl s_client -showcerts -connect 192.168.1.231:6443 -servername api 2>/dev/null | openssl x509 -noout -enddate

kubeadm certs renew all
```


## Restart the pods
```
ps -ef | grep containerd

### Set crictl endpoints
cat /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock

### Restart a pod 
crictl ps
crictl ps -a 

crictl stopp 2d3e562fb0ecb; crictl rmp 2d3e562fb0ecb
crictl ps

# To remove a pod you can move the manifes in /etc and move it back it will restart

```



### Create a new user certificate 
================================
kubectl get csr
kubectl config view


# For generating certificates using different tools refer to the k8s documentation 
https://kubernetes.io/docs/tasks/administer-cluster/certificates/
