#!/bin/sh

sudo apt update
sudo apt install git

### INSTALLATING NETFILTER CONFIG #### 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

lsmod | grep br_netfilter

### INSTALLATING NETWORK BRIDGE #### 
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

### SWAPOFF #### 
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

### INSTALLATING PACKAGES DOCKER #### 
sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

### ADDING KEYRING ####     
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

### ADDING KEYRING INTO SOURCES LIST #### 
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

### INSTALLATING DOCKER, DOCKER-CLI ####  
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

### CREATING A NEW FILE OF CGROUPDRIVER DOCKER #### 
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

### RESTARTING SERVICES DOCKER/CONTAINERD #### 
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker  

#sudo systemctl status docker
#sudo systemctl status containerd

### UPDATING AND ADDING KEYRING OF K8s #### 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

### INSTALLATING K8s #### 
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sleep 5
#sudo apt update
#sudo apt-cache madison kubeadm | tac
exit 1

-----------------------------------------------------------------------------------------------
### MANUALLY STEPS TODO ###

sudo nano /etc/containerd/config.toml
#disabled_plugins = ["cri"]
systemctl restart containerd.service
-----------------------------------------------------------------------------------------------
sudo kubeadm init

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#kubeadm token create --print-join-command
-----------------------------------------------------------------------------------------------
### TAINT NODES ###
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
#kubectl taint nodes --all node-role.kubernetes.io/master-
-----------------------------------------------------------------------------------------------
### INSTALL WEAVE NETWORK ###
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
-----------------------------------------------------------------------------------------------
kubectl get po -n kube-system
kubectl get nodes
kubectl get cs
-----------------------------------------------------------------------------------------------
### INSTALL CALICO COREDNS ###
#kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml 
#kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yam
-----------------------------------------------------------------------------------------------
#curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
#chmod 700 get_helm.sh
#./get_helm.sh
-----------------------------------------------------------------------------------------------
