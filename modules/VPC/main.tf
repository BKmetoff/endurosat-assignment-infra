data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags       = { "Name" = format("%s", var.name) }
}

resource "aws_subnet" "public" {
  count = var.subnet_count

  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags                    = { "Name" = format("%s-public-subnet-%s", var.name, count.index) }
}

resource "aws_subnet" "private" {
  count             = var.subnet_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.vpc.id
  tags              = { "Name" = format("%s-private-subnet-%s", var.name, count.index) }
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

# allow access from the "outside world"
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = var.subnet_count
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = var.subnet_count
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.gateway[*].id, count.index)
}

resource "aws_route_table" "private" {
  count  = var.subnet_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway[*].id, count.index)
  }

  tags = { "Name" = format("%s-private-route-table-%s", var.name, count.index) }
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}


# allow incoming connections on port 80
# allow outgoing connections to everywhere
resource "aws_security_group" "lb" {
  name   = "${var.name}-alb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# attach the load balancer to all public subnets
resource "aws_lb" "lb" {
  count = length(var.environments)

  name            = "${var.name}-${var.environments[count.index]}-lb"
  subnets         = aws_subnet.public[*].id
  security_groups = [aws_security_group.lb.id]
}

# forward the traffic coming to the load balancers to ECS
resource "aws_lb_target_group" "lb_tg" {
  count = length(var.environments)

  name        = "${var.name}-${var.environments[count.index]}-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  count = length(var.environments)

  load_balancer_arn = aws_lb.lb[count.index].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_tg[count.index].id
    type             = "forward"
  }
}
