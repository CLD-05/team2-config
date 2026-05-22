# modules/bastion/variables.tf
#
# 역할: Bastion EC2 모듈 입력 변수 정의
#   - my_ip   : SSH 허용할 내 공인 IP (x.x.x.x/32) — 반드시 본인 IP만 허용
#   - key_name: AWS 콘솔에서 발급한 Key Pair 이름 (기본값: tf-key)
#               콘솔에서 발급한 키는 AWS가 공개키를 보관
#               -> aws_key_pair 리소스 불필요, data로 이름만 참조

variable "project" {
  description = "리소스 이름 prefix"
  type        = string
}

variable "vpc_id" {
  description = "Bastion을 배치할 VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Bastion 배치할 퍼블릭 서브넷 ID"
  type        = string
}

variable "my_ip" {
  description = "SSH 허용할 내 공인 IP (x.x.x.x/32 형식)"
  type        = string
}

variable "key_name" {
  description = "AWS 콘솔에서 발급한 EC2 Key Pair 이름"
  type        = string
  default     = "tf-key"
}

variable "instance_type" {
  description = "Bastion EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}
