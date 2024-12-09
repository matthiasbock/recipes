
# Using Ansible to manage a Microsoft Windows 10 host

## Install OpenSSH Server for Windows

~~~pwsh
$OPENSSH_VERSION = "0.0.1.0"

# Check if OpenSSH is available
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~$OPENSSH_VERSION

# Start sshd service
Start-Service sshd

# Set to start automatically
Set-Service -Name sshd -StartupType 'Automatic'
~~~

## Configure PowerShell as the default login shell

~~~pwsh
$OPENSSH_REGISTRY_PATH = "HKLM:\SOFTWARE\OpenSSH"
$POWERSHELL_PATH = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

New-ItemProperty -Path $OPENSSH_REGISTRY_PATH -Name DefaultShell -Value $POWERSHELL_PATH -PropertyType String -Force
~~~

