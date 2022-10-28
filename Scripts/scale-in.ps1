

#$COMPUTERNAME = "EC2AMAZ-UNAQJPL"
$name = $env:COMPUTERNAME

$devieceParameterName = (Get-SSMParameterList | Where-Object {$_.name -match $name}).name

$instanceID = (Get-SSMParameterValue -Name $devieceParameterName).Parameters.Value

$runner_User_param = $devieceParameterName.split("/device")[0]

aws ssm put-parameter --name $runner_User_param --value avaliable --overwrite

aws ssm delete-parameter --name $devieceParameterName

aws autoscaling complete-lifecycle-action --lifecycle-hook-name "scale_in" --auto-scaling-group-name "asg-teste" --lifecycle-action-result CONTINUE --instance-id $instanceID --region "us-east-1"



