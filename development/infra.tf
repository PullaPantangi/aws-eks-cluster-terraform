module "dev_vpc_1" {
  source                = "../mod/compute"
  vpc_cidr              = "10.1.0.0/16"
  vpc_name              = "dev-platinum-vpc"
  platinum-aws-igw-name = "dev-platinum-igw"
  pub_subnet_cidr       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  az                    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  pub_subnet_name       = "dev-platinum-pub-subnet"
  pvt_subent_cidr       = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  pvt_subnet_name       = "dev-platinum-pvt-subnet"
  igw_route             = "0.0.0.0/0"
  pub_RT_name           = "dev-platinum-pub-RT"
  pvt_RT_name           = "dev-platinum-pvt-RT"
}

module "dev_sg_1" {
  source    = "../mod/sg"
  vpc_id    = module.dev_vpc_1.vpc_id
  ports_in  = [80, 443, 22]
  igw_route = module.dev_vpc_1.igw_route
}

module "dev_ec2_1" {
  source          = "../mod/ec2"
  pub_subnet_cidr = module.dev_vpc_1.pub_subnet_cidr
  ami = {
    us-east-1 = "ami-0150ccaf51ab55a51"
  }
  instance_type = "t2.micro"
  key_name      = "test"
  region        = "us-east-1"
  sg_id         = module.dev_sg_1.sg_id
  pub_sub       = module.dev_vpc_1.pub_sub
  az            = module.dev_vpc_1.a_zone
  comman_tags   = module.dev_vpc_1.local_tags
  Env           = "dev"
  key_path      = "C:/Users/raoli/.ssh/id_rsa"
}
module "dev_alb_1" {
  source       = "../mod/alb"
  alb_name     = "dev-ui-alb"
  sg_id        = module.dev_sg_1.sg_id
  sub_id       = module.dev_vpc_1.pub_sub
  vpc_id       = module.dev_vpc_1.vpc_id
  inttance_id  = module.dev_ec2_1.instance_list
  pub_instance = module.dev_ec2_1.instance_list
}
module "iam_iam-policy" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.59.0"
  create_policy = true
  name          = "dev-iam-policy"
  path          = "/"
  description   = "IAM policy for dev environment"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      }
    ]
  })
  tags = {
    Environment = "dev"
  }
}
