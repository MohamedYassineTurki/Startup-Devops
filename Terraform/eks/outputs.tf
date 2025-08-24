#The diffrence between arn and id is that arn is the full Amazon Resource Name, which includes the service, region, account ID, resource type, and resource name. The id is just the unique identifier for the resource within that service.
output "EKS_Cluster_Role_ARN" {
  description = "The ARN of the EKS Cluster Role"
  value       = aws_iam_role.BookAdvisor_EKS_Cluster_Role.arn

}
output "EKS_Node_Group_Role_ARN" {
  description = "The ARN of the EKS Node Group Role"
  value       = aws_iam_role.BookAdvisor_Node_Group_Role.arn
}

output "EKS_Cluster_Security_Group_ID" {
  description = "The security group ID of the EKS Cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

