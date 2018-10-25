# Description: Boxstarter Script
# Author: Microsoft
# chocolatey fest demo

Disable-UAC
$ConfirmPreference = "None" #ensure installing powershell modules don't prompt on needed dependencies

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$strpos = $helperUri.LastIndexOf("/demos/")
$helperUri = $helperUri.Substring(0, $strpos)
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

#--- Setting up Windows ---
executeScript "FileExplorerSettings.ps1";
executeScript "SystemConfiguration.ps1";
executeScript "RemoveDefaultApps.ps1";
executeScript "CommonDevTools.ps1";
executeScript "Browsers.ps1";

executeScript "HyperV.ps1";
RefreshEnv
# --- Executing WSL Script ---
# executeScript "WSL.ps1";

# choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

#--- Ubuntu ---
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
# run the distro once and have it install locally with root user, unset password

RefreshEnv
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y

# --- End of WSL Script ---
RefreshEnv
executeScript "Docker.ps1";

choco install -y powershell-core
choco install -y azure-cli
Install-Module -Force Az
Install-Module -Force posh-git
choco install -y microsoftazurestorageexplorer
choco install -y terraform

# Get NodeJS
choco install -y nodejs.install
RefreshEnv

# Install tools in WSL instance
write-host "Installing tools inside the WSL distro..."
Ubuntu1804 run apt install ansible -y

## Install NodeJS on WSL
Ubuntu1804 run curl -sL https://deb.nodesource.com/setup_8.x | bash -
Ubuntu1804 run apt-get install -y nodejs

# checkout recent projects
mkdir C:\github
cd C:\github
git.exe clone https://github.com/microsoft/windows-dev-box-setup-scripts
git.exe clone https://github.com/microsoft/winappdriver
git.exe clone https://github.com/microsoft/wsl
git.exe clone https://github.com/PowerShell/PowerShell

## Get a NodeJS Demo
git.exe clone https://github.com/gtsopour/nodejs-shopping-cart.git
cd C:\github\nodejs-shopping-cart
npm install
Ubuntu1804 run npm install

# set desktop wallpaper
Invoke-WebRequest -Uri 'http://chocolateyfest.com/wp-content/uploads/2018/05/img-bg-front-page-header-NO_logo-opt.jpg' -Method Get -ContentType image/jpeg -OutFile 'C:\github\chocofest.jpg'
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value 'C:\github\chocofest.jpg'
rundll32.exe user32.dll, UpdatePerUserSystemParameters
RefreshEnv

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
