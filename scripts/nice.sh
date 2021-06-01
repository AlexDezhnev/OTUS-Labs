#!/bin/bash

# Запускаем два экземпляра цикла
./loop.sh &
./loop.sh &
sleep 2

# Получаем PID запущенных скриптов
loop1=$(top -b -n1 | grep "loop.sh" | awk 'NR==1 {print $1}')
loop2=$(top -b -n1 | grep "loop.sh" | awk 'NR==2 {print $1}')
echo -e "\nЦикл 1: PID=$loop1"
echo -e "Цикл 2: PID=$loop2"

# Вешаем на 1 процессор оба скрипта
taskset -cp 0 $loop1 >/dev/null
taskset -cp 0 $loop2 >/dev/null

# Понижаем приоритет скрипту 1
echo -e "\nChanging process priority!"
renice 5 -p $loop1

# Ждем 5 секунд, чтобы устаканить нагрузку
echo -e "\nPlease wait 5 sec"
sleep 5

# Снимаем показатели нагрузки на процессор и время работы
cpu1=$(top -b -n1 | grep "loop.sh"| awk 'NR==1 {print $9}')
cpu2=$(top -b -n1 | grep "loop.sh"| awk 'NR==2 {print $9}')
time1=$(top -b -n1 | grep "loop.sh"| awk 'NR==1 {print $11}')
time2=$(top -b -n1 | grep "loop.sh"| awk 'NR==1 {print $11}')

# Вывод в консоль
echo -e "\nЦикл 1: PID=$loop1, загрузка ядра $cpu1, время работы $time1"
echo "Цикл 2: PID=$loop2, загрузка ядра $cpu2, время работы $time2"