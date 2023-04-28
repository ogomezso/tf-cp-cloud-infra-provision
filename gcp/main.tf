provider "google" {
  project = var.gcp_project_name
  region  = var.gcp_region
}

data "google_compute_network" "net" {
  name = var.gcp_vpc_name
}

data "google_compute_subnetwork" "subnet" {
  name = var.gcp_subnet_name
}

data "google_compute_zones" "available" {
}

resource "google_compute_firewall" "egress_all" {
  name      = "${var.resource_name_prefix}-egressall"
  network   = data.google_compute_network.net.name
  direction = "EGRESS"

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "ingress_internal" {
  name    = "${var.resource_name_prefix}-ansible-ingressinternal"
  network = data.google_compute_network.net.name

  allow {
    protocol = "tcp"
    ports    = [
      # To be adapted depending on the chosen port of the CP platform
      "8081", "9092", "2181", "2182", "9091", "9092", "8090", "8082", "8083", "8088", "9021", "8090", "80"
    ]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.cidr_range]
}

# Can be removed if a jumphost is used
resource "google_compute_firewall" "ingress_workstation" {
  name    = "${var.resource_name_prefix}-ansible-ingressworkstation"
  network = data.google_compute_network.net.name

  allow {
    protocol = "tcp"
    ports    = [
      # To be adapted depending on the chosen port of the CP platform
      "8081", "9092", "22", "2181", "2182", "9091", "9092", "9093", "8090", "8082", "8083", "8088", "9021", "8090", "80"
    ]
  }

  source_ranges = var.ingress_workstation_source_range
}

resource "google_compute_disk" "broker_disks" {
  count = var.broker_count
  name  = "${var.resource_name_prefix}-broker-${count.index}-disk"
  type  = var.broker_disk_type
  size  = var.broker_disk_size

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  lifecycle {
    # Set to true if you need to keep kafka broker log (segments/data)
    prevent_destroy = false
  }
}

resource "google_compute_instance" "brokers" {
  count        = var.broker_count
  name         = "${var.resource_name_prefix}-broker-${count.index}"
  machine_type = var.broker_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "broker"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.broker_cidr_prefix}${count.index}"
    access_config {
    }
  }
  attached_disk {
    source = google_compute_disk.broker_disks[count.index].id
  }

  metadata_startup_script = file("${path.module}/init-attached-disk.sh")
}

resource "google_compute_instance" "zookeepers" {
  count        = var.zookeeper_count
  name         = "${var.resource_name_prefix}-zookeeper-${count.index}"
  machine_type = var.zk_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "zookeeper"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.zk_cidr_prefix}${count.index}"
    access_config {
    }
  }
}

resource "google_compute_instance" "registries" {
  count        = var.registry_count
  name         = "${var.resource_name_prefix}-registry-${count.index}"
  machine_type = var.registry_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "registry"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.registry_cidr_prefix}${count.index}"
    access_config {
    }
  }
}

resource "google_compute_disk" "ccc_disks" {
  count = var.ccc_count
  name  = "${var.resource_name_prefix}-ccc-${count.index}-disk"
  type  = var.ccc_disk_type
  size  = var.ccc_disk_size

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  lifecycle {
    # Set to true if you need to keep kafka broker log (segments/data)
    prevent_destroy = false
  }
}

resource "google_compute_instance" "ccc" {
  count        = var.ccc_count
  name         = "${var.resource_name_prefix}-ccc-${count.index}"
  machine_type = var.ccc_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "ccc"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.ccc_cidr_prefix}${count.index}"
    access_config {
    }
  }
  attached_disk {
    source = google_compute_disk.ccc_disks[count.index].id
  }

  metadata_startup_script = file("${path.module}/init-attached-disk.sh")
}

resource "google_compute_instance" "connects" {
  count        = var.connect_count
  name         = "${var.resource_name_prefix}-connect-${count.index}"
  machine_type = var.connect_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "connect"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.connect_cidr_prefix}${count.index}"
    access_config {
    }
  }
}

resource "google_compute_instance" "ksqldbs" {
  count        = var.ksqldb_count
  name         = "${var.resource_name_prefix}-ksqldb-${count.index}"
  machine_type = var.ksqldb_machine_type

  zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  tags = ["kafka-cluster", "ksqldb"]

  boot_disk {
    initialize_params {
      image = var.os_image_name
    }
  }
  metadata = {
    ssh-keys = "${var.resource_name_prefix}:${file(var.pub_key_path)}"
  }
  network_interface {
    network    = data.google_compute_network.net.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    network_ip = "${var.ksqldb_cidr_prefix}${count.index}"
    access_config {
    }
  }
}