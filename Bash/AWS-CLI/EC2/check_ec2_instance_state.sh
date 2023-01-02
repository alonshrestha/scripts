#!/bin/bash

#Description: This script checks instance existance status and prints its state.
#Add your instanceId in "instArray" with given format and run the script.

instArray=("i-0XXXXXXXXXX3c7e" "i-07XXXXXXXXX9d65" "i-079XXXXXXXXXe0b" "i-07aXXXXXXXXX21")

for i in ${instArray[@]};
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
                echo $i, "Terminated/NotFound"
        fi
    done