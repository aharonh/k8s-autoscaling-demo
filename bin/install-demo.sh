helm upgrade --install demo-service ../helm/demo-service --namespace demo --create-namespace
helm upgrade --install demo-client ../helm/demo-client --namespace demo 
