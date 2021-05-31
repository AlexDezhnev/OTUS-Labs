# 4. ZFS

### Задание

```
Практические навыки работы с ZFS
Цель:
- Отрабатываем навыки работы с созданием томов export/import и установкой параметров.
- Определить алгоритм с наилучшим сжатием.
- Определить настройки pool’a Найти сообщение от преподавателей

Результат: список команд которыми получен результат с их выводами

Определить алгоритм с наилучшим сжатием

Зачем: Отрабатываем навыки работы с созданием томов и установкой параметров. Находим наилучшее сжатие.
Шаги:
- определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4)
- создать 4 файловых системы на каждой применить свой алгоритм сжатия Для сжатия использовать либо текстовый файл либо группу файлов:
- скачать файл “Война и мир” и расположить на файловой системе wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8 либо скачать файл ядра распаковать и расположить на файловой системе

Результат:
- список команд которыми получен результат с их выводами
- вывод команды из которой видно какой из алгоритмов лучше

Определить настройки pool’a
Зачем: Для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS
Шаги:
- Загрузить архив с файлами локально. https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg Распаковать.
- С помощью команды zfs import собрать pool ZFS.
- Командами zfs определить настройки
- размер хранилища
- тип pool
- значение recordsize
- какое сжатие используется
- какая контрольная сумма используется 
Результат:
список команд которыми восстановили pool . Желательно с Output команд.
- файл с описанием настроек settings

Найти сообщение от преподавателей
Зачем: для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.
Шаги:
- Скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing Файл был получен командой zfs send otus/storage@task2 > otus_task2.file
- Восстановить файл локально. zfs receive
- Найти зашифрованное сообщение в файле secret_message

Результат:
список шагов которыми восстанавливали
зашифрованное сообщение
```

### Решение 
```
[root@server ~]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  10G  0 disk
└─sda1   8:1    0  10G  0 part /
sdb      8:16   0   1G  0 disk
sdc      8:32   0   1G  0 disk
sdd      8:48   0   1G  0 disk
sde      8:64   0   1G  0 disk
sdf      8:80   0   1G  0 disk
sdg      8:96   0   1G  0 disk
[root@server ~]# zpool create hybrid raidz2 sdb sdc sdd sde
[root@server ~]# zpool list
NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
hybrid  3.75G   255K  3.75G        -         -     0%     0%  1.00x    ONLINE  -

[root@server ~]# zfs create hybrid/compress
[root@server ~]# zfs create hybrid/compress/gzip
[root@server ~]# zfs create hybrid/compress/zle
[root@server ~]# zfs create hybrid/compress/lzjb
[root@server ~]# zfs create hybrid/compress/lz4
[root@server ~]# zfs set compress=gzip hybrid/compress/gzip
[root@server ~]# zfs set compress=zle hybrid/compress/zle
[root@server ~]# zfs set compress=lzjb hybrid/compress/lzjb
[root@server ~]# zfs set compress=lz4 hybrid/compress/lz4

[root@server ~]# zfs get compression,compressratio
NAME                  PROPERTY       VALUE     SOURCE
hybrid                compression    off       default
hybrid                compressratio  1.00x     -
hybrid/compress       compression    off       default
hybrid/compress       compressratio  1.00x     -
hybrid/compress/gzip  compression    gzip      local
hybrid/compress/gzip  compressratio  1.00x     -
hybrid/compress/lz4   compression    lz4       local
hybrid/compress/lz4   compressratio  1.00x     -
hybrid/compress/lzjb  compression    lzjb      local
hybrid/compress/lzjb  compressratio  1.00x     -
hybrid/compress/zle   compression    zle       local
hybrid/compress/zle   compressratio  1.00x     -

[root@server ~]# mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
devtmpfs on /dev type devtmpfs (rw,nosuid,seclabel,size=485232k,nr_inodes=121308,mode=755)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,seclabel)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,seclabel,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,seclabel,mode=755)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,seclabel,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime,seclabel)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,memory)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpuset)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,net_cls,net_prio)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpu,cpuacct)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,freezer)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,hugetlb)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,perf_event)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,blkio)
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,rdma)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,pids)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,devices)
configfs on /sys/kernel/config type configfs (rw,relatime)
/dev/sda1 on / type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
selinuxfs on /sys/fs/selinux type selinuxfs (rw,relatime)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=34,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=17976)
debugfs on /sys/kernel/debug type debugfs (rw,relatime,seclabel)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,seclabel,pagesize=2M)
mqueue on /dev/mqueue type mqueue (rw,relatime,seclabel)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,seclabel,size=100284k,mode=700,uid=1000,gid=1000)
hybrid on /hybrid type zfs (rw,seclabel,xattr,noacl)
hybrid/compress on /hybrid/compress type zfs (rw,seclabel,xattr,noacl)
hybrid/compress/gzip on /hybrid/compress/gzip type zfs (rw,seclabel,xattr,noacl)
hybrid/compress/zle on /hybrid/compress/zle type zfs (rw,seclabel,xattr,noacl)
hybrid/compress/lzjb on /hybrid/compress/lzjb type zfs (rw,seclabel,xattr,noacl)
hybrid/compress/lz4 on /hybrid/compress/lz4 type zfs (rw,seclabel,xattr,noacl)

[root@server ~]# zfs get mounted
NAME                  PROPERTY  VALUE    SOURCE
hybrid                mounted   yes      -
hybrid/compress       mounted   yes      -
hybrid/compress/gzip  mounted   yes      -
hybrid/compress/lz4   mounted   yes      -
hybrid/compress/lzjb  mounted   yes      -
hybrid/compress/zle   mounted   yes      -

[root@server ~]# cd /hybrid/compress/
gzip/ lz4/  lzjb/ zle/
[root@server ~]# cd /hybrid/compress/gzip/

[root@server compress]# wget -O gzip/rfc1035 https://tools.ietf.org/html/rfc1035
--2021-03-30 09:21:18--  https://tools.ietf.org/html/rfc1035
Resolving tools.ietf.org (tools.ietf.org)... 64.170.98.42, 4.31.198.62
Connecting to tools.ietf.org (tools.ietf.org)|64.170.98.42|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 155040 (151K) [text/html]
Saving to: ‘gzip/rfc1035’

gzip/rfc1035                                       100%[==============================================================================================================>] 151.41K   203KB/s    in 0.7s

2021-03-30 09:21:20 (203 KB/s) - ‘gzip/rfc1035’ saved [155040/155040]

[root@server compress]# wget -O lz4/rfc1035 https://tools.ietf.org/html/rfc1035
--2021-03-30 09:21:33--  https://tools.ietf.org/html/rfc1035
Resolving tools.ietf.org (tools.ietf.org)... 64.170.98.42, 4.31.198.62
Connecting to tools.ietf.org (tools.ietf.org)|64.170.98.42|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 155040 (151K) [text/html]
Saving to: ‘lz4/rfc1035’

lz4/rfc1035                                        100%[==============================================================================================================>] 151.41K   210KB/s    in 0.7s

2021-03-30 09:21:34 (210 KB/s) - ‘lz4/rfc1035’ saved [155040/155040]

[root@server compress]# wget -O lzjb/rfc1035 https://tools.ietf.org/html/rfc1035
--2021-03-30 09:21:43--  https://tools.ietf.org/html/rfc1035
Resolving tools.ietf.org (tools.ietf.org)... 64.170.98.42, 4.31.198.62
Connecting to tools.ietf.org (tools.ietf.org)|64.170.98.42|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 155040 (151K) [text/html]
Saving to: ‘lzjb/rfc1035’

lzjb/rfc1035                                       100%[==============================================================================================================>] 151.41K   206KB/s    in 0.7s

2021-03-30 09:21:44 (206 KB/s) - ‘lzjb/rfc1035’ saved [155040/155040]

[root@server compress]# wget -O zle/rfc1035 https://tools.ietf.org/html/rfc1035
--2021-03-30 09:21:55--  https://tools.ietf.org/html/rfc1035
Resolving tools.ietf.org (tools.ietf.org)... 64.170.98.42, 4.31.198.62
Connecting to tools.ietf.org (tools.ietf.org)|64.170.98.42|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 155040 (151K) [text/html]
Saving to: ‘zle/rfc1035’

zle/rfc1035                                        100%[==============================================================================================================>] 151.41K   199KB/s    in 0.8s

2021-03-30 09:21:57 (199 KB/s) - ‘zle/rfc1035’ saved [155040/155040]



[root@server compress]# du /hybrid/compress/
157	/hybrid/compress/zle
43	/hybrid/compress/gzip
65	/hybrid/compress/lz4
95	/hybrid/compress/lzjb
359	/hybrid/compress/
```

#######################################################
## НАИБОЛЕЕ ЭФФЕКТИВЕН gzip, САМЫЙ НЕЭФФЕКТИВНЫЙ zle ##
#######################################################

```
[root@server ~]# ls -la
total 1024060
dr-xr-x---.  3 root root        211 Mar 30 20:19 .
dr-xr-xr-x. 19 root root        269 Mar 30 07:53 ..
-rw-------.  1 root root       5166 Jun 11  2020 anaconda-ks.cfg
-rw-------.  1 root root       6514 Mar 30 20:16 .bash_history
-rw-r--r--.  1 root root         18 May 11  2019 .bash_logout
-rw-r--r--.  1 root root        176 May 11  2019 .bash_profile
-rw-r--r--.  1 root root        176 May 11  2019 .bashrc
-rw-r--r--.  1 root root        100 May 11  2019 .cshrc
drwx------.  2 root root         25 Mar 30 07:45 .gnupg
-rw-------.  1 root root       5006 Jun 11  2020 original-ks.cfg
-rw-r--r--.  1 root root        129 May 11  2019 .tcshrc
-rw-r--r--.  1 root root        206 Mar 30 09:44 .wget-hsts
-rw-r--r--.  1 root root 1048586240 Mar 30 20:18 zfs_task1.tar

[root@server ~]# tar -xvf zfs_task1.tar
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
[root@server ~]# ls -la
total 1024060
dr-xr-x---.  4 root root        230 Mar 30 20:21 .
dr-xr-xr-x. 19 root root        269 Mar 30 07:53 ..
-rw-------.  1 root root       5166 Jun 11  2020 anaconda-ks.cfg
-rw-------.  1 root root       6514 Mar 30 20:16 .bash_history
-rw-r--r--.  1 root root         18 May 11  2019 .bash_logout
-rw-r--r--.  1 root root        176 May 11  2019 .bash_profile
-rw-r--r--.  1 root root        176 May 11  2019 .bashrc
-rw-r--r--.  1 root root        100 May 11  2019 .cshrc
drwx------.  2 root root         25 Mar 30 07:45 .gnupg
-rw-------.  1 root root       5006 Jun 11  2020 original-ks.cfg
-rw-r--r--.  1 root root        129 May 11  2019 .tcshrc
-rw-r--r--.  1 root root        206 Mar 30 09:44 .wget-hsts
-rw-r--r--.  1 root root 1048586240 Mar 30 20:18 zfs_task1.tar
drwxr-xr-x.  2 root root         32 May 15  2020 zpoolexport

[root@server ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE

[root@server ~]# zpool import -d zpoolexport/ otus
[root@server ~]# zpool list
NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
hybrid  3.75G  2.03M  3.75G        -         -     0%     0%  1.00x    ONLINE  -
otus     480M  2.18M   478M        -         -     0%     0%  1.00x    ONLINE  -

[root@server ~]# zfs list
NAME                   USED  AVAIL     REFER  MOUNTPOINT
hybrid                 913K  1.74G     35.1K  /hybrid
hybrid/compress        530K  1.74G     38.8K  /hybrid/compress
hybrid/compress/gzip  76.2K  1.74G     76.2K  /hybrid/compress/gzip
hybrid/compress/lz4   97.9K  1.74G     97.9K  /hybrid/compress/lz4
hybrid/compress/lzjb   128K  1.74G      128K  /hybrid/compress/lzjb
hybrid/compress/zle    190K  1.74G      190K  /hybrid/compress/zle
otus                  2.04M   350M       24K  /otus
otus/hometask2        1.88M   350M     1.88M  /otus/hometask2

[root@server ~]# zfs get checksum
NAME                  PROPERTY  VALUE      SOURCE
hybrid                checksum  on         default
hybrid/compress       checksum  on         default
hybrid/compress/gzip  checksum  on         default
hybrid/compress/lz4   checksum  on         default
hybrid/compress/lzjb  checksum  on         default
hybrid/compress/zle   checksum  on         default
otus                  checksum  sha256     local
otus/hometask2        checksum  sha256     inherited from otus

root@server ~]# zfs get recordsize
NAME                  PROPERTY    VALUE    SOURCE
hybrid                recordsize  128K     default
hybrid/compress       recordsize  128K     default
hybrid/compress/gzip  recordsize  128K     default
hybrid/compress/lz4   recordsize  128K     default
hybrid/compress/lzjb  recordsize  128K     default
hybrid/compress/zle   recordsize  128K     default
otus                  recordsize  128K     local
otus/hometask2        recordsize  128K     inherited from otus

[root@server ~]# zfs get compression,compressratio
NAME                  PROPERTY       VALUE     SOURCE
hybrid                compression    off       default
hybrid                compressratio  2.32x     -
hybrid/compress       compression    off       default
hybrid/compress       compressratio  2.67x     -
hybrid/compress/gzip  compression    gzip      local
hybrid/compress/gzip  compressratio  5.24x     -
hybrid/compress/lz4   compression    lz4       local
hybrid/compress/lz4   compressratio  3.67x     -
hybrid/compress/lzjb  compression    lzjb      local
hybrid/compress/lzjb  compressratio  2.60x     -
hybrid/compress/zle   compression    zle       local
hybrid/compress/zle   compressratio  1.62x     -
otus                  compression    zle       local
otus                  compressratio  1.00x     -
otus/hometask2        compression    zle       inherited from otus
otus/hometask2        compressratio  1.00x     -

[root@server ~]# zpool status
  pool: hybrid
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	hybrid      ONLINE       0     0     0
	  raidz2-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```


#######################################
## Найти сообщение от преподавателей ##
#######################################

```
[root@server ~]# zfs receive hybrid/text < otus_task2.file
[root@server ~]# zfs list
NAME                   USED  AVAIL     REFER  MOUNTPOINT
hybrid                4.53M  1.74G     35.1K  /hybrid
hybrid/compress        530K  1.74G     38.8K  /hybrid/compress
hybrid/compress/gzip  76.2K  1.74G     76.2K  /hybrid/compress/gzip
hybrid/compress/lz4   97.9K  1.74G     97.9K  /hybrid/compress/lz4
hybrid/compress/lzjb   128K  1.74G      128K  /hybrid/compress/lzjb
hybrid/compress/zle    190K  1.74G      190K  /hybrid/compress/zle
hybrid/text           3.74M  1.74G     3.74M  /hybrid/text
otus                  2.04M   350M       24K  /otus
otus/hometask2        1.88M   350M     1.88M  /otus/hometask2

[root@server text]# cat task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```