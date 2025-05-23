#!/bin/bash

source ./common.sh
app_name=shipping
check_root

echo "Please enter the root password for mysql setup"
read -s MYSQL_ROOT_PASSWORD


app_setup
maven_setup
systemd_setup


dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Installing mysql"


mysql -h mysql.laddudevops.shop -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql  &>>$LOG_FILE
mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.laddudevops.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE

else
    echo -e "Data is already loaded into the MYSQL.. $Y skipping $N"

fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo  -e "Script execution has been completed, $Y Time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE