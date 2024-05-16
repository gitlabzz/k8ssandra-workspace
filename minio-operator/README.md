https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-operator-helm.html?ref=github


helm repo add minio-operator https://operator.min.io
helm search repo minio-operator
helm install --namespace minio-operator --create-namespace operator minio-operator/operator
kubectl get all -n minio-operator


cat << EOF > tls-secret.yaml

EOF

kubectl apply -f tls-secret.yaml

cat << EOF > console-ingress.yaml

EOF

kubectl apply -f console-ingress.yaml

kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r ".data.token" | base64 -d

