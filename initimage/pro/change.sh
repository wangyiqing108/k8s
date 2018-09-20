#!/bin/bash
service=$1
namespace=$2
sed -i "s/k8sservice/$service/" /etc/config/prometheus.yml
sed -i "s/k8snamespace/$namespace/" /etc/config/prometheus.yml
