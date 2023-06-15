provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = var.aws_credential_files
}

data "aws_key_pair" "my_key_pair" {
  key_name = var.aws_key_pair
}

data "aws_security_group" "security-group" {
  id = var.aws_security_group
}

data "aws_route53_zone" "zone" {
  name = var.aws_zone
  private_zone = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route53_record" "broker_record" {
  count   = length(aws_instance.broker)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.broker[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.broker[count.index].private_ip]
}

resource "aws_route53_record" "zookeeper_record" {
  count   = length(aws_instance.zookeeper)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.zookeeper[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.zookeeper[count.index].private_ip]
}

resource "aws_route53_record" "registry_record" {
  count   = length(aws_instance.registry)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.registry[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.registry[count.index].private_ip]
}

resource "aws_route53_record" "ksqldb_record" {
  count   = length(aws_instance.ksqldb)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.ksqldb[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.ksqldb[count.index].private_ip]
}

resource "aws_route53_record" "ccc_record" {
  count   = length(aws_instance.ccc)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.ccc[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.ccc[count.index].private_ip]
}

resource "aws_route53_record" "connect_record" {
  count   = length(aws_instance.connect)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.connect[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.connect[count.index].private_ip]
}

resource "aws_instance" "zookeeper" {
  ami                    = var.os_image_name
  instance_type          = var.zookeeper_machine_type
  count                  = var.zookeeper_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  root_block_device {
    volume_size = 20
  }

  ebs_block_device {
    device_name = "/dev/xvdba"
    volume_type = var.broker_disk_type
    volume_size = var.broker_disk_size

    tags = {
      FileSystem = "/mnt/disks/attached-disk"
    }
  }

  tags = {
    Name      = "${var.resource_name_prefix}-zookeeper-${count.index}"
    DnsName   = "zookeeper-${count.index}.${var.aws_zone}"
    SubDomain = "zookeeper-${count.index}"
    DN        = "zookeeper-${count.index}"
  }

  user_data = file("${path.module}/init-attached-disk.sh")
}

resource "aws_instance" "broker" {
  ami                    = var.os_image_name
  instance_type          = var.broker_machine_type
  count                  = var.broker_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  root_block_device {
    volume_size = 20
  }

  ebs_block_device {
    device_name = "/dev/xvdba"
    volume_type = var.broker_disk_type
    volume_size = var.broker_disk_size

    tags = {
      FileSystem = "/mnt/disks/attached-disk"
    }
  }

  tags = {
    Name      = "${var.resource_name_prefix}-broker-${count.index}"
    DnsName   = "broker-${count.index}.${var.aws_zone}"
    SubDomain = "broker-${count.index}"
    DN        = "broker"
  }

  user_data = file("${path.module}/init-attached-disk.sh")
}

resource "aws_instance" "registry" {
  ami                    = var.os_image_name
  instance_type          = var.registry_machine_type
  count                  = var.registry_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name      = "${var.resource_name_prefix}-registry-${count.index}"
    DnsName   = "registry-${count.index}.${var.aws_zone}"
    SubDomain = "registry-${count.index}"
    DN        = "registry-${count.index}"
  }
}

resource "aws_instance" "ksqldb" {
  ami                    = var.os_image_name
  instance_type          = var.ksqldb_machine_type
  count                  = var.ksqldb_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name      = "${var.resource_name_prefix}-ksqldb-${count.index}"
    DnsName   = "ksqldb-${count.index}.${var.aws_zone}"
    SubDomain = "ksqldb-${count.index}"
    DN        = "ksqldb-${count.index}"
  }
}

resource "aws_instance" "ccc" {
  ami                    = var.os_image_name
  instance_type          = var.ccc_machine_type
  count                  = var.ccc_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  root_block_device {
    volume_size = 20
  }

  ebs_block_device {
    device_name = "/dev/xvdba"
    volume_type = var.ccc_disk_type
    volume_size = var.ccc_disk_size

    tags = {
      FileSystem = "/mnt/disks/attached-disk"
    }
  }

  tags = {
    Name      = "${var.resource_name_prefix}-ccc-${count.index}"
    DnsName   = "ccc-${count.index}.${var.aws_zone}"
    SubDomain = "ccc-${count.index}"
    DN        = "ccc-${count.index}"
  }

  user_data = file("${path.module}/init-attached-disk.sh")
}

resource "aws_instance" "connect" {
  ami                    = var.os_image_name
  instance_type          = "t2.large"
  count                  = var.connect_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name      = "${var.resource_name_prefix}-connect-${count.index}"
    DnsName   = "connect-${count.index}.${var.aws_zone}"
    SubDomain = "connect-${count.index}"
    DN        = "connect-${count.index}"
  }
}

output "aws_nameservers" {
  value = data.aws_route53_zone.zone.name_servers
}


output "all_hosts_join" {
  value = join("\n", [
    for instance in setunion(aws_instance.ccc, aws_instance.ksqldb, aws_instance.registry, aws_instance.broker, aws_instance.zookeeper) :
    format("%s#%s#%s#%s", instance.tags.DnsName, instance.private_dns, instance.private_ip, instance.tags.DN)
  ])
}