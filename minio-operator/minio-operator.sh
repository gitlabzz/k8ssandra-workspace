helm repo add minio-operator https://operator.min.io
helm search repo minio-operator
helm install --namespace minio-operator --create-namespace operator minio-operator/operator
kubectl get all -n minio-operator

kubectl get deployments -A --field-selector metadata.name=minio-operator

cat <<EOF >tls-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-tls-secret
  namespace: minio-operator
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdDakNDQlBLZ0F3SUJBZ0lVWk9sOTc3UCsvOEtvUlBVQWdiOGFreGZoYVpNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2daY3hDekFKQmdOVkJBWVRBa0ZWTVF3d0NnWURWUVFJREFOT1UxY3hEekFOQmdOVkJBY01CbE41Wkc1bAplVEVPTUF3R0ExVUVDZ3dGUVhoM1lYa3hIakFjQmdOVkJBc01GWEJ5YjJabGMzTnBiMjVoYkNCelpYSjJhV05sCmN6RVlNQllHQTFVRUF3d1BZWEJwTG1WNFlXMXdiR1V1WTI5dE1SOHdIUVlKS29aSWh2Y05BUWtCRmhCaGJXbHkKZW1GQVlYaDNZWGt1WTI5dE1CNFhEVEl5TURjeE56QXpOVFUxTVZvWERUTXlNRGN4TkRBek5UVTFNVm93Z1pjeApDekFKQmdOVkJBWVRBa0ZWTVF3d0NnWURWUVFJREFOT1UxY3hEekFOQmdOVkJBY01CbE41Wkc1bGVURU9NQXdHCkExVUVDZ3dGUVhoM1lYa3hIakFjQmdOVkJBc01GWEJ5YjJabGMzTnBiMjVoYkNCelpYSjJhV05sY3pFWU1CWUcKQTFVRUF3d1BZWEJwTG1WNFlXMXdiR1V1WTI5dE1SOHdIUVlKS29aSWh2Y05BUWtCRmhCaGJXbHllbUZBWVhoMwpZWGt1WTI5dE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBdWJKOXVlemdRTWtNCjBDSk94K3BwNDhUbmRZZkZzSndOV243blJLb0RzMUs2SE02Z3BYZitTS2ZkWG9zZEpuUXNlaEF3TVJBbklrOEIKVWRsTXBhTGd1NUVqZ2M2MHF4eU9RQm5UTUR5M00wdFlGTE11OEhtbC85ZmpkNmZWd2hPMGR5NGdBZXoxQVJyNAo1Z2xtWDF4dGQycUl3MXVkenE5dXFuaGlxdmZFR1BKQlZ1MDFJa1B6V0JCUldoaUNGR3ovMjN5VitSSXhVOXhDCnZZNkt3bXJlTWo2bUd0L3orZ0VYZjFhZEVjWlZabWpNK0EvRTF6YS8wQ3dTR2ZhY21va0FZbTRPaWRWVk1mbW8KbGNQRW0rUEw2QVpyMFpWUm1uRjN4S3crT3YrVEtFTGtlV2hFTDdtc1l0ZHQwSTVLQXBPaHlZYUZ3ZStHQy9HSApXWnZqRFB2SWZ3SURBUUFCbzRJQ1NqQ0NBa1l3SFFZRFZSME9CQllFRkFNRytWeXJTRExaV2xOMWEwTnFNVnpHCit6Z0lNSUhYQmdOVkhTTUVnYzh3Z2N5QUZBTUcrVnlyU0RMWldsTjFhME5xTVZ6Ryt6Z0lvWUdkcElHYU1JR1gKTVFzd0NRWURWUVFHRXdKQlZURU1NQW9HQTFVRUNBd0RUbE5YTVE4d0RRWURWUVFIREFaVGVXUnVaWGt4RGpBTQpCZ05WQkFvTUJVRjRkMkY1TVI0d0hBWURWUVFMREJWd2NtOW1aWE56YVc5dVlXd2djMlZ5ZG1salpYTXhHREFXCkJnTlZCQU1NRDJGd2FTNWxlR0Z0Y0d4bExtTnZiVEVmTUIwR0NTcUdTSWIzRFFFSkFSWVFZVzFwY25waFFHRjQKZDJGNUxtTnZiWUlVWk9sOTc3UCsvOEtvUlBVQWdiOGFreGZoYVpNd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVgpIUThFQkFNQ0F2d3dnWllHQTFVZEVRU0JqakNCaTRJTFpYaGhiWEJzWlM1amIyMkNEU291WlhoaGJYQnNaUzVqCmIyMkNFVzVuYVc1NExtVjRZVzF3YkdVdVkyOXRnZzloYm0wdVpYaGhiWEJzWlM1amIyMkNFR0Z3YVcwdVpYaGgKYlhCc1pTNWpiMjJDRTNSeVlXWm1hV011WlhoaGJYQnNaUzVqYjIyQ0QyRndhUzVsZUdGdGNHeGxMbU52YllJUgpiMkYxZEdndVpYaGhiWEJzWlM1amIyMHdnWllHQTFVZEVnU0JqakNCaTRJTFpYaGhiWEJzWlM1amIyMkNEU291ClpYaGhiWEJzWlM1amIyMkNFVzVuYVc1NExtVjRZVzF3YkdVdVkyOXRnZzloYm0wdVpYaGhiWEJzWlM1amIyMkMKRUdGd2FXMHVaWGhoYlhCc1pTNWpiMjJDRTNSeVlXWm1hV011WlhoaGJYQnNaUzVqYjIyQ0QyRndhUzVsZUdGdApjR3hsTG1OdmJZSVJiMkYxZEdndVpYaGhiWEJzWlM1amIyMHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQ25uCkVVSHZZMXVReldacnpwSGRSUnJqNWI0MDZkUTFzYWttV3dPeEl1aXBvZlU2aGQxSGdiZTlRZnd3TWNuMEdyVEsKRE5STnF0enNGRVZxOWZ3MUFDd3ZOT2dkeXRUTEp5MVU3ZG1CWFA4T2E2dzlWOC9oRTNOMjdCLzcyZzFTMmx6QQpoSmtvaFhJem5sK1E2aDlRL3FtUGdudEdOL3RqL0RrOHVpNmRwb1c3cElZQ0diV2JuMkd4SGFQdnk4TVFGbjNsCnZjTkt2K1NZZkJpUmtBMTNOUVJWUHpKdlplWTdGTDV4WXgzQlNkaWh5YTdwZzUvR21BL3RMV0psUG81MGQwRkkKeXh3UXdaaFFHY1N0YUE4bTMwb0NnYisyM0ZsWlRKZDZ6SW8zUmxmNUp3b2NBOTJqbFFaWGZXYkNVWkF1MnVjUwpqTVZZK2R4RWkvcloxeTZibW0wPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdWJKOXVlemdRTWtNMENKT3grcHA0OFRuZFlmRnNKd05XbjduUktvRHMxSzZITTZnCnBYZitTS2ZkWG9zZEpuUXNlaEF3TVJBbklrOEJVZGxNcGFMZ3U1RWpnYzYwcXh5T1FCblRNRHkzTTB0WUZMTXUKOEhtbC85ZmpkNmZWd2hPMGR5NGdBZXoxQVJyNDVnbG1YMXh0ZDJxSXcxdWR6cTl1cW5oaXF2ZkVHUEpCVnUwMQpJa1B6V0JCUldoaUNGR3ovMjN5VitSSXhVOXhDdlk2S3dtcmVNajZtR3QveitnRVhmMWFkRWNaVlptak0rQS9FCjF6YS8wQ3dTR2ZhY21va0FZbTRPaWRWVk1mbW9sY1BFbStQTDZBWnIwWlZSbW5GM3hLdytPditUS0VMa2VXaEUKTDdtc1l0ZHQwSTVLQXBPaHlZYUZ3ZStHQy9HSFdadmpEUHZJZndJREFRQUJBb0lCQUhnWUIxZUc2a0Q3eFYyVgowbjFZRE1OUlJKK3QveHdJMEZvR1dHci95UVRnSzUwVnhLOCt1eVVoNnZpSjM0QlBBYlN2WTN0WGh2ZVpRTEUrCloyTjN3ditMRGZ1VlF5S21oUmpQbXRWSGJ2T3RkbmxzcUo2OURhNDRZTk94cDN5c1libnlDcUUwTGY5WkFqOUQKTlFIWE5MUldJYnkyTTRqSHpEcFRRUHh3NEZHQXYvSTNhRTl5VlhZZ1pTWWlvSFpiWkRJY0UyQnRTZWs2cjZxZwowZHFXRlNONGZzUldLczJqUFM2ZjdPejRMclZML2tzTXkraDd1MHJQbU1sVGpUN2pkNHNORGZkTHdPb09YZ29BCmVIMllaMzVNZnc5MGdQeTF2bjRnOGp6V0FTeDBHWDRnNnBKaHFtVDhCQnV6NmhHWktrdzIwcG1DbjQxWjUvMlUKT2VDY01ZRUNnWUVBN0ZUVENsc2R4Tysweis4UGRuZUVyYXA5ZmNhdTNMdEdOUVZremNleVdYMVd5WUZ6MDZLcQphOCtsaFhBaFhmNCs5T2J6NHFyNitoTk9SRDc0ZndXcHBxcmNPVE9teXBqMTg3MmZ2bGVpa1Q2c0Z1TGFDRmxWCk1zMlZWSUt3TnpOVkY4TUlSc2hONzBaTGlpQ3RRdS9yOVVBSmpHdzNQb2JoOWNqT1lST3JuV3NDZ1lFQXlTYmcKc3YvUUM1RHBOV3RmKzFLMmZOTW9PdWxyclB1RW1zZ3p6MTVuMDFCcUJjbUU5OU52dTFTc2s3eDZ3c0RRaHRpegpYNVIyVUVmRThpTmw5dEJtQnpIOExnYXZVREVoYkRlSW5LYUlVMXhuTTJ3KzZGRWNyMWU3cnErb3czR1FIbzJnClpYY3lLUjE1WUU1cXpUK3JkNzB2RnM3Z0NsaStFWkdaUnVYQlVqMENnWUFRRFBiRVZrbmdUVE5uaCtIeDlzNFIKQ1dvNmQ1cjZyTkZvMm5QdE1lbmdBQTQ3NDBuZGpzZXFTTkVDRGdxR0dyVmw1cVdidUdjUlF1eG00Q3Y2WElVWQpKN1NMUWdISzhyYUpsbEJhR2hPVmI3ODZVcS9pTDBjRkMwZGdGUHdvMDVpczQzY1ZiNWN6Yi8vRFl0TEJvQS9UCmVVVHN2NURFODE0M1Zpc0dGdExwL3dLQmdRREJxbmJJb0ZjejY0ODg2V1o5Mk1MdUozY2lVVDVrUzd6K01TY0EKem9uMEFBWTBFRE8vVDRqUnVkSjJZdzltbHJHdVF0RmdndFh1c1VyRFBxV2JIa1k5UXpqakwzaDNJdlprOUlySgpGK1ZGTFVBSFdINnd1ZmQrTWwvMjdoVDBKMUIwdWpMbHZmOURhcWREdS94RUpMcjRDK05jZUUxb2FNeUdxY0lECmFvM1ltUUtCZ0hQT2Rta3RLTDhYLzN4VG1xRHAyMld2S0pZMjY1RVV3K3VRdkQ4d214eGtSM2lWTVFVWEgyQncKWTgrTHc5KzNJWkJXcmFMUjExd0JKK1R6K1RjZkk5eGExd0lVNDRMZmtmcmNjWnNsTEhWUTJRanRyOUVKZHR4Sgo3N1NYaFBXZHpwY0JNNExTWTY5Ty8xL3V6dUhQYm9iZlp5RTgySG41M3FoZVhpM0hzTllSCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

EOF

kubectl apply -f tls-secret.yaml

cat <<EOF >console-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: console-ingress
  namespace: minio-operator
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: console.172.16.236.200.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: console
                port:
                  number: 9090
  tls:
    - hosts:
        - console.172.16.236.200.nip.io
      secretName: api-tls-secret
EOF

kubectl apply -f console-ingress.yaml

kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r ".data.token" | base64 -d

cat <<EOF >minio-client.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: minio-client
  name: minio-client
  namespace: minio-operator
spec:
  containers:
    - name: minio-client
      image: minio/mc
      command: [ "bash", "-c" ]
      args:
        - |
          sleep 60
EOF
kubectl apply -f minio-client.yaml
