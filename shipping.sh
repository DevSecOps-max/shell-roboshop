#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

echo "Please enter the root password for mysql setup"
read -s MYSQL_ROOT_PASSWORD

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}


dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven and Java"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created... $Y SKIPPING $N"
fi


mkdir -p /app 
VALIDATE $? "Creating a app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading application code to the created app directory"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$LOG_FILE 
VALIDATE $? "unzipping shipping"


mvn clean package  &>>$LOG_FILE
VALIDATE $? "Creating the package for a shipping application"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "Moving and Renaming the jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Daemon"


systemctl enable shipping  &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting Shipping"


dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql

VALIDATE $? "Loading data into MYSQL"


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo  -e "Script execution has been completed, $Y Time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE