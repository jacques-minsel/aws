#!/bin/bash
read -p "name of your snapshot: " snapname
read -p "id instance: " my_instance
read -p "description (facultatif): " description
read -p "la taille que tu souhaites: " idtype

my_instance=$my_instance
snapname=$snapname
description=$description
idtype=$idtype
#DATE=$d
# start ami a Ec2 instance
echo -e "\e[93m *** start ami a Ec2 instance ID $my_instance *** \e[0m"

OUT=$(aws ec2 create-image --instance-id $my_instance --name $snapname --description $description --no-reboot --output text)
MY_STATE=$(echo "$OUT" | grep STATE | head -n 1 | cut -d'"' -f4)

#Wait for ami is in availaible status
    while [[ $MY_STATE = pending ]]; do  
    echo "AMI is not ready it still pending"
    sleep 5
    OUT=$(aws ec2 describe-images --image-ids "$OUT" --output text)
    MY_STATE=$(echo "$OUT" | grep STATE | cut -d'"' -f4)   
    done
    if [[ $MY_STATE != availaible ]]; then
  echo "start to change "
    fi
sleep 10
# stop a Ec2 instance
    echo -e "\e[93m *** stop a Ec2 instance ID $my_instance *** \e[0m"
    stop_OUT=$(aws ec2 stop-instances --instance-ids $my_instance --output text)
    stop_STATE=$(echo "$stop_OUT" | grep STATE | head -n 1 | cut -f 3) 
    
# Wait for instance in stop status
    while [[ $stop_STATE = stopping ]]; do 
    echo "- Waiting for stopping status"
    sleep 5
    stop_OUT=$(aws ec2 describe-instances --instance-ids $my_instance --output text)
    stop_STATE=$(echo "$stop_OUT" | grep STATE | head -n 1 | cut -f 3)   
done

if [ $stop_STATE = stopped ]; then
    echo -e "\e[93m *** change instance type Ec2 instance ID $my_instance *** \e[0m"
    aws ec2 modify-instance-attribute --instance-id $my_instance --instance-type "{\"Value\": \"$idtype\"}"
fi 
sleep 20
aws ec2 start-instances --instance-ids $my_instance
