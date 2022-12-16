#!/bin/bash


host_addr=$(hostname -I | awk '{print $1}') #Host IP Address
host_name=$HOSTNAME #Hostname

read -p "Enter the Cluster IP or Hostname: " cluster_addr #asking for cluster address
read -p "Enter the Index Name: " index_name #asking for index name
read -p "Count of vaule you want to add? e.g 1, 10, 100 etc: " inputCount #reading data from user

count_doc=$(curl -X GET http://${cluster_addr}:9200/_cat/indices?v | grep "script_data" | awk '{print $7}') #counting total number of docs

if [ $count_doc -eq 0 ]
then

ran_id=$(echo $RANDOM | head -c 4;) #randomNumberGenerator vaule of 4 digits
host_ran_id=$(echo $RANDOM | md5sum | head -c 20; echo;) #randomStringGenerator value of 20 digits
curl -H "Content-Type: application/json"  -X POST "http://${cluster_addr}:9200/$index_name/_doc/1" -d '{ "s_id" : "1", "ran_id" : "'$ran_id'", "host_name" : "'$host_name'", "host_addr" : "'$host_addr'", "host_ran_id" : "'$host_ran_id'"}'

sleep 5

fi

latest_id=$(curl -H 'Content-Type:application/json' -X GET "http://${cluster_addr}:9200/$index_name/_search?pretty" -d '{"_source": "s_id"}' | grep "s_id" | tail -1 | awk '{print $3}' | sed 's/"//g') #reading latest count ofindex document

echo "Latest SID: $latest_id"

chng_count=$(( $inputCount+$latest_id )) #new count to be set

start_count=$(( 1+$latest_id)) #Starting count of new counts_ids

for (( a=$start_count; a<=$chng_count; a++))
do
ran_id=$(echo $RANDOM | head -c 4;) #randomNumberGenerator vaule of 4 digits
host_ran_id=$(echo $RANDOM | md5sum | head -c 20; echo;) #randomStringGenerator value of 20 digits

curl -H "Content-Type: application/json"  -X POST "http://${cluster_addr}:9200/$index_name/_doc/$a" -d '{ "s_id" : "'$a'", "ran_id" : "'$ran_id'", "host_name" : "'$host_name'", "host_addr" : "'$host_addr'", "host_ran_id" : "'$host_ran_id'"}'

echo " | $a, $ran_id, $host_name, $host_addr, $host_ran_id"

done

if [ "$?" -eq "0" ]
then
echo "Data Entry Success"
else
echo "Something went wrong"
fi

echo "Reading New Count...."

sleep 5

new_count=$(curl -X GET http://${cluster_addr}:9200/_cat/indices?v | grep "script_data" | awk '{print $7}') #counting total number of docs

echo "New Count: $new_count"