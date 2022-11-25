### Manual setup of 55315AC
### Prerequisites:
# 1. Create Student account
# 2. Install SQL Server Developer: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
# 3. Install SQL Server Management Studio (SSMS 18.x.x): https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16
# 4. Install a PDF and Excel viewer (e.g. LibreOffice at www.libreoffice.org)
# 5. Enable PowerShell Script execution (e.g. Set-ExecutionPolicy Unrestricted)
# 6. Copy the course setup archive (55315A-ENU_PowerShellSetup.zip) to the $WorkFolder location designated in the next section.

# Copy From File Share Using Mapped Network Drive
$WorkFolder = 'C:\Labfiles.55315\' 
$LabFilesFolder = 'C:\Labfiles.55315\'
New-Item -Path $WorkFolder -Type Directory -Force
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/neiltucker/ccc/master/55315A-ENU_PowerShellSetup.zip -OutFile $DesktopPath"55315A-ENU_PowerShellSetup.zip"
Copy-Item $DesktopPath"\55315A-ENU_PowerShellSetup.zip" $WorkFolder"55315A-ENU_PowerShellSetup.zip"

# Configure Remote Settings
Net User /Add Adminz Pa$$wordPa$$w0rd /y
Net LocalGroup /Add Administrators Adminz
Net LocalGroup "Remote Management Users" /Add Adminz Student
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Enable-PSRemoting -SkipNetworkProfileCheck -Force
# Set-WSManQuickConfig -Force

# Configure Lab Environment
Enable-NetFirewallRule -DisplayName "File and Printer Sharing*"
New-Item -Path C:\Classfiles -Type Directory -Force -ErrorAction "SilentlyContinue"
New-Item -Path C:\Temp -Type Directory -Force -ErrorAction "SilentlyContinue"
New-Item -Path C:\CustomScriptExtension -Type Directory -Force -ErrorAction "SilentlyContinue"
New-Item -Path C:\AdventureWorks -Type Directory -Force -ErrorAction "SilentlyContinue"
$SetupFile = $WorkFolder + "55315A-ENU_PowerShellSetup.zip"
$Classfiles = "C:\Classfiles\"
[Environment]::SetEnvironmentVariable("LABFILESFOLDER", $WorkFolder, "Machine")
[Environment]::SetEnvironmentVariable("WORKFOLDER", $WorkFolder, "Machine")
If ((Get-PSRepository -Name PSGallery).InstallationPolicy = "Trusted") {Write-Output "PSGallery is already a trusted repository"} Else {Set-PSRepository -Name PSGallery -InstallationPolicy Trusted}
If (Get-PackageProvider -Name NuGet) {Write-Output "NuGet PackageProvider already installed."} Else {Install-PackageProvider -Name "NuGet" -Force}
If (Get-Module -ListAvailable -Name PowerShellGet) {Write-Output "PowerShellGet module already installed"} Else {Find-Module PowerShellGet -IncludeDependencies | Install-Module -Force}
If (Get-Module -ListAvailable -Name SQLServer) {Write-Output "SQLServer module already installed" ; Import-Module SQLServer} Else {Install-Module -Name SQLServer -AllowClobber -Force ; Import-Module -Name SQLServer}
Expand-Archive -LiteralPath $SetupFile -DestinationPath $WorkFolder -Force -ErrorAction "SilentlyContinue"

# Download AdventureWorks databases, unblock and copy files
Write-Output "Download AdventureWorks & AdventureWorksDW backup files"
& $WorkFolder\adventureworks_download.ps1
& $WorkFolder\adventureworksdw_download.ps1
Get-ChildItem -Path $WorkFolder -Recurse |  Unblock-File 
Copy-Item -Path $WorkFolder"*" -Destination $Classfiles -Recurse -Force -ErrorAction "SilentlyContinue"

# Install & Configure applications
$PrintToPDF = Get-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features
# $NetFx3 = Get-WindowsOptionalFeature -Online -FeatureName NetFx3
if($PrintToPDF.State -ne "Enabled"){Enable-WindowsOptionalFeature -Online -Featurename Printing-PrintToPDFServices-Features -All}
# if($NetFx3.State -ne "Enabled"){Enable-WindowsOptionalFeature -Online -Featurename Netfx3 -All}
Import-Module -Name SQLSERVER -Force
Set-Location SQLServer:\SQL\localhost
Invoke-SQLCMD -Inputfile c:\labfiles.55315\Tools\SQLServerConfig_Manual.sql
Set-Location $WorkFolder
Set-Service -Name SQLServerAgent -StartupType Automatic
Start-Service -Name SQLServerAgent
& $WorkFolder\Updatehelp.ps1

# Finish Setup
Start-Sleep 10
Write-Output "Setup Complete."
Write-Output "Verify setup by trying the demonstration exercise in Module 1."
