#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

echo "Please enter the password for RabbitMQ"
read -s RABBITMQ_PASSWORD


cp $SCRIPT_DIR/rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding rabbitMQ repo"


dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitMQ server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitMQ"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting rabbitMQ"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_time
