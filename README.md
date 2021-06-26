# Зантие 25. Архитектура сетей

### Задание

```
разворачиваем сетевую лабораторию
otus-linux
Vagrantfile - для стенда урока 9 - Network
Дано
https://github.com/erlong15/otus-linux/tree/network (ветка network)
Vagrantfile с начальным построением сети
inetRouter
centralRouter
centralServer
тестировалось на virtualbox
Планируемая архитектура
построить следующую архитектуру
Сеть office1
192.168.2.0/26 - dev
192.168.2.64/26 - test servers
192.168.2.128/26 - managers
192.168.2.192/26 - office hardware
Сеть office2
192.168.1.0/25 - dev
192.168.1.128/26 - test servers
192.168.1.192/26 - office hardware
Сеть central
192.168.0.0/28 - directors
192.168.0.32/28 - office hardware
192.168.0.64/26 - wifi
Office1 ---\
                   -----> Central --IRouter --> internet
Office2----/
Итого должны получится следующие сервера
inetRouter
centralRouter
office1Router
office2Router
centralServer
office1Server
office2Server
Теоретическая часть
Найти свободные подсети
Посчитать сколько узлов в каждой подсети, включая свободные
Указать broadcast адрес для каждой подсети
проверить нет ли ошибок при разбиении
Практическая часть
Соединить офисы в сеть согласно схеме и настроить роутинг
Все сервера и роутеры должны ходить в инет черз inetRouter
Все сервера должны видеть друг друга
у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс
Критерии оценки:
Статус "Принято" ставится, если сделана хотя бы часть.
Задание со звездочкой - выполнить всё.
```


```
Вся лаба в vagrant файле. При запуске создается 7 vm с заданными именами
Прописывается адресация и маршрутизация
В файле 25.Network.jpg схема сети
```

# Архитектура

![](/Images/Network_map.jpg)

Сеть central
- 192.168.0.0/28   - directors
- 192.168.0.32/28  - office hardware
- 192.168.0.64/26  - wifi

Сеть office1
- 192.168.2.0/26    - dev
- 192.168.2.64/26   - test servers
- 192.168.2.128/26  - managers
- 192.168.2.192/26  - office hardware

Сеть office2
- 192.168.1.0/25    - dev
- 192.168.1.128/26  - test servers
- 192.168.1.192/26  - office hardware

```
Office1 ---\
       -----> Central --IRouter --> internet
Office2----/
```

# В задании не указано
- сети в office1 и office2, к которым подключены серверы. Будут использоваться сети test servers
- сети, через которые office1Router и office2Router подключены к centralRouter. Будет использоваться сеть office hardware

# Созданы сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

# Теоретическая часть

# Найти свободные подсети

Сеть central
```
- 192.168.0.64/26 - wifi
```

Сеть office1
```
- 192.168.2.0/26 - dev
- 192.168.2.128/26 - managers
- 192.168.2.192/26 - office hardware
```

Сеть office2
```
- 192.168.1.0/25 - dev
- 192.168.1.192/26 - office hardware
```

# Посчитать сколько узлов в каждой подсети, включая свободные. Указать broadcast адрес для каждой подсети

Формат - общая емкость (включая адрес сети и броадкаст), количество доступных адресов хостов, использовано (включая маршрутизатор), количество свободных адресов

central
| Сеть | Адрес | Емкость | Доступно | Использовано | Свободно | Broadcast |
|-----------|:--------------:|:--:|:--:|:--:|:--:|:--:|
| directors | 192.168.0.0/28 | 16 | 14 | 2 | 12 | 192.168.0.15
| office hardware | 192.168.0.32/28 | 16 | 14 | 3 | 11 | 192.168.0.47
| wifi | 192.168.0.64/26 | 64 | 62 | 1 | 61 | 192.168.0.127

office1
| Сеть | Адрес | Емкость | Доступно | Использовано | Свободно |
|-----------|:--------------:|:--:|:--:|:--:|:--:|
| dev | 192.168.2.0/26 | 64 | 62 | 1 | 61 |
| test servers | 192.168.2.64/26 | 64 | 62 | 2 | 60 |
| managers | 192.168.2.128/26 | 64 | 62 | 1 | 61 |
| office hardware | 192.168.2.192/26 | 64 | 62 | 1 | 61 |

Сеть office2

office1
| Сеть | Адрес | Емкость | Доступно | Использовано | Свободно |
|-----------|:--------------:|:--:|:--:|:--:|:--:|
| dev | 192.168.1.0/25 | 128 | 126 | 1 | 125 |
| test servers | 192.168.1.128/26 | 64 | 62 | 2 | 60 |
| office hardware | 192.168.1.192/26 | 64 | 62 | 1 | 61 |




# 


Сеть office1
- 192.168.2.0/26    - dev
```
192.168.2.63
```
- 192.168.2.64/26   - test servers
```
192.168.2.127
```
- 192.168.2.128/26  - managers
```
192.168.2.191
```
- 192.168.2.192/26  - office hardware
```
192.168.2.255
```

Сеть office2
- 192.168.1.0/25    - dev
```
192.168.1.127
```
- 192.168.1.128/26  - test servers
```
192.168.1.191
```
- 192.168.1.192/26  - office hardware
```
192.168.1.255
```

# проверить нет ли ошибок при разбиении
```
Адреса сетей корректны, пересечений нет
```

# Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
```
Сделано. Маршруты добавлены
```
- Все сервера и роутеры должны ходить в инет черз inetRouter
```
Сделано. У всех устройств за главным роутером основной маршрут - ближайший вышестоящий роутер. Обратные маршруты добавлены
```
- Все сервера должны видеть друг друга
```
Сделано. Маршруты добавлены
```
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
```
Отключено
```
- при нехватке сетевых интерфейсов добавить по несколько адресов на интерфейс
```
Интерфейсов хватило
```



