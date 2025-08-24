#!! After creating the cluster you can uncomment the node group resource to apply it.

#!!aws eks update-kubeconfig --region eu-west-3 --name BookAdvisor_cluster


#!! installed cert manager for the custer using:
#kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml
#kubectl create namespace cert-manager
#kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml

#!! installed aws load balancer controller using:
#kubectl create namespace kube-system
#Create the serviceaccount.yml file in the infra/eks directory
#kubectl apply -f serviceaccount.yaml
#helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=BookAdvisor_cluster --set region=eu-west-3 --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller


#created three namespaces for the applications : dev , qa , prod by using:
#kubectl create namespace dev

resource "aws_eks_cluster" "eks_cluster" {
  name     = "BookAdvisor_cluster"
  role_arn = aws_iam_role.BookAdvisor_EKS_Cluster_Role.arn
  version = var.kubernetes_version

  vpc_config {
    subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  }
  depends_on = [ aws_iam_role_policy_attachment.EKS_Cluster_Policy_Attachment,
                 aws_iam_role_policy_attachment.EKS_Service_Policy_Attachment ]
  tags = {
    Project = "BookAdvisor"
    Environment = "shared"
  }
}


#!! make sure to create the cluster before the node group thats why i commented the node group resource at first apply
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "BookAdvisor_node_group"
  node_role_arn = aws_iam_role.BookAdvisor_Node_Group_Role.arn
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = [ "t3.small" ]
  depends_on = [ aws_iam_role_policy_attachment.Node_Group_Policy_Attachment,
           aws_iam_role_policy_attachment.Node_Group_CNI_Policy_Attachment,
           aws_iam_role_policy_attachment.Node_Group_Read_Only_Policy_Attachment ]
  tags = {
    Project = "BookAdvisor"
    Environment = "shared"
  }
}

