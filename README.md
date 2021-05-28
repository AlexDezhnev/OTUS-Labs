# OTUS. Занятие 8 - Инициализация системы. Systemd. 

Задание
```
Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);
- Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi);
- Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами; 
- 4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.
```

## ЗАПУСК

> vagrant up

> vagrant ssh

### 1. Сервис logmonitor

Скрипт install.sh копирует в систему сервис logmonitor и его настройки, хранящиеся в файле /etc/sysconfig/logmonitor, создает симлинк и запускает сервис

Каждые 30 секунд сервис запускает скрипт /usr/bin/logmonitor.sh, который проверяет наличие ключевого слова в заданном в настройках файле (по умолчанию файл /vagrant/Vagrantfile, ключевое слово config) и делает запись в журнале

### Проверка:
> systemctl status logmonitor.service
```
● logmonitor.service - Key word monitor script
   Loaded: loaded (/etc/systemd/system/logmonitor.service; static; vendor preset: disabled)
   Active: inactive (dead) since Fri 2021-05-28 09:21:39 UTC; 9s ago
  Process: 12887 ExecStart=/usr/bin/logmonitor.sh (code=exited, status=0/SUCCESS)
 Main PID: 12887 (code=exited, status=0/SUCCESS)
```
> systemctl status logmonitor.timer
```
● logmonitor.timer - Start logmonitor service every 30 seconds
   Loaded: loaded (/etc/systemd/system/logmonitor.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Fri 2021-05-28 09:20:12 UTC; 2min 38s ago
```
> sudo journalctl -u logmonitor.service
```
-- Logs begin at Fri 2021-05-28 09:17:42 UTC, end at Fri 2021-05-28 09:23:04 UTC. --
May 28 09:20:35 localhost.localdomain systemd[1]: Starting Key word monitor script...
May 28 09:20:35 localhost.localdomain logmonitor.sh[12696]: Searching for a config in file /vagrant/Vagrantfile
May 28 09:20:35 localhost.localdomain logmonitor.sh[12696]: Vagrant.configure("2") do |config|
May 28 09:20:35 localhost.localdomain logmonitor.sh[12696]: config.vm.box = "centos/7"
May 28 09:20:35 localhost.localdomain logmonitor.sh[12696]: config.vm.box_check_update = false
May 28 09:20:35 localhost.localdomain logmonitor.sh[12696]: config.vm.provision "shell", path: "provision.sh"
May 28 09:20:35 localhost.localdomain systemd[1]: Started Key word monitor script.
May 28 09:21:00 localhost.localdomain systemd[1]: Starting Key word monitor script...
May 28 09:21:00 localhost.localdomain logmonitor.sh[12885]: Searching for a config in file /vagrant/Vagrantfile
May 28 09:21:00 localhost.localdomain logmonitor.sh[12885]: Vagrant.configure("2") do |config|
May 28 09:21:00 localhost.localdomain logmonitor.sh[12885]: config.vm.box = "centos/7"
May 28 09:21:00 localhost.localdomain logmonitor.sh[12885]: config.vm.box_check_update = false
May 28 09:21:00 localhost.localdomain logmonitor.sh[12885]: config.vm.provision "shell", path: "provision.sh"
```
### 2. Переписать spawn-fcgi на unit-файл 

Тут все довольно просто, главное загрузить нужные зависимости :)
Скрипт install.sh копирует в систему /etc/systemd/system/spawn-fcgi.service, правит конфиг /etc/sysconfig/spawn-fcgi и запускает сам сервис.

### Проверка:

> systemctl status spawn-fcgi
```
● spawn-fcgi.service - Spawn fast cgi service
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Fri 2021-05-28 09:20:38 UTC; 2min 52s ago
     Docs: man:spawn-fcgi(1)
 Main PID: 12752 (code=exited, status=0/SUCCESS)
```
### 3. Запуск нескольких экземпляров httpd

Скрипт install.sh копирует в систему unit-файл /etc/systemd/system/httpd@.service
Он, в свою очередь, при запуске использует конфиг /etc/sysconfig/httpd{1,2} для запуска экземпляра Apache с другим портом (8000 и 8001) и PID 

### Проверка
> systemctl status httpd@httpd1.service
```
● httpd@httpd1.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-05-28 09:20:40 UTC; 3min 6s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 12855 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@httpd1.service
           ├─12855 /usr/sbin/httpd -DFOREGROUND
           ├─12856 /usr/sbin/httpd -DFOREGROUND
           ├─12857 /usr/sbin/httpd -DFOREGROUND
           ├─12858 /usr/sbin/httpd -DFOREGROUND
           ├─12859 /usr/sbin/httpd -DFOREGROUND
           ├─12860 /usr/sbin/httpd -DFOREGROUND
           └─12861 /usr/sbin/httpd -DFOREGROUND
```
> systemctl status httpd@httpd2.service
```
● httpd@httpd2.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-05-28 09:20:40 UTC; 3min 18s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 12875 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@httpd2.service
           ├─12875 /usr/sbin/httpd -DFOREGROUND
           ├─12876 /usr/sbin/httpd -DFOREGROUND
           ├─12877 /usr/sbin/httpd -DFOREGROUND
           ├─12878 /usr/sbin/httpd -DFOREGROUND
           ├─12879 /usr/sbin/httpd -DFOREGROUND
           ├─12880 /usr/sbin/httpd -DFOREGROUND
           └─12881 /usr/sbin/httpd -DFOREGROUND
```
Заодно можно ткнуть curl'ом
> curl localhost:8000

> curl localhost:8001

### Все
> exit
> vagrant destroy -f