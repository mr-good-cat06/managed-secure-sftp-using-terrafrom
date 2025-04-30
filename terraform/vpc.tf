resource "aws_vpc" "this" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "Sftp-vpc"
        
        }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.this.id
    
    tags = {
        Name = "Sftp-igw"
    }
}

resource "aws_subnet" "public" {
    count = length(var.az_list)
    vpc_id = aws/vpc.this.id
    cidr_block = "10.0.${count.index}.0/24"
    availability_zone = var.az_list[count.index]

    tags = {
        Name = "Sftp-public-subnet-${count.index}"
    }
}

resource "aws_route_table" "to_igw" {
    count = length(var.az_list)
    vpc_id = aws_vpc.this.id

    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "Sftp-route-table-${count.index}"
    }
}

resource "aws_route_table_association" "this" {
    count = length(var.az_list)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.to_igw[count.index].id
  
}

resource "aws_eip" "this" {
    depends_on = [ aws_internet_gateway.igw ]
    count = length(var.az_list)
    tags = {
      Name = "Sftp-eip-${count.index}"
    }
}

resource "aws_security_group" "sftp_sg" {
    name = "sftp-sg"
    description = "Allow SSH and SFTP"
    vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = aws_security_group.sftp_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port = 22
    to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
    security_group_id = aws_security_group.sftp_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}