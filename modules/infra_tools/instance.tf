resource "oci_core_instance" "public_server" {
  compartment_id = data.oci_identity_compartment.vpn.id
  availability_domain = data.oci_identity_availability_domains.azs.availability_domains[0].name

  display_name = "public-server"
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(data.template_file.cloud_config.rendered)
  }
  create_vnic_details {
    subnet_id = data.oci_core_subnet.public.id
    nsg_ids = [
      oci_core_network_security_group.vpn.id
    ]
  }

  shape = var.node_shape
  shape_config {
    ocpus = var.shape_config.ocpus
    memory_in_gbs = var.shape_config.memory_in_gbs
  }
  source_details {
    source_id   = data.oci_core_images.vpn.images[0].id
    source_type = "image"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "oci_core_images" "vpn" {
  compartment_id = data.oci_identity_compartment.vpn.id
  shape = var.node_shape
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"
}