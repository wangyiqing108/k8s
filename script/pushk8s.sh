#!/bin/bash
IMAGES=`docker images| grep k8s.gcr.io| grep -v latest | awk '{print $1":"$2}'`
NAMES=`docker images| grep k8s.gcr.io| grep -v latest | awk '{print $1}'|awk -F '/' '{print $2}'`
VERSIONS=`docker images| grep k8s.gcr.io| grep -v latest | awk '{print $2}'`
imagearr=($(echo $IMAGES|tr "\r" "\n"))
namearr=($(echo $NAMES|tr "\r" "\n"))
versionarr=($(echo $VERSIONS|tr "\r" "\n"))

for((i=0;i<${#imagearr[@]};i++))
do
  docker tag  ${imagearr[$i]} 192.168.210.10:8099/k8s/${namearr[$i]}:${versionarr[$i]}
  docker push 192.168.210.10:8099/k8s/${namearr[$i]}:${versionarr[$i]}
done







