#!/usr/bin/bash
curl -sfL https://get.k3s.io | sh -
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add my-repo https://charts.bitnami.com/bitnami
mkdir .kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chmod 777 ~/.kube/config
KUBECONFIG=~/.kube/config
helm install my-release my-repo/nginx
cat <<EOL > ~/nginx-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-release
data:
  nginx.conf: |-
    data:
      events {
          worker_connections  2048;
      }
EOL
sudo kubectl apply -f nginx-configmap.yaml
sudo kubectl get configmap
cat <<EOL > ~/nginx-values.yaml
staticStiteConfigmap: nginx.conf
EOL
helm upgrade my-release my-repo/nginx -f nginx-values.yaml
# helm uninstall my-release