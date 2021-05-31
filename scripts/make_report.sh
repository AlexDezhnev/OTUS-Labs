#!/bin/bash

# Количество анализируемых IP адресов
X=10
# Количество запрашиваемых адресов 
Y=10

# номер последней обработанной в прошлый запуск строки (хранится в last_line.txt)
last_line=$(cat last_line.txt)

# lock duplicate run
lockfile=/tmp/lockfile

function analyze_log () {
    # X запросов с IP адресов
    echo "$X IP адресов с наибольшим количеством запросов" > log_report.txt
    echo "" >> log_report.txt
    awk 'NR > $last_line {print $1}' $1 | sort | uniq -c | sort -rn | head -n $X >> log_report.txt

    # Y запрашиваемых адресов (метод http GET)
    echo -e "\n$Y запрашиваемых адресов" >> log_report.txt
    echo "" >> log_report.txt
    awk 'NR > $last_line && /'GET'/ {print $7}' $1 | sort | uniq -c | sort -rn | head -n $Y >> log_report.txt

    # Ошибки
    echo -e "\nОшибки" >> log_report.txt
    echo "" >> log_report.txt
    awk 'NR > $last_line {print $9}' $1 | grep -P '\d{1,3}' | sort | uniq -c | sort -rn | head >> log_report.txt

    echo -e "\n Дата отчета $(date)" >> log_report.txt
}


if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
    # парсим лог начиная с последней обработанной строки
    analyze_log $1
    # отправляем отчет на почту
    mail -s "Report" vagrant < log_report.txt
    rm -f "$lockfile"
    trap - INT TERM EXIT
    # сохраняем последнюю обработанную строку
    awk 'END {print NR}' $1 > last_line.txt
else
   echo "Failed to acquire lockfile: $lockfile."
   echo "Held by $(cat $lockfile)"
fi