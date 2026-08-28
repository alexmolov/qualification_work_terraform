# Дипломная работа. Поднятие инфраструктуры с помощью terraform и ansible.

Репозиторий для автоматического создания и настрйоки VM для выполнения дипломоной работы. С помощью S3 можно получить доступ к terraform.tfstate студента и управлять продовой VM

### Предварительные требования
- **Terraform** версии 1.16.0
- **Ansible Core** версии 2.16.3

## Конфигурация

### 1. Инициализация проекта:
```
terraform init 
```
1.1 Для подключению к yc студента используйте следующий код. ACCESS_KEY и SECRET_KEY находятся в сопроводительном сообщении к дипломной работе
```
terraform init -reconfigure \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="access_key=ACCESS_KEY" \
  -backend-config="secret_key=SECRET_KEY"
```
### 2. Для хранения чувствительных данных создайте файл с переменными
```
cp personal.auto.tfvars.example personal.auto.tfvars
```

### 3. Файл personal.auto.tfvars автоматически загружается Terraform при выполнении команд. Заполните значения переменных. Для работы с YC студента внесите значения переменных из сопроводительного сообщения к дипломной работе
```
#Id облака yc
cloud_id = ""

#Id каталога yc 
folder_id = ""

#Cтатический ip адрес для VM
static_ip = ""

#Путь к публичной части ssh ключа доступа к VM
ssh_public_key_path=""

#Путь приватной части ssh ключа доступа к VM
ssh_private_key_path=""

#Путь к файлу авторизации сервисного аккаунта YC. Указывать нужно полный путь к файлу (не относительный)
service_account_key_path=""
```

### 4. Запуск конфигурации
```
terraform apply 
```

### 5. Удалить созданные конфигурацией ресурсы
```
terraform destroy
```


## Ansible

Terraform запускает ansible код для настройки VM. Ansbile добавлен в репозиторий в качестве сабмодуля. Подробное описание его работы назодится [по ссылке](https://github.com/alexmolov/qualification_work_ansible).