terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
        }
    }
    required_version = "~>1.13.0"

    backend "s3" {
        bucket         = "qualification-work-s3-bucket"
    #    key            = "terraform.tfstate"   
        region         = "ru-central1"               
        endpoint       = "https://storage.yandexcloud.net"   
    #    access_key     = ""      
    #    secret_key     = ""
        skip_region_validation      = true
        skip_credentials_validation = true
        skip_metadata_api_check     = true
        skip_requesting_account_id  = true 
        use_path_style              = true  
    }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}