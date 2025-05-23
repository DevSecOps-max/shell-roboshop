#!/bin/bash

source ./common.sh
app_name=mysql
check_root


echo "Please enter the root password for mysql setup"
read -s MYSQL_ROOT_PASSWORD


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld   &>>$LOG_FILE
VALIDATE $? "Enabling mysql"
systemctl start mysqld    &>>$LOG_FILE
VALIDATE $? "Starting mysql" 


mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MYSQL root password"

print_time
