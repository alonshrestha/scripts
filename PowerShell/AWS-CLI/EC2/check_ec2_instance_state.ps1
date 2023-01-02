#Description: This script checks instance existance status and prints its state.
#Add your instanceId in "instArray" with given format and run the script.

$instArray = "i-0XXXXXXXXXXX5", "i-01XXXXXXXXX26d49", "i-0XXXXXXXXXXefbc"
foreach ($i in $instArray){
    $output = aws ec2 describe-instances --instance-ids	$i --query 'Reservations[].Instances[].[State.Name]' --output text 2>$null
    if ($LASTEXITCODE -eq 0){
        if ($output.Length -eq 0 -Or $output -eq "terminated"){
            Write-Output "$i`, Terminated/NotFound"
        }else{
            Write-Output "$i`,  $output"
        }
    }else{
         Write-Output "$i`, Terminated/NotFound"
    }
}
