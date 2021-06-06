# Занятие 18. Docker

### Задание
```
- Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
- Определите разницу между контейнером и образом Вывод опишите в домашнем задании.
- Ответьте на вопрос: Можно ли в контейнере собрать ядро?
- Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.

Задание со * (звездочкой)
- Создайте кастомные образы nginx и php, объедините их в docker-compose. После запуска nginx должен показывать php info.
- Все собранные образы должны быть в docker hub
```
#### Кастомный образ nginx на базе alpine
Образ собран с помощью [Dockerfile](docker/Dockerfile) и загружен в [DockerHub](https://hub.docker.com/r/adezhnev/otus-labs)

Стенд содержит Docker, устанавливаемый при запуске Vagrant с помощью Ansible

###### Проверка:

>vagrant up

>vagrant ssh

>sudo docker run -d -p 8000:80 adezhnev/otus-labs

>curl localhost:8000

#### Разница между образом и контейнером
Образ - это шаблон, из которого создается контейнер. Сам образ запустить невозможно, запускается контейнер.
Образ создается с помощью инструкций Dockerfile, при этом каждая новая инструкция формирует новый ReadOnly слой в образе. Каждый новый слой - это набор отличий от предыдцщего, т.н. Diff.

>Грубо, контейнер - это образ, в котором открыт на запись верхний слой и инициализированы различные параметры (имя, лимиты, сеть и тд)

#### Можно ли в контейнере собрать ядро?
Можно. Google по строке поиска "Docker kernel build" дает массу примеров. Единственное, загрузиться внутри докера с такого ядра не получится.