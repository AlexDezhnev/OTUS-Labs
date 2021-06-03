# Занятие 13. Автоматизация администрирования. Ansible-1

### Задание
```
Первые шаги с Ansible
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible

Домашнее задание считается принятым, если:
- предоставлен Vagrantfile и готовый playbook/роль ( инструкция по запуску стенда, если посчитаете необходимым )
- после запуска стенда nginx доступен на порту 8080
- при написании playbook/роли соблюдены перечисленные в задании условия

Критерии оценки:
Статус "Принято" ставится, если создан playbook.
Дополнительно можно написать роль.
```
### Решение
Плейбук [nginx.yml](nginx.yml) использует в работе шаблон [nginx.conf.j2](templates/nginx.conf.j2)
- Устанавливаем в системе [Ansible](https://docs.ansible.com/ansible/2.7/installation_guide/intro_installation.html)
- Поднимаем виртуалку без запуска плейбука ansible
> vagrant up --no-provision

- Проверяем присвоенный виртуальной машине порт
>vagrant ssh-config
```
Host nginx
  HostName 127.0.0.1
  User vagrant
  Port 2201
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
```
- Если присвоенный порт отличается от порта по умолчанию (2222), редактируем файл конфигурации:
>vi hosts
- Меняем значение параметра ansible_port=
```
[web]
nginx ansible_host=127.0.0.1 ansible_port=2201 ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
```
- Запускаем плейбук ansible
>vagrant provision
```
    nginx: Running ansible-playbook...

PLAY [Install and configure NGINX] *********************************************

TASK [Gathering Facts] *********************************************************
ok: [nginx]

TASK [Install EPEL Repo package from standart repo] ****************************
changed: [nginx]

TASK [Install NGINX package from epel-repo] ************************************
changed: [nginx]

TASK [Create NGINX config file from template] **********************************
changed: [nginx]

RUNNING HANDLER [restart nginx] ************************************************
changed: [nginx]

RUNNING HANDLER [reload nginx] *************************************************
changed: [nginx]

PLAY RECAP *********************************************************************
nginx                      : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
#### Подключаемся к серверу и проверяем результат
>vagrant ssh
- Проверяем статус nginx
>systemctl status nginx
```
systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-06-03 07:23:37 UTC; 37s ago
  Process: 4333 ExecReload=/bin/kill -s HUP $MAINPID (code=exited, status=0/SUCCESS)
  Process: 4243 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 4241 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 4239 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 4245 (nginx)
   CGroup: /system.slice/nginx.service
           ├─4245 nginx: master process /usr/sbin/nginx
           └─4334 nginx: worker process
```
- Проверяем работу nginx на порту 8080
>curl localhost:8080

#### Завершение работы
>exit

>vagrant destroy -f