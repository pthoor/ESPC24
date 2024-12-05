# ESPC24

Welcome to the ESPC24 repository!

This repository contains the demos and scripts used in the session talk "Mastering Cloud Security: A Deep Dive into Defender for Cloud for IT Pros and Developers" at the ESPC24 conference. The session covers various aspects of cloud security, including Azure Arc, custom script extensions, and security tools for DevOps.

For more details about the session, visit the [event page](https://www.sharepointeurope.com/events/mastering-cloud-security-a-deep-dive-into-defender-for-cloud-for-it-pros-and-developers/).

## Table of Contents

- [Presentation](#presentation)
- [Demo Hybrid Environments](#demo-hybrid-environments)
- [Custom Script Extension](#custom-script-extension)
- [Run Command](#run-command)
- [Demo Defender for DevOps](#demo-defender-for-devops)
- [Demo Defender for Resource Manager (ARM)](#demo-defender-for-resource-manager)

## Presentation

See the file [here](./Th20_Mastering%20Cloud%20Security%20A%20Deep%20Dive%20into%20Defender%20for%20Cloud%20for%20IT%20Pros%20and%20Developers_PierreThoor.pdf) for PDF-version of the presentation.

## Demo Hybrid Environments

Try out Azure Arc with simple steps:
1. Set environment variable:
    ```powershell
    [System.Environment]::SetEnvironmentVariable("MSFT_ARC_TEST",'true',[System.EnvironmentVariableTarget]::Machine)
    ```

2. Remove all extensions from the Azure VM
    ```powershell
    az vm extension list -g <rgName> --vm-name <vmName>
    az vm extension delete –g <rgName> --vm-name <vmName> -n <extensionName>
    ```
4. Disable Azure VM guest agent
    ```powershell
    Set-Service WindowsAzureGuestAgent -StartupType Disabled -Verbose
    Stop-Service WindowsAzureGuestAgent -Force -Verbose
    ```
5. Firewall settings:
    ```powershell
    New-NetFirewallRule -Name BlockAzureIMDS -DisplayName "Block access to Azure IMDS" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 169.254.169.254
    ```
6. Install Azure Arc Connected machine agent via script, GPO or other with other tooling, see [Connect hybrid machines to Azure](https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-portal). Here's a short and easy PowerShell script for downloading and installing the Azure Arc Connected machine agent:
    ```powershell
    # Define the URL for the Azure Connected Machine Agent
    $agentUrl = "https://aka.ms/AzureConnectedMachineAgent"

    # Define the path to save the downloaded file
    $downloadPath = "$env:TEMP\AzureConnectedMachineAgent.msi"

    # Download the Azure Connected Machine Agent
    Invoke-WebRequest -Uri $agentUrl -OutFile $downloadPath

    # Install the Azure Connected Machine Agent
    Start-Process msiexec.exe -ArgumentList "/i $downloadPath /quiet /norestart" -Wait

    # Verify the installation
    Get-Service -Name "himds"
    ```

7. Onboard the Azure Connected machine agent with the ```azcmagent``` CLI tool, with for example device code authentication:
    ```powershell
    & "$env:PROGRAMFILES\AzureConnectedMachineAgent\azcmagent.exe" connect --subscription-id "Production" --resource-group "HybridServers" --location "eastus" --use-device-code
    ```

### Custom Script Extension

[CustomScriptExtension.ps1](./CustomScriptExtension.ps1)

This script will disable the built-in Windows firewall, then download a custom background and add set that background to all of the users on the machine.

### Run Command

[RunCommand.ps1](./RunCommand.ps1)

These commands will add a new malicious user to the machine.

## Demo Defender for DevOps

See misconfigured Bicep file located at [here](main.bicep).

To be able to test the Bicep file follow these steps:
1. Either fork, download or just copy every file within the repo.
2. Make sure to create a new GitHub Action by having the following folder structure:
    ```
    .github 
    ├── workflows 
    │ └── github-actions-demo.yml
    ```
3. The [```github-actions-demo.yml```](./github/workflows/github-actions-demo.yml) is the GitHub Actions file that you will use. This action runs either manually or when we have a Pull Request in the **Main** bransch and consist of ````.bicep``` files.
4. When the GitHub Action have been running, please see the Security tab within the repo to analyze the findings.

> [!TIP]
> Read more about Microsoft Security DevOps GitHub action with IaC
> [Trivy](https://github.com/aquasecurity/trivy)
> [Checkov](https://github.com/bridgecrewio/checkov)
> [Template Analyzer](https://github.com/Azure/template-analyzer)


## Demo Defender for Resource Manager

Pre-reqs for **PowerZure**:
- Windows PowerShell 5 or PowerShell 7
- Azure PowerShell module

### Steps
1. If you want to install PowerShell 7 from Winget follow below steps if you are running Windows 11 or Windows Server 2025. For earlier OS versions, please download and install the MSI file, see (here)[https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#installing-the-msi-package]
    ```powershell
    winget install --id Microsoft.PowerShell --source winget
    ```
2. Start PowerShell 7 or Windows PowerShell as administrator from the start menu.
3. Install Azure PowerShell module
    ```powershell
    Install-Module Az -Force
    ```
4. Disable Defender with the following PowerShell command, add more parameters of your choice:
    ```powershell
    Set-MpPreference `
        -DisableRealtimeMonitoring $true `
        -DisableScriptScanning $true `
        -DisableBehaviorMonitoring $true `
        -DisableIOAVProtection $true `
        -DisableIntrusionPreventionSystem $true
    ```
5. Read up and install [PowerZure](https://github.com/hausec/PowerZure).
6. Look at [New-Backdoor.ps1](./New-AzureBackdoor.ps1) function to create a Service Principal with Global Administrator permissions as a backdoor to Entra ID.