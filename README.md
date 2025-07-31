# By default eks cluster have access that who created the eks ckluster. If you have created eks cluster using root email create secret credentials for that user and login to eks cluster and create a config map with aws-auth name unser kube-system namespace  and populate user/role details that want to access the eks cluster

# Run bootstrap scrip as userdata on the self-managerd node group ami 

# prior to this we need to have node role with below policy  to get registed in the aws-auth config map under kube-system 

	• AmazonEKSWorkerNodePolicy
	• AmazonEC2ContainerRegistryReadOnly
	• AmazonEKS_CNI_Policy


