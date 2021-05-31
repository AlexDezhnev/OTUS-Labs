#!/bin/bash

# устанавливаем переменную, равную количеству строк лога + 1
last_line=$(awk 'END {print NR+1}' access.log)
# добавляем одну строку из шаблона
sed -n ${last_line}p access-template.log >> access.log