
# Autoscaling demo 

This repository contains the demo for kubernetes autoscaling presentation. 


## Create demo cluster

The demo uses the kOps based kubernetes cluster. All the files required to create the kubernetes cluster are in this repository.

### Assumptions

Before creating the cluster, you should have 

- a route53 domain for the parent zone - here we use the *harley.systems* parent domain
- aws profile configuration that allows access to your aws account. here it is under the aws profile called *AWS_PROFILE=harley-systems-mfa*
- install *kubectl*, *kops* and *helm*. when creating this repo, I used the following versions:
  - kubectl v1.25.12 
  - kOps 1.25.3
  - helm 3.9.3
- if using *aws-iam-authenticator*, make sure you install it on your laptop/client computer

### Steps to create demo cluster


0. Clone this repository and enter the folder

```shell
git clone 
cd k8s-autoscaling-demo/
```

1. Optional - define access to private container registry or authenticated access to public container registry

Create kops/dockerconfig.json file 

```json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "<base 64 encoded string user:password"
		}
	}
}

```

if you want to use your own docker configuration for the demo cluster, you can use the following command instead:

```
cp ~/.docker/config.json kops/dockerconfig.json
```

2. Prepare kOps kubernetes cluster pre-requisites

Review the terraform/vars.tf file, then apply the terraform while customizing the variables
where required. The command will look something like:

```shell
cd terraform/
terraform apply -var="demo_state_bucket=<your state bucket name>" 
```

3. Adjust the kOps definitions and create the cluster.

Most probably, you will:
- replace all the occurrences of *harley.systems* in kops/cluster-and-groups to a string suitable in your case.
- replace the *arn:aws:iam::239082432822:role/admin* with an arn of admin role in your account
- adjust the *bin/vars.sh* to suit your environment (bucket names, aws profile name, cluster name and ssh key)

Then run:

```shell
cd ../bin/
./create-cluster.sh
./install-operators.sh
```

At this point, you should have the fully functional cluster.

4. Install demo software

examine both helm/demo-service/values.yaml and helm/demo-client/values.yaml of both demo-service and demo-client helm charts. 
Note the values that should be overridden in your use-case, then run the commands below to install adding the --set parameters as 
many times as necessary.

```shell
cd ../helm/
helm upgrade --install demo-service ./demo-service --namespace demo --create-namespace --set <parameter>=<value>
helm upgrade --install demo-client ./demo-client --namespace demo --set <parameter>=<value>
```

## About the cluster

The custer is fully functional kubernetes cluster. It has CSI plugin, CNI plugin, integration with AWS IAM users, Cluster Autoscaler and we also add the Keda and RabbitMQ charts.

Please, note that the cluster control plane and all the nodes are in the public network so do not use as-is for production or even for serious development. Without securing it, it should only be used for short POC then tier down scenario.

## About the demo

### Python applications

The demo consists of two python applications

- demo-client 
- demo-service

The demo-client is a web application that allows an authorized user to send given amount of messages to RabbitMQ exchange. This is to simulate workload tasks submitting. It also prints out the time at which the messages are submitted. This time is used as input to *bin/asg-wait-and-collect.sh* script.

To login to UI you can use the user *demo* with password obtained using command (on wayland) into your clipboard, then just paste it in password field:

```shell
kubectl -n demo get secret demo-client-user -o jsonpath={.data.password} | base64 -d | wl-copy
```

The demo-service is a RabbitMQ consumer that emulates a heavy data processing engine. Instead of any processing, it waits for 10 seconds to emulate processing durations.

To login into the RabbitMQ management UI, use below commands to copy the user into the clipboard

```shell
kubectl -n demo get secret rmq-default-user -o jsonpath={.data.username} | base64 -d | wl-copy
```

Paste the username in the username field, then use the following command to copy it's password

```shell
kubectl -n demo get secret rmq-default-user -o jsonpath={.data.password} | base64 -d | wl-copy
```

and paste it. Now you can access

### Bash Scripts

The *bin* folder contains many scripts, two of which we mentioned above in installation instructions.
Other useful scripts are:

- asg-wait-and-collect.sh
- asg.sh

The *asg-wait-and-collect.sh* should be ran after the workload is submitted using the demo-client UI. 
It will collect the timing for each of the stages of the scale-out and output it in CSV format.
This can be used to create charts in libreOffice or google sheets.

- Pod created at
- Instance boot
- Node created
- Node ready
- Pod scheduled
- Pod initialized
- Pod containers ready
- Pod ready

The *asg.sh* script prints basic info on the instances, nodes, hpa and pods that belong to an autoscaling group. It is useful to monitor the process of scale-out/scale-in at all levels.

It receives as it's parameters:
- a name of an autoscaling group, 
- name of the node group - value of the nodes label 'dedicated', 
- pods label 'app.kubernetes.io/name' value. 

For example to follow the state related to AWS ASG group *demo-wp.harley.systems* running in instance group called *demo-wp* running the application *demo-service*, use the command:

```shell
asg.sh demo-wp.harley.systems demo-wp demo-service demo-service
```

All the scripts either have explanation of their function in their first few lines, or they are just shortcut scripts
with some parameters set and running other scripts for the bin folder. Checkout all of them and see of you find them useful.