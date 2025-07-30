#!/bin/bash
set -ex

# Define vars
CLUSTER_NAME="test-cluster-1"
REGION="us-east-1"
B64_CLUSTER_CA="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJYklDcVJBV01zVW93RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBM016QXlNVEkxTXpGYUZ3MHpOVEEzTWpneU1UTXdNekZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNSaExBMXhpYTFKY0YyTERibGFhWk4yYVdlc01Bcm1CUlM3VGd4SkJlZEtuQ2ZaRFBsUTVLdVA3NzcKL2hEeExUeWpIWE5IcTg5WXJyK2RZUUx4NmpEZTYwTUtWOWVVNW9QK21QWEl5c2R4ZjZzamNRckxURzJGbzdvYgo0SUtpakVGZWZMcUl1Q1h3ODZKbjZmNndRWEt3K1N2WE0rQ0t4c2JMM3hGc29mcHJUSEE0V3RSWjNqT1BWR3R1Cnl3KzVaNzJKenNhNzFnelJ5QlY1SlBBT1FoQ29EYUhmY2g1ZjNNbElKYm9xWXk0KzNMVlMzT3ljbEVnZzlTWEcKK1poTUVYUzB0bURkV3I0MkpyM28rU2VCZGFXenlXTzIzNGNWUEVCNHdwaVd1c3BIQnFjTXhnZHFTZVZXZVFQegpYdGJiaHZzVWFxdlErdEtCZ0lEUU43SHh1bndWQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUMUhWOHlJNFhIWDZVdzlFdENtOU5xZUl5QmJEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ0loU2lUZlpFNQpVM3pJd2VTT1RDOHA4TWJEZXY0OEtyd2pRbjhlNTFQYnhuWjJXVzZOQmJrWm0wd1g2cThuN2tVRnV6T3haUklFCnNFK3NSVzhLVitoelI1MmM0SmpNTlU1N1BXNXpXN0k0NGsxcEhzdDlYdU1UazJzMW1FSm9kaGw0N0R4TXN4b2cKTHpoRFBycExoV2dicUd6OTNPWEgzVDdWTHhLT3pnL0NOaDViV3lDVWpQRHZENzhMQ0JEenBMTWhoTjNJVlp3dAo5bmhXT3FidTVxa0ttcnp1d212dFN6OHdZc0tjd2Y0VCt6dkdXWnQ0SmJhbzdueTBpWi9PNEZTMlpvK2o3dVozCnh4ODlUVnlHZFJLNTk3WjU1WGUxWnRHZ2w5UEltcjN0MmVHNlZ1V1Q3ZlVxdUl4MVV0OUFROUpYdS9NZStaZ28KSnliS3FRTzYxMG5HCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
APISERVER_ENDPOINT="https://D013B94E9B2826068A144F46BA68C3D9.gr7.us-east-1.eks.amazonaws.com"

# Install dependencies
dnf update -y
dnf install -y curl unzip tar conntrack socat iptables jq

# Install containerd (preferred over Docker for K8s)
dnf install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl enable --now containerd

# Enable required kernel modules and settings
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

# Install kubelet
K8S_VERSION="1.31.0"
curl -LO https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/amd64/kubelet
install -o root -g root -m 0755 kubelet /usr/bin/kubelet

# Install kubectl
curl -LO "https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/bin/kubectl

# Install aws-iam-authenticator
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest/download/aws-iam-authenticator-linux-amd64
chmod +x aws-iam-authenticator
mv aws-iam-authenticator /usr/bin/

# Generate kubeconfig for kubelet
mkdir -p /var/lib/kubelet
cat <<EOF > /var/lib/kubelet/kubeconfig
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${B64_CLUSTER_CA}
    server: ${APISERVER_ENDPOINT}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
users:
- name: kubelet
  user:
    exec:
      apiVersion: "client.authentication.k8s.io/v1beta1"
      command: "/usr/bin/aws"
      args:
        - "eks"
        - "get-token"
        - "--region"
        - "${REGION}"
        - "--cluster-name"
        - "${CLUSTER_NAME}"
EOF

# Create minimal kubelet systemd service
cat <<EOF > /etc/systemd/system/kubelet.service
[Unit]
Description=Kubelet
After=network.target

[Service]
ExecStart=/usr/bin/kubelet \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock \
  --cloud-provider=aws \
  --register-node=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start kubelet
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now kubelet
