## Filtering Sorting outputs
```
kubectl get pods --field-selector status.phase=Running
kubectl get pods --field-selector spec.nodeName=worker-1 -o wide
kubectl get pods --field-selector metadata.name=kube-flannel-ds-pjqkc
kubectl get pods --field-selector=status.phase=Running,spec.restartPolicy=Always

kubectl get pods --show-labels
kubectl get pods -l app=nfs

kubectl get pods -o yaml
kubectl get pods -o json

kubectl get pods --sort-by=.metadata.name
kubectl get pods --sort-by=.spec.nodeName -o wide
kubectl get pods --sort-by=.status.containerStatuses[0].restartCount

kubectl get pods -o json        # get the path to the column in json
kubectl get pods -o custom-columns=NAME:.metadata.name,QoS_CLASS:.status.qosClass
kubectl get pods -o custom-columns=NAME:.metadata.name,DNS_Policy:.spec.dnsPolicy
kubectl get pods -o custom-columns=NAME:.metadata.name,Restart_Policy:.spec.restartPolicy
kubectl get pods -o custom-columns=NAME:.metadata.name,Restart_Policy:.status.containerStatuses[0].image
```

## Draining nodes
```
# get the pods running in the node
kubectl get pods --field-selector spec.nodeName=worker-1 -o wide -A

# drain the node - pods managed by daemonsets will not be evicted
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data

# staus should be SchedulingDisabled 
kubectl get node
kubectl describe node worker-1 | grep Unschedulable

# uncordon the node
kubectl uncordon worker-1

```


## View Cluster information
```
kubectl cluster-info
kubectl cluster-info dump
kubectl get all -o wide -A

```

## Node operations
```
kubectl get nodes --show-labels
kubectl label nodes master-1 nodename=master-1
kubectl label nodes worker-1 disktype=local
```



## Enable kubectl auto completion

```
dnf install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

## Configure kubetl aliases
```
vi .bash_profile

# kubectl aliases
alias k=kubectl
alias kgn='kubectl get nodes'
alias kgnw='kubectl get nodes -o wide'
alias kgp='kubectl get pods -A'
alias kgpw='kubectl get pods -A -o wide'
alias kdp='kubectl describe pod'
alias kga='kubectl get all -A'
alias kgaw='kubectl get all -A -o wide'
alias kl='kubectl logs'
```
```
complete -o default -F __start_kubectl k
```




kubectl port-forward svc/productpage 9080





## Deactivate VSCODE linter warning s

Following message will appear if you dont have both cpu and memory limits ocnifgure in yaml
One or more containers do not have resource limits - this could starve other processes 

To deactiviate this warning do the following
```
Ctrl +, --> Open Settings JSON Icon on Top Right corner

Go to Seetings.json and add following

{
    "vs-kubernetes": {
        "disable-linters": ["resource-limits"],        
    },
```

