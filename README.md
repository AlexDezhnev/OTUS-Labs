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

>systemctl status logmonitor.timer

>sudo journalctl -u logmonitor.service

### 2. Переписать spawn-fcgi на unit-файл 

Тут все довольно просто, главное загрузить нужные зависимости :)
Скрипт install.sh копирует в систему /etc/systemd/system/spawn-fcgi.service, правит конфиг /etc/sysconfig/spawn-fcgi и запускает сам сервис.

### Проверка:

> systemctl status spawn-fcgi

### 3. Запуск нескольких экземпляров httpd

Скрипт install.sh копирует в систему unit-файл /etc/systemd/system/httpd@.service
Он, в свою очередь, при запуске использует конфиг /etc/sysconfig/httpd{1,2} для запуска экземпляра Apache с другим портом (8000 и 8001) и PID 

### Проверка
> systemctl status httpd@httpd1.service

> systemctl status httpd@httpd2.service

Заодно можно ткнуть curl'ом
> curl localhost:8000

> curl localhost:8001