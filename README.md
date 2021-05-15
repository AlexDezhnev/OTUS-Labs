# OTUS. Занятие 6 - Управление пакетами. Дистрибьюция софта 

### Задание:
```
Размещаем свой RPM в своем репозитории
- создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
- создать свой репо и разместить там свой RPM реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо
- реализовать дополнительно пакет через docker
Критерии оценки:
Статус "Принято" ставится, если сделаны репо и рпм.
Дополнительно можно сделать докер образ.
```

### Решение
vagrant up поднимает машину и:
- устанавливает NGINX
- все необходимые зависимости NGINX
- OpenSSL
- собирает NGINX rpm с поддержкой OpenSSL
- создает локальный репозиторий и размещает там собранный rpm NGINX

### Проверка
> vagrant up

> vagrant ssh rpn

> yum repolist | grep custom
```
custom                              custom-repo 
```
> yum provides nginx
```
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.docker.ru
 * extras: mirror.reconn.ru
 * updates: mirror.reconn.ru
1:nginx-1.14.1-1.el7_4.ngx.x86_64 : High performance web server
Repo        : custom



1:nginx-1.14.1-1.el7_4.ngx.x86_64 : High performance web server
Repo        : @/nginx-1.14.1-1.el7_4.ngx.x86_64
```