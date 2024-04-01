
#Security Group
#해당 보안 그룹을 가진 인스턴스들은 서로 모든 포트를 허용한다.
resource "aws_security_group" "k8s_node_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.cluster_name}-node-sg"
  description = "For k8s worker nodes"
}


resource "aws_security_group_rule" "k8s_node_sg_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # -1은 모든 프로토콜을 의미합니다.
  source_security_group_id = aws_security_group.k8s_node_sg.id
  security_group_id        = aws_security_group.k8s_node_sg.id
}

output "common_cluster_sg_id" {
  value = aws_security_group.k8s_node_sg.id
}
