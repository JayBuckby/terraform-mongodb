variable "vpc_id" {
    description = "The VPC ID in AWS"
}
variable "name" {
    description = "The name to be used for AWS tags"
}
variable "route_table_id" {
    description = "The RT ID for this module in AWS"
}
variable "cidr_block" {
    description = "The IP and Subnet for local connection"
}
variable "user_data" {
    description = "The script we use to start the instance"
}
variable "ami_id" {
    description = "The AMI ID in AWS"
}
variable "map_public_ip_on_launch" {
    description = "Providing the public IP on launch of the module"
    default = false
}
variable "ingress" {
    description = "Collection of rules to allow connections access"
    type = list
}