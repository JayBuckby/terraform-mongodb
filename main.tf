// State our provider
provider "aws" {
    region="us-west-1"
}

// Create our VPC
resource "aws_vpc" "jaybuckby-application-deployment" {
    cidr_block = "10.5.0.0/16"

    tags = {
        Name = "jaybuckby-application-deployment-vpc"
    }
}

// Create our Internet Gateway
resource "aws_internet_gateway" "jaybuckby-ig" {
    vpc_id = "${aws_vpc.jaybuckby-application-deployment.id}"

    tags = {
        Name = "jaybuckby-ig"
    }
}

// Create our route table
resource "aws_route_table" "jaybuckby-rt" {
    vpc_id = "${aws_vpc.jaybuckby-application-deployment.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.jaybuckby-ig.id}"
    }
}

// State our modules and construct them
module "db-tier" {
    name = "jaybuckby-database"
    source = "./modules/db-tier"
    vpc_id = "${aws_vpc.jaybuckby-application-deployment.id}"
    route_table_id = "${aws_vpc.jaybuckby-application-deployment.main_route_table_id}"
    cidr_block = "10.5.1.0/24"
    user_data=templatefile("./scripts/db_user_data.sh", {})
    ami_id = "ami-0d17099f9a1843ab6"
    map_public_ip_on_launch = false

    ingress = [{
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = "${module.application-tier.subnet_cidr_block}"
    }]
}


module "application-tier" {
    name = "jaybuckby-app"
    source = "./modules/application-tier"
    vpc_id = "${aws_vpc.jaybuckby-application-deployment.id}"
    route_table_id = "${aws_route_table.jaybuckby-rt.id}"
    cidr_block = "10.5.0.0/24"
    user_data=templatefile("./scripts/app_user_data.sh", { mongodb_ip = module.db-tier.private_ip })
    ami_id = "ami-0d303287a96a6816c"
    map_public_ip_on_launch = true

    ingress =[{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    },{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "81.156.197.158/32"
    },{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "3.12.164.39/32"} ]
}
