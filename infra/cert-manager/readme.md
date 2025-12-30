```
helm repo add jetstack https://charts.jetstack.io --force-update

helm upgrade \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.19.2 \
  --set crds.enabled=true \
  --values values.yaml
```