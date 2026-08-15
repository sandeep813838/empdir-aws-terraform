variable "project_name" { type = string }
variable "environment" { type = string }
variable "ami_id" { type = string }
variable "key_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "web_sg_id" { type = string }
variable "alb_sg_id" { type = string }
variable "web_instance_profile_name" { type = string }
variable "min_size" {
  type    = number
  default = 1
}
variable "max_size" {
  type    = number
  default = 2
}
variable "desired_capacity" {
  type    = number
  default = 2
}