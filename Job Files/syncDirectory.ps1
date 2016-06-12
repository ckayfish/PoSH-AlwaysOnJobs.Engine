param(
   [string]$sourceDir = "..\Sync Test\Source",
   [string]$destDirsCsv = "..\Sync Test\Dest1,..\Sync Test\Dest2",
   [int]$pause = 2,
   [string]$logPath=""
)
write-host "logPath   : $logPath"
$dateStr = Get-Date -Format yyyyMMddHHss
$logFile = "SyncDir-$dateStr.log"
$logFilePath=Join-Path $logPath $logFile

$destList=$destDirsCsv.Split(",").Trim()

[string[]]$cmdAction = @("/MIR")
[string[]]$cmdOptions = @("/R:2", "/W:3", "/NFL", "/NDL","/Z", "/MT")

Write-Host "Log file: $logFilePath"
Write-Host "Source : '$sourceDir'"
Write-Host "Destinations"
Write-Host "------------"     
$destList | format-list
Write-Host "Executing at : $pwd" 

"Starting Time: $dateStr" | ac $logFilePath
"Executing at : $pwd" | ac $logFilePath
"Source       : $sourceDir" | ac $logFilePath
"Pause        : $pause" | ac $logFilePath
"Destinations ($($destList.Count))" | ac $logFilePath
"--------------------------------" | ac $logFilePath
while ($true) {
   Write-Host ""
   Write-host "---- Source Location -----"
   Write-Host "$sourceDir" 
   Write-host "------ Destinations ------"
   $destList | Format-list
   $destList | foreach {
      [string[]]$cmdArgs = @("$sourceDir", "$_", $cmdAction)
      $cmdArgs += $cmdOptions
      "$(get-date) - Executing: robocopy.exe $cmdArgs" | ac $logFilePath
      $roboResult=robocopy.exe $cmdArgs  
      $LastExitCode =  if ($LastExitCode -lt "8") { 0 } else { 1 }
      $roboFiles=$roboResult -match '^(?= *?\b(Files)\b)((?!    Files).)*$'
      Write-Host $roboFiles
      $roboFiles | ac $logFilePath
   }
Write-Host "Pausing $pause seconds..."
Start-Sleep $pause
}