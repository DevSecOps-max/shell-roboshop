#!/bin/bash

source ./common.sh
app_name=redis
check_root


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the default redis version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the redis:7"

dnf install redis -y  &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected mode/ c protected-mode no' /etc/redis/redis.conf  # c - change, i- permanent 
VALIDATE $? "Edited redis.conf file to accept remote connections"


systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis  &>>$LOG_FILE
VALIDATE $? "Started the Redis service"


print_time


















