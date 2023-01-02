#!/bin/bash

#Description: This script checks instance existance status and prints its state.
#Step1: Create "inst.list" file and list the instanceIDs that you want to check.
#Step2: Run the script!!

for i in $(cat inst.list)
    do
        output=$(aws ec2 describe-instances --instance-ids $i --query 'Reservations[].Instances[].[State.Name]' --output text 2>/dev/null)
        if [ $? -eq 0 ];
            then
                if [ -z "$output" ] || [ "$output" = "terminated" ];
                    then
                        echo $i, "Terminated/NotFound"
                    else
                        echo $i, $output
                fi
            else
                echo "Something went worng or $i does not exist"
        fi
    done
