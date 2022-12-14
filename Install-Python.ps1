### Install Python on the local computer
### Must be run from an Administrator Console
### Create Variables
Set-StrictMode -Version 2.0
$SubscriptionName = "Azure Pass"                                 	# Replace with the name of your preferred subscription
$WorkFolder = "C:\Labfiles.55315\"
[Environment]::SetEnvironmentVariable("WORKFOLDER", $WorkFolder, "Machine")
If (-NOT (Test-Path $WorkFolder)) {New-Item -ItemType Directory -Path $WorkFolder} Else {Write-Output "$WorkFolder already exists."}
Set-Location $WorkFolder

### Install Python 3.7.0
# Use TLS 1.2 for site security
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PythonDownloadFile = $WorkFolder + "python-3.7.0-amd64.exe"
$PythonInstallFolder = "C:\Program Files\Python370"
$PythonURL = "https://www.python.org/ftp/python/3.7.0/python-3.7.0-amd64.exe"
(New-Object System.Net.WebClient).DownloadFile($PythonURL, $PythonDownloadFile) 
&$PythonDownloadFile /Passive InstallAllUsers=1 PrependPath=1 Include_Test=0 TargetDir=$PythonInstallFolder

### Upgrade pip.  A new PowerShell Administrator console should be opened to run this command.
Start-Sleep 30
python -m pip install --upgrade pip

### Install Python modules using pip.  A new PowerShell Administrator console should be opened to run this command.
Start-Sleep 30
pip install --upgrade pandas pandas_datareader scipy matplotlib pyodbc pycountry azure azure-cli

### Verify installed modules
# pip list

### Install Bash on Windows 
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

