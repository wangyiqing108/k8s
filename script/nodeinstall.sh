#!/bin/bash

detect_color_support() {
    if [ $? -eq 0 ]; then
        RC="\033[1;31m"
        GC="\033[1;32m"
        BC="\033[1;34m"
        YC="\033[1;33m"
        EC="\033[0m"
    else
        RC=""
        GC=""
        BC=""
        YC=""
        EC=""
    fi
}
detect_color_support
config_host(){
   cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#关闭swapo
swapoff -a

sysctl -p /etc/sysctl.d/k8s.conf

#配置yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
echo "${BC}config host success${BC}"
}

kubeadm_install(){
  yum makecache fast
  yum install -y kubelet-1.10.0-0 kubeadm-1.10.0-0 kubectl-1.10.0-0
  if [ $? -eq 0 ]; then
    echo "${BC}kebeadm install success ${BC}"
  else
    echo "${RC}kubeadm install faile${RC}"
  fi
  #更改配置
  sed -i 's/systemd/cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload
}

docker_install(){
   yum install -y docker
   sed -i "/OPTIONS/s/'$/ /" /etc/sysconfig/docker
   sed -i "/OPTIONS/ s/$/ --insecure-registry 192.168.210.10:8099'/" /etc/sysconfig/docker
   tee <<EOF > /etc/docker/daemon.json
{"registry-mirrors": ["https://0qlh0h7j.mirror.aliyuncs.com"]}
EOF
  if [[ " cgroupfs" != `docker info |grep "Cgroup Driver"|awk -F ':' '{print $2}'` ]];then
    sed -i 's/systemd/cgroupfs/' /lib/systemd/system/docker.service 
  fi 
  systemctl daemon-reload
  systemctl start docker
  if [ $? -eq 0 ]; then
    echo "${BC}docker install success ${BC}"
  else
    echo "${RC}docker install faile${RC}"
  fi
}

docker_login(){
  docker login 192.168.210.10:8099 -u admin -p "Harbor12345"
  if [ $? -eq 0 ]; then
    echo "${BC}docker login success${BC}"
  else
    echo "${RC}docker loin faile${RC}"
  fi
}

pull_images(){

  docker pull 192.168.210.10:8099/k8s/kube-proxy-amd64:v1.10.0
  docker pull 192.168.210.10:8099/k8s/flannel:v0.10.0-amd64
  docker pull 192.168.210.10:8099/k8s/pause-amd64:3.1
  docker pull 192.168.210.10:8099/k8s/kubernetes-dashboard-amd64:v1.8.3
  docker pull 192.168.210.10:8099/k8s/heapster-influxdb-amd64:v1.3.3
  docker pull 192.168.210.10:8099/k8s/heapster-amd64:1.4.2
  docker pull 192.168.210.10:8099/k8s/heapster-grafana-amd64:v4.4.3
  
  docker tag 192.168.210.10:8099/k8s/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
  
  IMAGES=`docker images| grep '192.168.210.10:8099' | grep -v 'flannel' | awk '{print $1":"$2}'`
  NAMES=`docker images| grep '192.168.210.10:8099' | grep -v 'flannel' | awk '{print $1}'|awk -F '/' '{print $3}'`
  VERSIONS=`docker images| grep '192.168.210.10:8099' | grep -v 'flannel' | awk '{print $2}'`
  imagearr=($(echo $IMAGES|tr "\r" "\n"))
  namearr=($(echo $NAMES|tr "\r" "\n"))
  versionarr=($(echo $VERSIONS|tr "\r" "\n"))
  
  for((i=0;i<${#imagearr[@]};i++))
  do
    docker tag  ${imagearr[$i]} k8s.gcr.io/${namearr[$i]}:${versionarr[$i]}
  done
}

node_init(){
  kubeadm join 192.168.210.48:6443 --token iozfkb.86hkxppynbn8fpo8 --discovery-token-ca-cert-hash sha256:9bdb55ac466fce0d95d4fd34552994c44bf182ca070d1a9cad1679e611a670f2 --ignore-preflight-errors=Swap
  if [$? -eq 0 ]; then
    echo "${BC}node init success${BC}"
  else
    echo "${RC}node init faile${RC}"
    kubeadm reset
  fi

  #配置kubectl
  mkdir -p $HOME/.kube
  #cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  #chown $(id -u):$(id -g) $HOME/.kube/config
}

main(){
  #config_host
  #kubeadm_install
  #docker_install
  #docker_login
  #pull_images
  #node_init
  echo "d"
}

#main

