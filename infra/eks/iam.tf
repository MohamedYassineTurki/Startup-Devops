resource "aws_iam_role" "BookAdvisor_EKS_Cluster_Role" {
    name = "BookAdvisor_EKS_Cluster_Role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Principal = {
            Service = "eks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
        ]
    })
    tags = {
        Project = "BookAdvisor"
        Environment = "shared"
    }
}

resource "aws_iam_role_policy_attachment" "EKS_Cluster_Policy_Attachment" {
    role       = aws_iam_role.BookAdvisor_EKS_Cluster_Role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "EKS_Service_Policy_Attachment" {
    role       = aws_iam_role.BookAdvisor_EKS_Cluster_Role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}



resource "aws_iam_role" "BookAdvisor_Node_Group_Role" {
    name = "BookAdvisor_EKS_Node_Group_Role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
        ]
    })
    tags = {
        Project = "BookAdvisor"
        Environment = "shared"
    }  
}

resource "aws_iam_role_policy_attachment" "Node_Group_Policy_Attachment" {
    role       = aws_iam_role.BookAdvisor_Node_Group_Role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "Node_Group_CNI_Policy_Attachment" {
    role       = aws_iam_role.BookAdvisor_Node_Group_Role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "Node_Group_Read_Only_Policy_Attachment" {
  
    role       = aws_iam_role.BookAdvisor_Node_Group_Role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}