Set-ExecutionPolicy Bypass
$path = "C:\SysmonTriage"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
Write-Host "Clearing the folder if it is not empty..." -ForegroundColor red -BackgroundColor white
Get-ChildItem -Path C:\SysmonTriage\ -Include * -File -Recurse | foreach { $_.Delete()}

Write-Host "[+] Retrieving Sysmon Dns Queries"
Write-Host
$account = @()
$events = Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-Sysmon/Operational"; Id=22}  
ForEach ($event in $events) 
{
    if ($event.Message.Contains("QueryName"))
    {
        $Dictionary = @{}
        $string = $event.Message.ToString()
        $string.Split([environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
        $key,$value = $_.Split(':')
        $Dictionary[$key] =$value
            } 
     }
  $Dictionary.Item("QueryName").Trim() >>  C:\SysmonTriage\dnsQueries.csv
}
