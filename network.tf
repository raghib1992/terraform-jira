resource "aws_security_group" "alb" {
  name = "${var.name_prefix}-alb-sg"
  vpc_id = aws_vpc.mumbai-vpc.id

#  ingress {
#    from_port = -1
#    to_port = -1
#    protocol = "icmp"
#    cidr_blocks = [ "0.0.0.0/0" ]
#  }
#
#  ingress {
#    from_port = 443
#    to_port = 443
#    protocol = "tcp"
#    cidr_blocks = [ "0.0.0.0/0" ]
#    ipv6_cidr_blocks = [ "::/0" ]
#  }
#
#  ingress {
#    from_port = 80
#    to_port = 80
#    protocol = "tcp"
#    cidr_blocks = [ "0.0.0.0/0" ]
#    ipv6_cidr_blocks = [ "::/0" ]
#  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = local.common_tags
}

resource "aws_security_group" "mumbai-rds-sg" {
  name = "${var.name_prefix}-rds-sg"
  vpc_id = aws_vpc.mumbai-vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [
      aws_security_group.mumbai-sg.id,
      aws_security_group.mumbai-ec2-sg.id,
      aws_security_group.mumbai-lambda-db-provisioner-sg.id,
      aws_security_group.mumbai-lambda-saas-db-dump-sg.id
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = local.common_tags
}

resource "aws_security_group" "mumbai-sg" {
  name = "${var.name_prefix}-sg"
  vpc_id = aws_vpc.mumbai-vpc.id
  
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = [ aws_security_group.alb.id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = local.common_tags
}

resource "aws_security_group" "mumbai-lambda-saas-db-dump-sg" {
  name = "${var.name_prefix}-lambda-saas-db-dump-sg"
  vpc_id = aws_vpc.mumbai-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = local.common_tags
}

resource "aws_vpc" "mumbai-vpc" {
  cidr_block = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-vpc"
           }
  )
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.mumbai-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = var.private_subnet_cidrs[0]
  ipv6_cidr_block = cidrsubnet(aws_vpc.mumbai-vpc.ipv6_cidr_block,8,0)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[0]}"
           }
  )
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.mumbai-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = var.private_subnet_cidrs[1]
  ipv6_cidr_block = cidrsubnet(aws_vpc.mumbai-vpc.ipv6_cidr_block,8,1)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[1]}"
           }
  )
}

resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.mumbai-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = var.public_subnet_cidrs[0]
  ipv6_cidr_block = cidrsubnet(aws_vpc.mumbai-vpc.ipv6_cidr_block,8,2)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-public-${data.aws_availability_zones.available.names[0]}"
           }
  )
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.mumbai-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = var.public_subnet_cidrs[1]
  ipv6_cidr_block = cidrsubnet(aws_vpc.mumbai-vpc.ipv6_cidr_block,8,3)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-public-${data.aws_availability_zones.available.names[1]}"
           }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mumbai-vpc.id
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-gw"
           }
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.mumbai-vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.private.id]
}

#resource "aws_vpc_endpoint" "ecs-agent" {
#  vpc_endpoint_type = "Interface"
#  vpc_id = "${aws_vpc.mumbai-vpc.id}"
#  service_name = "com.amazonaws.${var.region}.ecs-agent"
#  route_table_ids = ["${aws_route_tables.private.id}"}
#  security_group_ids = [ "${aws_security_group.mumbai-ecs-endpoint-sg.id}" ]
#}
#
#resource "aws_vpc_endpoint" "ecs-telemetry" {
#  vpc_endpoint_type = "Interface"
#  vpc_id = "${aws_vpc.mumbai-vpc.id}"
#  service_name = "com.amazonaws.${var.region}.ecs-telemetry"
#  route_table_ids = ["${aws_route_tables.private.id}"}
#  security_group_ids = ["${aws_security_group.mumbai-ecs-endpoint-sg.id}"]
#}
#
#resource "aws_vpc_endpoint" "ecs" {
#  vpc_id = "${aws_vpc.mumbai-vpc.id}"
#  service_name = "com.amazonaws.${var.region}.ecs"
#  vpc_endpoint_type = "Interface"
#  route_table_ids = ["${aws_route_tables.private.id}"}
#  security_group_ids = ["${aws_security_group.mumbai-ecs-endpoint-sg.id}"]
#}

resource "aws_default_route_table" "default-route" {
  default_route_table_id = aws_vpc.mumbai-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  dynamic "route" {
    for_each = distinct(flatten([
      for customer_gateway in values(var.ipsec_vpn_map):
        customer_gateway.remote_private_subnet_cidrs
    ]))
    content {
      cidr_block = route.value
      gateway_id = aws_vpn_gateway.vpn_gw[0].id
    }
  }

  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-route"
           }
  )
}

#resource "aws_eip" "nat-eip" {
#  vpc = true
#  tags = {
#    Name = "${var.name_prefix}-eip"
#    sc_purpose = "saas"
#    sc_customer = "${var.name_prefix}"
#  }
#}

#resource "aws_nat_gateway" "nat-gw" {
#  allocation_id = "${aws_eip.nat-eip.id}"
#  subnet_id = "${aws_subnet.public_0.id}"
#  tags = {
#    Name = "${var.name_prefix}-private-route"
#    sc_purpose = "saas"
#    sc_customer = "${var.name_prefix}"
#  }
#}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.mumbai-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  dynamic "route" {
    for_each = distinct(flatten([
      for customer_gateway in values(var.ipsec_vpn_map):
        customer_gateway.remote_private_subnet_cidrs
    ]))
    content {
      cidr_block = route.value
      gateway_id = aws_vpn_gateway.vpn_gw[0].id
    }
  }

  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-private-route"
           }
  )
}

resource "aws_route_table_association" "private_0" {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "instance-eip" {
  count = var.eipcount
  vpc      = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-eip"
           }
  )
}

resource "aws_eip" "nlb-eip" {
  count = 2
  vpc   = true
  tags = merge(
           local.common_tags,
           {
             Name = "${var.name_prefix}-nlb-eip"
           }
  )
}
