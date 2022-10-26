<powershell>

$lambdaName = "RegisterDeviceA360"

$temp_path = "C:\Users\Public\Documents\"

$codPool = "120"

#$installer_url1 = "https://teste-public-access.s3.amazonaws.com/AutomationAnywhereBotAgent.msi"
#$installer_file1 = $temp_path + [System.IO.Path]::GetFileName( $installer_url1 )

#$installer_url2 = "https://teste-public-access.s3.amazonaws.com/ChromeSetup.exe"
#$installer_file2 = $temp_path + [System.IO.Path]::GetFileName( $installer_url2 )

#$extension_url = "https://teste-public-access.s3.amazonaws.com/kammdlphdfejlopponbapgpbgakimokm.zip"
#$extension_file = $temp_path + [System.IO.Path]::GetFileName( $extension_url )

$installer_url3 = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$installer_file3 = $temp_path + [System.IO.Path]::GetFileName( $installer_url3 )

#$extension_installer_folder = $temp_path + [System.IO.Path]::GetFileName( $extension_url ).split(".")[0]
#$chrome_installer = "C:\Program Files\Google\Chrome\Application\chrome.exe"

Try
{
    #Invoke-WebRequest -Uri $installer_url1 -OutFile $installer_file1

    #Invoke-WebRequest -Uri $installer_url2 -OutFile $installer_file2
    
    Invoke-WebRequest -Uri $installer_url3 -OutFile $installer_file3

    #Invoke-WebRequest -Uri $extension_url -OutFile $extension_file

    Start-Process -FilePath $installer_file3 -ArgumentList "/quiet" -Wait

    #Start-Process -FilePath $installer_file2 -ArgumentList "/silent /install" -Wait

    #Start-Process -FilePath $installer_file1 -ArgumentList "/quiet" -Wait

    #Expand-Archive $extension_file -DestinationPath $temp_path

    #& $chrome_installer --load-extension=$extension_installer_folder
} 
Catch
{
   Write-Output ( $_.Exception.ToString() )
   Break
}

try{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

    #aws lambda update-function-configuration --function-name $functionName --environment "Variables={runnerUser='$runner_User',runnerDevice='$env:COMPUTERNAME'}"
    
    #aws lambda invoke --function-name $functionName response.json

    #aws ssm describe-parameters --parameter-filters "Key=Path,Values=/pool/$codPool/user"

    $runner_User_param = (Get-SSMParametersByPath -Path "/pool/$codPool/user/" | Where-Object {$_.Value -eq "avaliable"} | Select-Object -First 1).name

    $runner_User = $runner_User_param.Split("/")[-1]

    #$payload = '{\"runnerUser\":\"'+$runner_User+'\" , \"runnerDevice\":\"'+$env:COMPUTERNAME+'\"}' # acrescentar o device pool

    #aws lambda invoke --function-name $lambdaName --cli-binary-format raw-in-base64-out --payload $payload response.json

    aws ssm put-parameter --name $runner_User_param --value unavaliable --overwrite

    aws ssm put-parameter --name "$runner_User_param/device" --value $env:COMPUTERNAME --type "String" --overwrite

    $instanceID = (curl http://169.254.169.254/latest/meta-data/instance-id).content

    aws autoscaling complete-lifecycle-action --lifecycle-hook-name "scale_out" --auto-scaling-group-name "asg-teste" --lifecycle-action-result CONTINUE --instance-id $instanceID
}
catch{

    $logMsg = "Erro ao executar commando no AWS CLI"

    $logMsg | Out-File $temp_path"log.txt"
}
</powershell>