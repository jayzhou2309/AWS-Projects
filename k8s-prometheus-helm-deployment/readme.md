### Setup
### K8s - Ensure Minikube is installed
minikube start

### Run Command 
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack
kubectl get all

### Access Grafana
kubectl get deployment (Look for Grafana)
kubectl port-forward deployment/prometheus-grafana 3000

### localhost:3000 Login
username: admin

### Get pasword
kubectl get pods (Look for Grafana Pod) > pod.yaml
- Look for Password Env Variable
- GF_SECURITY_ADMIN_PASSWORD=*********

kubectl exec -it grafana-pod -- printenv | grep GF_SECURITY_ADMIN_PASSWORD

### Log Into Grafana UI

### Monitor 3rd Party Apps with Endpoint Configurations