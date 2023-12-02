# k8ssandra-workspace

### Learning and practicing with K8ssandra.

## K8ssandra Operator Github:

[Kubernetes operator for K8ssandra.](https://github.com/k8ssandra/k8ssandra-operator)

## cassandra-exporter:

[cassandra-exporter is a Java agent (with optional standalone mode) that exports Cassandra metrics to Prometheus.](https://github.com/instaclustr/cassandra-exporter)

## Deploy cert-manager:

- helm repo add jetstack https://charts.jetstack.io
- helm repo update
- helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

### Deploy min.io

refer to minio.sh file

- kubectl get all -n minio
- kubectl -n minio port-forward svc/minio 9000:9000
- ssh -L 9000:127.0.0.1:9000 dev@master
- http://localhost:9000
- k8ssandra_key/k8ssandra_secret

### Deploy K8ssandra Operator:

- helm repo add k8ssandra https://helm.k8ssandra.io/stable
- helm repo update
- helm search repo k8ssandra --devel
- helm show chart k8ssandra/k8ssandra-operator
- helm install k8ssandra-operator k8ssandra/k8ssandra-operator -n k8ssandra-operator --create-namespace


- kubectl get crds | grep k8ssandra
- kubectl get pods -n k8ssandra-operator

> **note:**: this will take some time, will show some PV related errors. later when checking logs the liveness and
> readiness probes will appear to fail in logs but after some time eventaully the pod will come up successfully.

- kubectl apply -f k8ssandra-cluster.yaml
- kubectl -n k8ssandra-operator get k8cs demo
- kubectl -n k8ssandra-operator describe k8cs demo

### Single-cluster install with helm

[Single-cluster install with helm](https://docs.k8ssandra.io/install/local/single-cluster-helm/)

### Sample manifests:

[Sample manifests](https://docs.k8ssandra.io/quickstarts/samples/)

### Extract credentials

- CASS_USERNAME=$(kubectl get secret demo-superuser -n k8ssandra-operator -o=jsonpath='{.data.username}' | base64
  --decode)
- echo $CASS_USERNAME

### Now obtain the password secret

- CASS_PASSWORD=$(kubectl get secret demo-superuser -n k8ssandra-operator -o=jsonpath='{.data.password}' | base64
  --decode)
- echo $CASS_PASSWORD

## Using Cassandra DB

### Check Status:

> kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- nodetool -u $CASS_USERNAME -pw
> $CASS_PASSWORD status

### Or

> - kubectl exec -it -n k8ssandra-operator demo-dc1-default-sts-0 -c cassandra -- /bin/bash
> - nodetool -u demo-superuser -pw E70M67aq6IOhMP9jpoXs status

### Insert Records:

#### Create Keyspace 'Test':

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "CREATE KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};"

#### Create Table "Users':

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "CREATE TABLE test.users (email text primary key, name text, state text);"

#### Insert Records:

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('john@gamil.com', 'John Smith', 'NC');"

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('joe@gamil.com', 'Joe Jones', 'VA');"

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('sue@help.com', 'Sue Sas', 'CA');"

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "insert into test.users (email, name, state) values ('tom@yes.com', 'Tom and Jerry', 'NV');"

#### Select All Records:

> - kubectl exec -it demo-dc1-default-sts-0 -n k8ssandra-operator -c cassandra -- cqlsh -u $CASS_USERNAME -p
    $CASS_PASSWORD -e "select * from test.users;"

#### Or

> - kubectl exec -it -n k8ssandra-operator demo-dc1-default-sts-0 -c cassandra -- /bin/bash
> - nodetool -u demo-superuser -pw E70M67aq6IOhMP9jpoXs status
> - cqlsh -u demo-superuser -p E70M67aq6IOhMP9jpoXs demo-dc1-stargate-service
> - DESCRIBE KEYSPACES;
> - use test;
> - select * from users;

### Expose Service:

> **note:**: we can port-forward startgate service's 9042 port and access the cqlsh from outside the cluster
> demo-dc1-stargate-service is the startgate service which exposes 9042 cqlsh port
> port forward 9042 port of stargate service to local machine
> - kubectl -n k8ssandra-operator port-forward svc/demo-dc1-stargate-service 9042:9042

> **note:**: Because i'm running via master virtual machine, the port forward is on master, so i need to create SSH port
> forwarding from my mac host machine to master vm:
> - ssh -L 9042:127.0.0.1:9042 dev@master

#### Then i can connect via Intellij Idea, as below:

![Screenshot 2023-09-09 at 5.11.57 pm.png](Screenshot%202023-09-09%20at%205.11.57%20pm.png)

### Expose Service of type load balancer:

- kubectl expose service demo-dc1-stargate-service -n k8ssandra-operator --port=9042 --target-port=9042
  --name=cassandra-exposed --type=LoadBalancer



helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm install k8ssandra k8ssandra/k8ssandra -n k8ssandra -f values.yaml

kubectl wait --for=condition=Ready cassandradatacenter/dc1 --timeout=900s -n k8ssandra-operator

kubectl -n k8ssandra-operator rollout status deployment demo-dc1-default-stargate-deployment
kubectl -n k8ssandra-operator describe cassandradatacenter/dc1



kubectl create job --image=nosqlbench/nosqlbench nosqlbench -n k8ssandra-operator -- java -jar nb.jar cql-iot rampup-cycles=1k cyclerate=50 \
username=$username password=$password main-cycles=5k write_ratio=7 read_ratio=3 async=50 hosts=k8ssandra-dc1-service --progress console:1s -v

kubectl -n k8ssandra-operator get jobs

kubectl -n k8ssandra-operator logs job/nosqlbench --follow




### Remove CRDS:

kubectl delete crd cassandratasks.control.k8ssandra.io
kubectl delete crd clientconfigs.config.k8ssandra.io
kubectl delete crd k8ssandraclusters.k8ssandra.io
kubectl delete crd k8ssandratasks.control.k8ssandra.io
kubectl delete crd medusabackupjobs.medusa.k8ssandra.io
kubectl delete crd medusabackups.medusa.k8ssandra.io
kubectl delete crd medusabackupschedules.medusa.k8ssandra.io
kubectl delete crd medusarestorejobs.medusa.k8ssandra.io
kubectl delete crd medusatasks.medusa.k8ssandra.io
kubectl delete crd reapers.reaper.k8ssandra.io
kubectl delete crd replicatedsecrets.replication.k8ssandra.io
kubectl delete crd stargates.stargate.k8ssandra.io

## References:

[K8ssandra 1.1 Walkthrough Featuring MinIO Backup](https://www.youtube.com/watch?v=RyO60H9s0UI)
