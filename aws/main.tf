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

  records = [aws_instance.broker[count.index].public_ip]
}

resource "aws_route53_record" "zk_record" {
  count   = length(aws_instance.zk)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.zk[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.zk[count.index].public_ip]
}

resource "aws_route53_record" "sr_record" {
  count   = length(aws_instance.sr)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.sr[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.sr[count.index].public_ip]
}

resource "aws_route53_record" "kc_record" {
  count   = length(aws_instance.kc)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.kc[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.kc[count.index].public_ip]
}

resource "aws_route53_record" "cc_record" {
  count   = length(aws_instance.cc)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.cc[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.cc[count.index].public_ip]
}

resource "aws_route53_record" "connect_record" {
  count   = length(aws_instance.connect)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", aws_instance.connect[count.index].tags.SubDomain, var.aws_zone)
  type    = "A"
  ttl     = "300"

  records = [aws_instance.connect[count.index].public_ip]
}

resource "aws_instance" "zk" {
  ami                    = var.os_image_name 
  instance_type          = var.zk_machine_type
  count                  = var.zookeeper_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name      = "${var.resource_name_prefix}-zk-${count.index}"
    DnsName   = "zk-${count.index}.${var.aws_zone}"
    SubDomain = "zk-${count.index}"
    DN        = "zk-${count.index}"
  }
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
      FileSystem = "/mnt/disks/broker-disk"
    }
  }

  tags = {
    Name      = "${var.resource_name_prefix}-broker-${count.index}"
    DnsName   = "broker-${count.index}.${var.aws_zone}"
    SubDomain = "broker-${count.index}"
    DN        = "broker"
  }
}

resource "aws_instance" "sr" {
  ami                    = var.os_image_name 
  instance_type          = var.registry_machine_type
  count                  = var.registry_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name      = "${var.resource_name_prefix}-sr-${count.index}"
    DnsName   = "sr-${count.index}.${var.aws_zone}"
    SubDomain = "sr-${count.index}"
    DN        = "sr-${count.index}"
  }
}

resource "aws_instance" "kc" {
  ami                    = var.os_image_name 
  instance_type          = var.ksqldb_machine_type
  count                  = var.ksqldb_count
  key_name               = data.aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [data.aws_security_group.security-group.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name      = "${var.resource_name_prefix}-kc-${count.index}"
    DnsName   = "kc-${count.index}.${var.aws_zone}"
    SubDomain = "kc-${count.index}"
    DN        = "kc-${count.index}"
  }
}

resource "aws_instance" "cc" {
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
      FileSystem = "/mnt/disks/ccc-disk"
    }
  }

  tags = {
    Name      = "${var.resource_name_prefix}-cc-${count.index}"
    DnsName   = "cc-${count.index}.${var.aws_zone}"
    SubDomain = "cc-${count.index}"
    DN        = "cc-${count.index}"
  }
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
    for instance in setunion(aws_instance.cc, aws_instance.kc, aws_instance.sr, aws_instance.broker, aws_instance.zk) :
    format("%s#%s#%s#%s", instance.tags.DnsName, instance.private_dns, instance.private_ip, instance.tags.DN)
  ])
}