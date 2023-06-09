data "template_file" "init_node_sh" {
  template = file("${path.module}/scripts/init_node.sh")
  vars = {
    K8S_VERSION = var.k8s_version
    MST_FIXED_IP = local.MST_FIXED_IP
  }
}
data "template_file" "init_cluster" {
  template = file("${path.module}/scripts/init_cluster.sh")
  vars = {
    K8S_VERSION = var.k8s_version
    MST_FIXED_IP = local.MST_FIXED_IP
    K8S_TOKEN = var.k8s_token
  }
}
data "template_file" "join_cluster" {
  template = file("${path.module}/scripts/join_cluster.sh")
  vars = {
    K8S_VERSION = var.k8s_version
    MST_FIXED_IP = local.MST_FIXED_IP
    K8S_TOKEN = var.k8s_token
  }
}

data "template_file" "master_cloud_config" {
  template = <<YAML
#cloud-config
write_files:
- content: |
    ${indent(4, data.template_file.init_node_sh.rendered)}
  path: "/tmp/init-node.sh"
  owner: root:root
  permissions: '0755'
- content: |
    ${indent(4, data.template_file.init_cluster.rendered)}
  path: "/tmp/init-cluster.sh"
  owner: root:root
  permissions: '0755'
runcmd:
 - bash /tmp/init-node.sh
 - bash /tmp/init-cluster.sh
YAML

}

data "template_file" "worker_cloud_config" {
  template = <<YAML
#cloud-config
write_files:
- content: |
    ${indent(4, data.template_file.init_node_sh.rendered)}
  path: "/tmp/init-node.sh"
  owner: root:root
  permissions: '0755'
- content: |
    ${indent(4, data.template_file.join_cluster.rendered)}
  path: "/tmp/join-cluster.sh"
  owner: root:root
  permissions: '0755'
runcmd:
 - bash /tmp/init-node.sh
 - bash /tmp/join-cluster.sh
YAML
}