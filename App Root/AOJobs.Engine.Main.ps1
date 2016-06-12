##############################################
####### Entry point for AOJobs.Engine ########
##############################################

$svcName="AOJobs.Engine"
$dateStart = Get-Date
Set-Location $PSScriptRoot
Write-Host "Starting       : $svcName"
Write-Host "Date/Time      : $dateStart"
Write-Host "Run Location   : $pwd"

### Including library/function File(s) ###

$libFile="AOJobs.Engine.Library.ps1"
$libFilePath = Join-Path $PSScriptRoot $libFile
Write-Host "Library File   : $libFile"
try {
   . "$libFilePath"
   Write-Host "Library succesfully loaded."
} catch {
   Write-Host "Can't load library file '$libFilePath'"
   Write-Host "Exiting with error 1"
   exit 1
}

### Loading and verifying config file  ###

$configFile = "application.config"
Write-Host "Configuration  : ./$configFile"

if (Test-Path $configFile) {
try{
[xml]$configXml = Get-Content $configFile } catch
 {
   Write-Host "Can't load Config file '$configFile' as XML"
   Write-Host "Exiting with error 3"
   exit 3
}
} else {
   Write-Host "Cant fild config file : $configFile"
   Write-Host "Exiting with error 2"
   exit 2
}
## TODO: VERIFY ENTIRE FILE. Names must be unique

### Setting global variables from config ###

$recheckTime=$configXml.configuration.recheckTime
$jobFolder=$configXml.configuration.jobFolder
$logFolder=$configXml.configuration.logFolder
$dateFormat=$configXml.configuration.dateFormat
$dateStr=$dateStart.ToString($dateFormat)
$AOlogFile = "Start-AOJobs_$dateStr.log"
$AOlogPath = [System.IO.Path]::GetFullPath((Join-Path $pwd $logFolder))
$AOLogFilePath=Join-Path $AOlogPath $AOlogFile

[System.Xml.XmlNodeList]$allConfigJobs = $configXml.SelectNodes("//job") 
Write-Host "Found $($allConfigJobs.Count) jobs in $configFile"
"Found $($allConfigJobs.Count) jobs in $configFile"  | ac $AOLogFilePath
$activeConfigJobs=$allConfigJobs | Foreach {if ($_.Active.ToString().ToUpper() -eq "TRUE") {$_} }
Write-Host "Found $($activeConfigJobs.Count) ACTIVE jobs in $configFile"
"Found $($activeConfigJobs.Count) ACTIVE jobs in $configFile"  | ac $AOLogFilePath

"$(Get-Date) - Starting $svcName" | ac $AOlogFilePath

Write-Host "Starting time  : $dateStart"
Write-Host "Date Format    : $dateFormat"
Write-Host "Wait Seconds   : $recheckTime"
Write-Host "Job Folder     : '$jobFolder'"
Write-Host "Log Folder     : '$logFolder'"

"Starting time  : $dateStart" | ac $AOLogFilePath
"Date Format    : $dateFormat" | ac $AOLogFilePath
"Wait Seconds   : $recheckTime" | ac $AOLogFilePath
"Job Folder     : '$jobFolder'" | ac $AOLogFilePath
"Log Folder     : '$logFolder'" | ac $AOLogFilePath


Write-Host ""
Write-Host "Getting current jobs..."
Get-Job | Select-Object -Property id, name, state | Format-table

##### AlwaysOn While $TRUE #####
While ($true) {
   ######v Clean Up v#####
   Get-Job | where {$_.State -ne "Running"} | Remove-Job
   [System.GC]::Collect()
   ## TODO: More cleanup?
   ######^ Clean Up ^#####
   $CurrentJobs = Get-Job
   Write-Host "Number of Jobs Running: $($CurrentJobs.Count)"
   Write-Host ""
   $CurrentJobNames = $CurrentJobs | Select-Object -ExpandProperty Name
   $activeConfigJobs | foreach {
     ## Start if not running
     If ($CurrentJobNames -eq $Null -or !($CurrentJobNames.Contains($_.name))) {
        "Starting Job: $($_.name)"
        $_ | Start-AOJobs
     } else {    Write-Host "Job '$($_.name)' already running" }
   }
   Write-Host "Waiting $recheckTime seconds"
   Start-Sleep $recheckTime
}
