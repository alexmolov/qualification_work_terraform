variable "vm_platform_id" {
  type        = string
  default     = "standard-v2"
}

variable "vm_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 4
    memory        = 4
    core_fraction = 50
  }
}

#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

#создаем подсеть
resource "yandex_vpc_subnet" "develop" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

variable "vm_preemptible" {
  type        = bool
  default     = true
}

variable "vm_nat" {
  type        = bool
  default     = true
}

variable "vm_image_family" {
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "static_ip" {
  type        = string
  description = "Существующий статический IP адрес для ВМ"
}

variable "use_static_ip" {
  type        = bool
  description = "Использовать существующие статические IP вместо создания новых"
  default     = true
}

data "yandex_compute_image" "ubuntu_count" {
  family = var.vm_image_family
}


resource "yandex_compute_instance" "web-vm" {
  count = 1
  name        = "qualification-work-main-vm"
  platform_id = var.vm_platform_id

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = var.vm_resources.core_fraction
  }

    boot_disk {
        initialize_params {
        image_id = data.yandex_compute_image.ubuntu_count.image_id
        size     = var.common_boot_disk_config.size
        }
    }
  
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.vm_nat
    nat_ip_address = var.use_static_ip ? var.static_ip : null
    # security_group_ids = [yandex_vpc_security_group.example.id]
  }

  allow_stopping_for_update = true
  metadata = local.common_metadata
}

resource "null_resource" "install_python" {
  depends_on = [yandex_compute_instance.web-vm]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = yandex_compute_instance.web-vm[0].network_interface.0.nat_ip_address
    private_key = file("${var.ssh_private_key_path}")
  }

  provisioner "remote-exec" {
    inline = [
      # Отключаем needrestart
      "sudo sed -i 's/#$nrconf{restart} = .*/$nrconf{restart} = \"a\";/g' /etc/needrestart/needrestart.conf 2>/dev/null || true",

      # Обновляем пакеты
      "sudo apt update -y",
      "sudo apt upgrade -y",
      
      # Устанавливаем Python
      "sudo apt install -y python3 python3-pip",
          
      # Проверяем установку
      "python3 --version",
    ]
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && ansible-galaxy install -r requirements.yml"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/ansible && ansible-playbook -i ../inventory.ini site.yml --private-key ${var.ssh_private_key_path}"
  }
}