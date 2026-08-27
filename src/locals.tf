locals {
  ssh_public_key = file("${var.ssh_public_key_path}")
  
  common_metadata = {
    serial-port-enable = "true"
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
    # user-data = <<-EOF
    #   #cloud-config
    #   packages:
    #     - python3
    #     - python3-dnf 
    #   runcmd:
    #     - alternatives --install /usr/bin/python python /usr/bin/python3 2
    #     - python --version
    # EOF
  }
}