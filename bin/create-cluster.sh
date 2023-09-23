. vars.sh
kops create -f ../kops/cluster-and-groups.yaml 
kops create secret --name $NAME sshpublickey admin -i /home/aharon/.ssh/id_rsa_aharon_dev.pub
kops create secret --name $NAME dockerconfig -f ../kops/dockerconfig.json
kops update cluster --name demo.harley.systems --yes
kops export kubeconfig --admin=87600h0m0s --name demo.harley.systems
kops validate cluster --name $NAME --wait 15m --count 3

