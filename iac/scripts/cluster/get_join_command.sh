#!/bin/bash
API_SERVER="$1:6443"
TOKEN=$(sudo kubeadm token list | awk 'NR==2{print $1}')
CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
JOIN_CMD="kubeadm join $API_SERVER --token $TOKEN --discovery-token-ca-cert-hash sha256:$CERT_HASH"
echo $JOIN_CMD > /home/ubuntu/scripts/join_cluster.sh