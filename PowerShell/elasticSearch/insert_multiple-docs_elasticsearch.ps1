<#
This is my first basic powerhsell script(just for fun) that post multiple docs in ElasicSearch Index.
First it ask you the number of docs you want to post. 
Then it generates that number of docs and post them in index.
Docs contains machine's(where this script is ran) ip address, hostname, random_genrated_string, random_generated_integer.
#>

$host_addr = (Get-NetIpAddress -AddressFamily IPv4 -InterfaceAlias Ethernet*).IPAddress -join ", " #Generate IPv4 of Server
$host_name = hostname.exe #Get Hostname of server

$cluster_addr = Read-Host "Enter the Cluster IP or Hostname"
$index_name = Read-Host "Enter the Index Name"
[int]$inputCount = Read-Host "Count of dcoument you want to insert? e.g 1, 10, 100 etc"

$countValue = Invoke-WebRequest -URI "http://$cluster_addr`:9200/$index_name`/_count" | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -Property count #Count total docs of the index
Write-Output "Total Docx: " $countValue.count

#Check if index docs is 0 and if true insert 1 docs
if($countValue.count -eq 0){
    $host_ran_id = -join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_}) #Generate Random String
    $ran_id = Get-Random –Minimum 0000 -Maximum 9999 #Generate Random Integer
    $body = @{"s_id" = "1"; "ran_id" = $ran_id; "host_name" = $host_name; "host_addr" = $host_addr; "host_ran_id" = $host_ran_id} | ConvertTo-Json
    Invoke-WebRequest -Method POST -Uri "http://$cluster_addr`:9200/$index_name`/_doc/1" -ContentType 'application/json' -Body $body #ElasticSearch Post meathod to insert docs
    Start-Sleep -Seconds 5 #Pause for 5sec
}

[int]$find_id = $countValue.count - 1
$latest_id = Invoke-WebRequest -Method GET -Uri "http://$cluster_addr`:9200/$index_name`/_search?_source=s_id&from=$find_id" -ContentType 'application/json' | Select-Object -ExpandProperty Content | ConvertFrom-Json #Get ES Search Field
Write-Output "Latest SID: " $latest_id.hits.hits._source.s_id

[int]$chng_count = [int]$inputCount + [int]$latest_id.hits.hits._source.s_id
[int]$start_count = [int]$latest_id.hits.hits._source.s_id + 1

Write-Output "Insert Docx Count: " $inputCount

for ($a = $start_count; $a -le $chng_count; $a++)
{

$host_ran_id = -join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})
$ran_id = Get-Random –Minimum 0000 -Maximum 9999
$body = @{"s_id" = "$a"; "ran_id" = $ran_id; "host_name" = $host_name; "host_addr" = $host_addr; "host_ran_id" = $host_ran_id} | ConvertTo-Json
Invoke-WebRequest -Method POST -Uri "http://$cluster_addr`:9200/$index_name`/_doc/$a" -ContentType 'application/json' -Body $body

Write-Output $a, $host_addr, $host_name, $host_ran_id, $ran_id

}

Write-Output "Reading New Count...."

Start-Sleep -Seconds 5

$new_count =  Invoke-WebRequest -URI "http://$cluster_addr`:9200/$index_name`/_count" | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -Property count
Write-Output $new_count.count