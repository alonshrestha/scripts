#!/bin/bash

Echo "Change Instance Type Automation!!!!"
read -p "Enter the Instance ID: " instId
read -p "Enter Instance Type for ${instId}: " newInstType

instState=$(aws ec2 describe-instances --instance-ids $instId --query 'Reservations[].Instances[].[State.Name]' --output text 2>/dev/null)
if [ $? -eq 0 ];
    then
        if [ -z $instState ] || [ $instState = "terminated" ];
            then
                echo "Didn't find $instId"
                exit 0
            else
                if [ $instState != "stopped" ];
                    then
                        echo "Instance $instId is not in stopped state. Stopping it.."
                        until [ "stopped" = $(aws ec2 stop-instances --instance-ids $instId --query 'StoppingInstances[].[CurrentState.Name]' --output text) ]
                            do 
                                echo "Stop instance in progress.."
                                sleep 30
                            done
                        echo "Instance stopped."
                        echo "Changing instance type to --> $newInstType"
                        cmdExecute=$(aws ec2 modify-instance-attribute --instance-id $instId --instance-type "{\"Value\": \"${newInstType}\"}" 2>&1 >/dev/null)
                        if [ $? -ne 0 ];
                            then
                                echo "Error: $cmdExecute"
                                exit 0
                        fi
                        sleep 1
                        checkInstType=$(aws ec2 describe-instances --instance-ids $instId --query 'Reservations[].Instances[].[InstanceType]' --output text 2>/dev/null)    
                        if [ "$checkInstType" != "$newInstType" ];
                            then
                                echo "Error: Something went wrong.."
                                exit 0
                            else
                                echo "$instId instance type changed to -> $newInstType"
                                counter=0
                                until [ $counter -eq 3 ]
                                        do
                                            read -p "Do you want to run the instance?(y/n): " runInst
                                            if [ $runInst = "y" ];
                                                then
                                                    aws ec2 start-instances --instance-ids $instId
                                                    echo "$instId Started."
                                                    exit 0
                                            elif [ $runInst = "n" ];
                                                then
                                                    echo "$instId Stopped."
                                                    exit 0
                                            else
                                                ((counter=counter+1))
                                            fi
                                        done
                                        echo "$instId Stopped."
                        fi
                    else    
                        echo "Instance $instId is already in stopped state."
                        echo "Changing instance type to --> $newInstType"
                        cmdExecute=$(aws ec2 modify-instance-attribute --instance-id $instId --instance-type "{\"Value\": \"${newInstType}\"}" 2>&1 >/dev/null)
                        if [ $? -ne 0 ];
                            then
                                echo "Error: $cmdExecute"
                                exit 0
                        fi
                        sleep 1
                        checkInstType=$(aws ec2 describe-instances --instance-ids $instId --query 'Reservations[].Instances[].[InstanceType]' --output text 2>/dev/null)    
                        if [ "$checkInstType" != "$newInstType" ];
                            then
                                echo "Error: Something went wrong.."
                                exit 0
                            else
                                echo "$instId instance type changed to -> $newInstType"
                                counter=0
                                until [ $counter -eq 3 ]
                                        do
                                            read -p "Do you want to run the instance?(y/n): " runInst
                                            if [ $runInst = "y" ];
                                                then
                                                    aws ec2 start-instances --instance-ids $instId
                                                    echo "$instId Started."
                                                    exit 0
                                            elif [ $runInst = "n" ];
                                                then
                                                    echo "$instId Stopped."
                                                    exit 0
                                            else
                                                ((counter=counter+1))
                                            fi
                                        done
                                        echo "$instId Stopped."
                        fi                
                fi    
        fi
    else
        echo "Didn't find $instId"
        exit 0           
        
fi