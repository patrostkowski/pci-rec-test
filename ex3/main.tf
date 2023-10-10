################################
### Config
################################

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "openstack" {
  user_name   = "user-CH4pKESUJZgT"
  tenant_name = "3245829148481055"
  password    = "<PASSWORD>"
  auth_url    = "https://auth.cloud.ovh.net/v3"
  region      = "GRA7"
}

################################
### Variables
################################

locals {
  username = "user-CH4pKESUJZgT"
}

variable "public_network_id" {
  type    = string
  default = "393d06cc-a82c-4dc4-a576-c79e8dd67ba3"
}

variable "subnet_cidr" {
  type    = string
  default = "192.168.200.0/24"
}

variable "dns_nameservers" {
  type    = list(string)
  default = ["213.186.33.99"]
}

variable "security_group_ids" {
  type    = list(string)
  default = ["378188de-3b05-4d4b-8107-20e0e8ee7ee9"]
}

variable "compute_image_id" {
  type    = string
  default = "929ae811-f25b-48ef-a9bd-9bd875377d65"
}

variable "compute_flavor_id" {
  type    = string
  default = "199060ac-6dde-435a-acab-78456ac337a7"
}

variable "external_network_name" {
  type    = string
  default = "Ext-Net"
}

################################
### Network
################################

data "openstack_networking_network_v2" "this" {
  name = var.external_network_name
}

resource "openstack_networking_router_v2" "this" {
  name                = "${local.username}-router"
  external_network_id = var.public_network_id
}

resource "openstack_networking_network_v2" "this" {
  name = "${local.username}-network"
}

resource "openstack_networking_subnet_v2" "this" {
  name            = "${local.username}-subnet"
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.subnet_cidr
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_router_interface_v2" "this" {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}

resource "openstack_networking_floatingip_v2" "this" {
  pool = data.openstack_networking_network_v2.this.name
}

resource "openstack_compute_floatingip_associate_v2" "this" {
  floating_ip = openstack_networking_floatingip_v2.this.address
  instance_id = openstack_compute_instance_v2.this.id
  fixed_ip    = openstack_compute_instance_v2.this.network[0].fixed_ip_v4
}

################################
### Compute
################################

resource "openstack_networking_port_v2" "this" {
  name               = "${local.username}-port"
  network_id         = openstack_networking_network_v2.this.id
  admin_state_up     = true
  security_group_ids = var.security_group_ids
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.this.id
  }
}

resource "openstack_compute_keypair_v2" "this" {
  name = "${local.username}-key-pair"
}

resource "openstack_compute_instance_v2" "this" {
  name      = "${local.username}-vm"
  image_id  = var.compute_image_id
  flavor_id = var.compute_flavor_id
  key_pair  = openstack_compute_keypair_v2.this.name

  network {
    uuid = openstack_networking_network_v2.this.id
    port = openstack_networking_port_v2.this.id
  }
}

################################
### Outputs
################################

output "public_ssh_key" {
  value = openstack_compute_keypair_v2.this.public_key
}

output "private_ssh_key" {
  value     = openstack_compute_keypair_v2.this.private_key
  sensitive = true
}

output "public_ip" {
  value = openstack_networking_floatingip_v2.this.address
}
