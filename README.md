# Занятие 20. Резервное копирование 

### Задание

```
- Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client
- Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
- Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB.
- Репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение
- Имя бекапа должно содержать информацию о времени снятия бекапа
- Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. 
- Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов
- Резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации.
- Написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение.
- Настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов

Запустите стенд на 30 минут. Убедитесь что резервные копии снимаются. Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа. Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.
```

В качестве основы взяты готовые роли [Borg-client](https://github.com/yurihs/ansible-role-borg-client) и [Borg-server](https://github.com/yurihs/ansible-role-borg-server)

Роли переработаны, в них добавлено:
- шифрование репозитория. Автоматизация шифрования в скрипте реализована с помощью переменной BORG_PASSPHRASE, через которую скрипт передает в borg пароль
- ротирование логов (с помощью шаблона [logrotate](/roles/borg-client/templates/logrotate.j2) создается конфигурационный файл /etc/logrotate.d/logrotate-borg)
- при запуске сервера создается второй диск емкостью 2Гб, который монтируется в /var/backup
```
[vagrant@server ~]$ lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk
`-sda1   8:1    0  40G  0 part /
sdb      8:16   0   2G  0 disk
`-sdb1   8:17   0   2G  0 part /etc/backup
```
- автоматическая инициализация репозитория в /var/backup

Borg prune хранит:
- все резервные копии за последние сутки (для проверки)
- по 1 резервной копии за последние 90 суток (3 месяца)
- по 1 резервной копии за последние 12 месяцев
- на клиенте для резервного копирования создается скрипт /usr/local/bin/borg_backup_script, который использует файл конфигурации /etc/borg_client/client_repo.conf. Логи складываются в файл /var/log/borg_client.log
- каждые 5 мин запускается скрипт резервного копирования. Проверить можно командой
>sudo crontab -u root -l

### Проверка восстановления
- ждем полчаса, проверяем 
>sudo BORG_PASSPHRASE=Borg_123456789 borg list borg@server:client_repo
```
2021-06-14_10:35:01                  Mon, 2021-06-14 10:35:02 [2c22660b0ac4c124b45677b1d6b30d17e660d1beec1ef93977af0a0141f32736]
2021-06-14_10:40:01                  Mon, 2021-06-14 10:40:02 [81b6812a918c1c587e1022c5e695edc62a743cda39530e0ef661e03a6ef3b03c]
2021-06-14_10:45:02                  Mon, 2021-06-14 10:45:03 [647ea5bbdba444a212b595e6ee54bb407ac406916d20d9b459434c6bfc4118f9]
2021-06-14_10:50:01                  Mon, 2021-06-14 10:50:02 [2fa76799dcb1214e98a951270f92dffef138f210ab372023fa839e48cb04574d]
2021-06-14_10:55:01                  Mon, 2021-06-14 10:55:03 [bd5a2805642a4c8f4cfe6519ec1f0b782f8f9e63efd684911617d5c278ef1883]
2021-06-14_11:00:02                  Mon, 2021-06-14 11:00:03 [1b31c64889d7d82ac23c1f18d724169b6b76f4a6138b3a042e6a6b54ba357a13]
```
- останавливаем backup (переименовываем скрипт)
>sudo mv /usr/local/bin/borg_backup_script /usr/local/bin/borg_backup_script_stopped
- поскольку удаление etc удалит и файл passwd, это приведет к невозможности подключиться удаленно к сервер. Поэтому сначала восстановим последний архив в домашнюю директорию пользователя root на клиенте.
>su - root

>mkdir etc
- восстанавливаем архив с сервера в локальную папку /root/etc
>sudo BORG_PASSPHRASE=Borg_123456789 borg extract borg@server:client_repo::2021-06-14_11:00:02 etc/

>ls -la etc/
```
total 1072
drwxr-xr-x. 79 root root     8192 Jun 14 11:17 .
dr-xr-x---.  8 root root      215 Jun 14 11:22 ..
-rw-r--r--.  1 root root       16 Apr 30  2020 adjtime
-rw-r--r--.  1 root root     1529 Apr  1  2020 aliases
-rw-r--r--.  1 root root    12288 Jun 14 11:15 aliases.db
drwxr-xr-x.  2 root root     4096 Apr 30  2020 alternatives
-rw-------.  1 root root      541 Aug  8  2019 anacrontab
drwxr-x---.  3 root root       43 Apr 30  2020 audisp
drwxr-x---.  3 root root       83 Jun 14 11:15 audit
drwxr-xr-x.  2 root root       68 Apr 30  2020 bash_completion.d
-rw-r--r--.  1 root root     2853 Apr  1  2020 bashrc
drwxr-xr-x.  2 root root        6 Apr  7  2020 binfmt.d
drwxr-xr-x.  2 root root       30 Jun 14 11:17 borg_client
-rw-r--r--.  1 root root       37 Apr  7  2020 centos-release
-rw-r--r--.  1 root root       51 Apr  7  2020 centos-release-upstream
drwxr-xr-x.  2 root root        6 Aug  4  2017 chkconfig.d
-rw-r--r--.  1 root root     1108 Aug  8  2019 chrony.conf
-rw-r-----.  1 root chrony    481 Aug  8  2019 chrony.keys
drwxr-xr-x.  2 root root       26 Apr 30  2020 cifs-utils
drwxr-xr-x.  2 root root       21 Apr 30  2020 cron.d
drwxr-xr-x.  2 root root       42 Apr 30  2020 cron.daily
-rw-------.  1 root root        0 Aug  8  2019 cron.deny
drwxr-xr-x.  2 root root       22 Jun  9  2014 cron.hourly
drwxr-xr-x.  2 root root        6 Jun  9  2014 cron.monthly
-rw-r--r--.  1 root root      451 Jun  9  2014 crontab
drwxr-xr-x.  2 root root        6 Jun  9  2014 cron.weekly
-rw-------.  1 root root        0 Apr 30  2020 crypttab
-rw-r--r--.  1 root root     1620 Apr  1  2020 csh.cshrc
-rw-r--r--.  1 root root     1103 Apr  1  2020 csh.login
```
- удаляем папку /etc
>rm -rf /etc
rm: cannot remove ‘/etc’: Device or resource busy

>ls -la /etc
```
total 0
drwxr-xr-x.  2 0 0   6 Jun 14 11:24 .
dr-xr-xr-x. 18 0 0 255 Jun 14 11:16 ..
```
- переносим восстановленную папку из /root/etc в /etc
>cp -r etc /
- проверяем
>ls -la /etc
```
total 1072
drwxr-xr-x. 79 root root   8192 Jun 14 11:27 .
dr-xr-xr-x. 18 root root    255 Jun 14 11:16 ..
-rw-r--r--.  1 root root     16 Jun 14 11:27 adjtime
-rw-r--r--.  1 root root   1529 Jun 14 11:27 aliases
-rw-r--r--.  1 root root  12288 Jun 14 11:27 aliases.db
drwxr-xr-x.  2 root root   4096 Jun 14 11:27 alternatives
-rw-------.  1 root root    541 Jun 14 11:27 anacrontab
drwxr-x---.  3 root root     43 Jun 14 11:27 audisp
drwxr-x---.  3 root root     83 Jun 14 11:27 audit
drwxr-xr-x.  2 root root     68 Jun 14 11:27 bash_completion.d
-rw-r--r--.  1 root root   2853 Jun 14 11:27 bashrc
drwxr-xr-x.  2 root root      6 Jun 14 11:27 binfmt.d
drwxr-xr-x.  2 root root     30 Jun 14 11:27 borg_client
-rw-r--r--.  1 root root     37 Jun 14 11:27 centos-release
-rw-r--r--.  1 root root     51 Jun 14 11:27 centos-release-upstream
drwxr-xr-x.  2 root root      6 Jun 14 11:27 chkconfig.d
-rw-r--r--.  1 root root   1108 Jun 14 11:27 chrony.conf
-rw-r-----.  1 root root    481 Jun 14 11:27 chrony.keys
drwxr-xr-x.  2 root root     26 Jun 14 11:27 cifs-utils
drwxr-xr-x.  2 root root     21 Jun 14 11:27 cron.d
drwxr-xr-x.  2 root root     42 Jun 14 11:27 cron.daily
-rw-------.  1 root root      0 Jun 14 11:27 cron.deny
drwxr-xr-x.  2 root root     22 Jun 14 11:27 cron.hourly
drwxr-xr-x.  2 root root      6 Jun 14 11:27 cron.monthly
-rw-r--r--.  1 root root    451 Jun 14 11:27 crontab
drwxr-xr-x.  2 root root      6 Jun 14 11:27 cron.weekly
-rw-------.  1 root root      0 Jun 14 11:27 crypttab
-rw-r--r--.  1 root root   1620 Jun 14 11:27 csh.cshrc
-rw-r--r--.  1 root root   1103 Jun 14 11:27 csh.login
drwxr-xr-x.  4 root root     78 Jun 14 11:27 dbus-1
drwxr-xr-x.  2 root root     44 Jun 14 11:27 default
drwxr-xr-x.  2 root root     23 Jun 14 11:27 depmod.d
drwxr-x---.  4 root root     53 Jun 14 11:27 dhcp
-rw-r--r--.  1 root root   5090 Jun 14 11:27 DIR_COLORS
-rw-r--r--.  1 root root   5725 Jun 14 11:27 DIR_COLORS.256color
-rw-r--r--.  1 root root   4669 Jun 14 11:27 DIR_COLORS.lightbgcolor
-rw-r--r--.  1 root root   1285 Jun 14 11:27 dracut.conf
drwxr-xr-x.  2 root root     88 Jun 14 11:27 dracut.conf.d
-rw-r--r--.  1 root root    112 Jun 14 11:27 e2fsck.conf
-rw-r--r--.  1 root root      0 Jun 14 11:27 environment
-rw-r--r--.  1 root root   1317 Jun 14 11:27 ethertypes
-rw-r--r--.  1 root root      0 Jun 14 11:27 exports
drwxr-xr-x.  2 root root      6 Jun 14 11:27 exports.d
-rw-r--r--.  1 root root     70 Jun 14 11:27 filesystems
drwxr-x---.  7 root root    133 Jun 14 11:27 firewalld
-rw-r--r--.  1 root root    450 Jun 14 11:27 fstab
-rw-r--r--.  1 root root     38 Jun 14 11:27 fuse.conf
drwxr-xr-x.  2 root root      6 Jun 14 11:27 gcrypt
drwxr-xr-x.  2 root root      6 Jun 14 11:27 gnupg
-rw-r--r--.  1 root root     94 Jun 14 11:27 GREP_COLORS
```
- данные восстановлены