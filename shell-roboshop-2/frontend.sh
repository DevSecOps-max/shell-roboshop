#!/bin/bash

source ./common.sh
check_root


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling the nginx  default module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nginx:1.24"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "Installing the nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx  
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing and default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the Frontend Content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "Unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove the default nginx configuration"

cp $SCRIPT_DIR/nginx.conf  /etc/nginx/nginx.conf
VALIDATE $? "Copying the nginx.conf"

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "restarting the nginx"











