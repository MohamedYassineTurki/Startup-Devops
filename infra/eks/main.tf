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