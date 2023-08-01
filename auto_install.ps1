Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
New-LocalUser -Name "remote" -FullName "repair" -Description "adm"
Add-LocalGroupMember -Group Администраторы -Member remote
net localgroup "Пользователи удаленного рабочего стола" /add remote
Get-LocalUser
write-host "-"
write-host "выбери пользователя с которого работает USER для подруба RDP"
$login_mic=read-host
net localgroup "Пользователи удаленного рабочего стола" /add $login_mic

Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
New-Item -Path "C:\auto\" -ItemType Directory
New-Item -Path "C:\auto\auto.ps1"
$login_pidr="remote"
$String='$log'
Set-Content -Path "C:\auto\auto.ps1" -Value $String="'"$login_pidr"'"
Add-Content -Path "C:\auto\auto.ps1" -Value "Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass –Force"
write-host "ip NFS server"
$ipnfs=read-host
$String1='$ipnfs'
Add-Content -Path "C:\auto\auto.ps1" -Value $String1="'"$ipnfs"'"
Add-Content -Path "C:\auto\auto.ps1" -Value 'Mount -o anon \\$ipnfs\export\case z:'
Add-Content C:\auto\auto.ps1 'Add-Type -AssemblyName System.Web
$pass = [System.Web.Security.Membership]::GeneratePassword(12,2)
$passhard = ConvertTo-SecureString -String $pass -AsPlainText -Force
Remove-Item "z:$env:computername.txt"
#$pass Remove-Item "z:$env:computername.txt" 
New-Item -Path "Z:$env:computername.txt" 
Set-Content Z:$env:computername.txt "$pass/#-^_^-#$env:computername"
Set-LocalUser -Name $log -Password $passhard 
umount z:'

New-Item -Path "C:\Windows\System32\Tasks\auto-repair" -ItemType Directory
$time = New-TimeSpan -Minutes 60
$Trigger = New-ScheduledTaskTrigger -Once -At 0:00 -RepetitionInterval $time
$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction -Execute "powershell" -Argument "Remove-Item -Path Alias:mount -ErrorAction Ignore | C:\auto\auto.ps1"
Register-ScheduledTask -TaskPath "auto-repair" -TaskName "auto-nfs1" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
$Trigger= New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskPath "auto-repair" -TaskName "auto-nfs2" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force

Get-WindowsCapability -Online | Where-Object Name -like ‘OpenSSH.Server*’ | Add-WindowsCapability –Online
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
Get-NetFirewallRule -Name *OpenSSH-Server* |select Name, DisplayName, Description, Enabled

Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
mkdir c:\script-tmp
clear
Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, BuildNumber | FL
write-host "what arhiticture windows? x32 or x64"
write-host "1= x32 or 2= x64"
$arh=read-host
if($arh -eq 1) {
   Write-Output "x32"
Invoke-WebRequest -URI https://github.com/ikashi-sunhine/pack-vnc-install/raw/main/tightvnc-2.8.81-gpl-setup-32bit.msi -UseBasicParsing -outfile c:\script-tmp\x32.msi
C:\script-tmp\x32.msi
}
elseif ($arh -eq 2) {
    Write-Output "x64"
Invoke-WebRequest -URI https://github.com/ikashi-sunhine/pack-vnc-install/raw/main/tightvnc-2.8.81-gpl-setup-64bit.msi -UseBasicParsing -outfile c:\script-tmp\x64.msi
C:\script-tmp\x64.msi
}
else {
    Write-Output "PISDEC"
}
Wait-Event -Timeout 120
rm -r c:\script-tmp

Set-Service -Name tvnserver -StartupType Manual
Stop-Service -Name tvnserver

mkdir c:\script-tmp

if($arh -eq 1) {
   Write-Output "x32"
Invoke-WebRequest -URI https://github.com/ikashi-sunhine/zabbix-agen-cl/raw/main/zabbix_agent2-6.4.4-windows-i386-openssl.msi -UseBasicParsing -outfile c:\script-tmp\x32.msi
C:\script-tmp\x32.msi
}
elseif ($arh -eq 2) {
    Write-Output "x64"
Invoke-WebRequest -URI https://github.com/ikashi-sunhine/zabbix-agen-cl/raw/main/zabbix_agent2-6.4.4-windows-amd64-openssl.msi -UseBasicParsing -outfile c:\script-tmp\x64.msi
C:\script-tmp\x64.msi
}
else {
    Write-Output "PISDEC"
}
Invoke-WebRequest -URI https://github.com/ikashi-sunhine/smarttools/raw/main/smartmontools7.3.exe -UseBasicParsing -outfile c:\script-tmp\smarttools.exe
C:\script-tmp\smarttools.exe
Wait-Event -Timeout 120
Add-Content -Path "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" -Value 'Plugins.Smart.Path="C:\Program Files\smartmontools\bin\smartctl.exe"'
Get-Service 'Zabbix Agent 2'| Restart-Service -force
Wait-Event -Timeout 160
rm -r c:\script-tmp

