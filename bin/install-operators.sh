# helm repo add kedacore https://kedacore.github.io/charts
# helm repo update
# helm fetch kedacore/keda --version 2.11.2 -d ../helm
# helm install keda kedacore/keda --namespace keda -create-namespace
helm install keda \
    ../helm/keda-2.11.2.tgz \
    --namespace keda --create-namespace

# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update
# helm fetch bitnami/rabbitmq-cluster-operator --version 3.6.5 -d ../helm
# helm install rabbitmq bitnami/rabbitmq-cluster-operator --namespace rabbitmq -create-namespace
helm install rabbitmq \
    ../helm/rabbitmq-cluster-operator-3.6.5.tgz \
    --namespace rabbitmq --create-namespace \
    --set useCertManager=true \
    --set clusterOperator.resources.limits.cpu=500m \
    --set clusterOperator.resources.limits.memory=2Gi \
    --set clusterOperator.resources.requests.cpu=500m \
    --set clusterOperator.resources.requests.memory=2Gi \
    --set msgTopologyOperator.resources.limits.cpu=500m \
    --set msgTopologyOperator.resources.limits.memory=2Gi \
    --set msgTopologyOperator.resources.requests.cpu=500m \
    --set msgTopologyOperator.resources.requests.memory=2Gi 
