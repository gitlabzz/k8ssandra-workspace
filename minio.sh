cat << EOF > medusa-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: medusa-bucket-key
  namespace: k8ssandra-operator
type: Opaque
stringData:
  credentials: |-
    [default]
    aws_access_key_id = k8ssandra_key
    aws_secret_access_key = k8ssandra_secret
EOF

kubectl apply -f medusa-secret.yaml

helm repo add minio https://helm.min.io

helm install --namespace minio --create-namespace minio minio/minio --set replicas=2,accessKey=k8ssandra_key,secretKey=k8ssandra_secret,defaultBucket.enabled=true,defaultBucket.name=k8ssandra-medusa
