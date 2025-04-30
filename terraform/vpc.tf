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
    count = length(var.az_list)
    tags = {
      Name = "Sftp-eip-${count.index}"
    }




  
}