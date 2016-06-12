param(
  [int]$countby = 10,
  [int]$pause = 3,
  [string]$outputStr = "Hi",
  [string]$logPath=""
)

$dateStr = Get-Date -Format yyyyMMddHHss
$logFile = "TstCount-$countby-$pause-$dateStr.log"
$logFilePath=Join-Path $logPath $logFile

"Countby        : $countby" | Add-Content $logFilePath
"Pause          : $pause seconds" | Add-Content $logFilePath
"Description    : $outputStr" | Add-Content $logFilePath
"" | Add-Content $logFilePath
"Date                  Count" | Add-Content $logFilePath
"-------------------   -----" | Add-Content $logFilePath
$i=$countby
 while ($true) {
    Write-Host "Count      : $i"
    "$(get-date) - $i" | Add-Content $logFilePath
    Start-Sleep $pause
    $i += $countby
 }
 