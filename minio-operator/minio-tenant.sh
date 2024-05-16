helm search repo minio-operator

helm install --namespace minio-operator --create-namespace minio-operator minio-operator/tenant


cat <<EOF >tenant-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tenant-console-ingress
  namespace: minio-operator
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: tenant.172.16.236.200.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myminio-console
                port:
                  number: 9443
  tls:
    - hosts:
        - tenant.172.16.236.200.nip.io
      secretName: api-tls-secret
EOF

kubectl apply -f tenant-ingress.yaml

kubectl --namespace minio-operator port-forward svc/myminio-console 9443:9443