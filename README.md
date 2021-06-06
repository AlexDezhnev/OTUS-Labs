# Занятие 17. SELinux - когда все запрещено 

### Задание
```
Практика с SELinux
Цель:

Тренируем умение работать с SELinux: диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

К сдаче:
README с описанием каждого решения (скриншоты и демонстрация приветствуются).

Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность. К сдаче:

README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;

Исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

Критерии оценки:

Статус "Принято" ставится при выполнении следующих условий:
- для задания 1 описаны, реализованы и продемонстрированы все 3 способа решения;
- для задания 2 описана причина неработоспособности механизма обновления зоны;
- для задания 2 реализован и продемонстрирован один из способов решения;

Опционально для выполнения:
- для задания 2 предложено более одного способа решения;
- для задания 2 обоснованно(!) выбран один из способов решения.
```
## ЗАДАНИЕ 1

### Стенд с помощью ansible поднимает сервер с nginx на порту 7080 и накатывает необходимые для работы с SELinux пакеты
- сервис nginx не стартует с нестандартным портом, не разрешает SELinux
>vagrant ssh

>sudo systemctl status nginx.service
```
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sat 2021-06-05 17:00:20 UTC; 12s ago
  Process: 3795 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3897 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 3896 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3797 (code=exited, status=0/SUCCESS)

Jun 05 17:00:20 hw11 systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Jun 05 17:00:20 hw11 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jun 05 17:00:20 hw11 systemd[1]: nginx.service: control process exited, code=exited status=1
Jun 05 17:00:20 hw11 nginx[3897]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jun 05 17:00:20 hw11 nginx[3897]: nginx: [emerg] bind() to 0.0.0.0:7080 failed (13: Permission denied)
Jun 05 17:00:20 hw11 nginx[3897]: nginx: configuration file /etc/nginx/nginx.conf test failed
Jun 05 17:00:20 hw11 systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Jun 05 17:00:20 hw11 systemd[1]: Unit nginx.service entered failed state.
Jun 05 17:00:20 hw11 systemd[1]: nginx.service failed.
```
##### Вариант 1. Переключатели setsebool
>sudo setsebool -P nis_enabled 1
```
[vagrant@hw11 ~]$ sudo systemctl restart nginx
[vagrant@hw11 ~]$ sudo systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-06-05 17:01:58 UTC; 3s ago
  Process: 3952 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3949 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3948 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3954 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3954 nginx: master process /usr/sbin/nginx
           └─3955 nginx: worker process

Jun 05 17:01:58 hw11 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jun 05 17:01:58 hw11 nginx[3949]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jun 05 17:01:58 hw11 nginx[3949]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jun 05 17:01:58 hw11 systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Jun 05 17:01:58 hw11 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

##### Вариант 2. Добавление нестандартного порта в имеющийся тип
>sudo semanage port --add --type http_port_t --proto tcp 7080
```
[vagrant@hw11 ~]$ sudo systemctl restart nginx
[vagrant@hw11 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-06-05 17:11:52 UTC; 6s ago
  Process: 3851 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3848 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3847 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3853 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3853 nginx: master process /usr/sbin/nginx
           └─3854 nginx: worker process

Jun 05 17:11:52 hw11 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jun 05 17:11:52 hw11 nginx[3848]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jun 05 17:11:52 hw11 nginx[3848]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jun 05 17:11:52 hw11 systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Jun 05 17:11:52 hw11 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

##### Вариант 3. Формирование и установка модуля SELinux
>sudo ausearch -c 'nginx' --raw | audit2allow -M nginx-custom-port
>sudo semodule -i nginx-custom-port.pp
```
[root@hw11 ~]# sudo systemctl restart nginx
[root@hw11 ~]# sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-06-05 17:20:51 UTC; 6s ago
  Process: 3872 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3870 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3869 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3874 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3874 nginx: master process /usr/sbin/nginx
           └─3875 nginx: worker process

Jun 05 17:20:51 hw11 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jun 05 17:20:51 hw11 nginx[3870]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jun 05 17:20:51 hw11 nginx[3870]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jun 05 17:20:51 hw11 systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Jun 05 17:20:51 hw11 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

## ЗАДАНИЕ 2
- Развертываем стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems

Как говорил мудрый рядовой Иванов, чистка автомата начинается с проверки серийного номера, чтобы не почистить чужой автомат. По условию, инженер предполагает, что проблема в SELinux. Ок, на сервере и клиенте переводим SELinux в режим permissive
>setenforce 0

И пробуем обновить зону с клиента
```
[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
>
```
Сработало. Проблема действительно в SELinux. Значит, будем чистить автомат.

На сервере:
>[root@ns01 ~]# audit2why < /var/log/audit/audit.log
```
type=AVC msg=audit(1622957726.466:1932): avc:  denied  { create } for  pid=5374 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1622957726.466:1932): avc:  denied  { write } for  pid=5374 comm="isc-worker0000" path="/etc/named/dynamic/named.ddns.lab.view1.jnl" dev="sda1" ino=465013 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.
```
Поскольку SELinux хотя и не вмешивается в работу системы, но тем не менее записывает в audit.log все происходящее, мы видим, что он сделал стойку на создание и запись файла /etc/named/dynamic/named.ddns.lab.view1.jnl

Очевидно, что папка /etc/named принимает участие в работе DNS. Проверим, что там с разрешениями
```
[root@ns01 ~]# ls -Z /etc/named/
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab

[root@ns01 ~]# ls -Z /etc/named/dynamic/
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
-rw-r--r--. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1.jnl
```
Два момента:
- права на запись файла /etc/named/dynamic/named.ddns.lab.view1.jnl у группы named нет. Правда, есть у пользователя named, но на всякий уравняем с остальными файлами в папке
>chmod 660 /etc/named/dynamic/named.ddns.lab.view1.jnl
- контекст у папки /etc/named и всех вложенных файлов и папок - etc_t, что явно не совпадает named_t, указанном в логе аудита. Меняем все
>chcon -v -R -t named_zone_t /etc/named
```
changing security context of ‘/etc/named/named.dns.lab’
changing security context of ‘/etc/named/named.dns.lab.view1’
changing security context of ‘/etc/named/dynamic/named.ddns.lab’
changing security context of ‘/etc/named/dynamic/named.ddns.lab.view1’
changing security context of ‘/etc/named/dynamic/named.ddns.lab.view1.jnl’
changing security context of ‘/etc/named/dynamic’
changing security context of ‘/etc/named/named.newdns.lab’
changing security context of ‘/etc/named/named.50.168.192.rev’
changing security context of ‘/etc/named’
```
Возвращаем SELinux на сервере и клиенте в режим enforcing
>setenforce 1

На клиенте проверяем работоспособность обновления зоны
```
[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
>
```
Все работает

##### В отчете инженеру даем рекомендацию изменить контекст для папки /etc/named и установить разрешение 660 на файл /etc/named/dynamic/named.ddns.lab.view1.jnl:

>semanage fcontext -a -t named_zone_t "/etc/named(/.*)?"

>restorecon -v -r '/etc/named'

>chmod 660 /etc/named/dynamic/named.ddns.lab.view1.jnl