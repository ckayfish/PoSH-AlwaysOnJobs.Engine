####################################################################################
############################### Function  Start-AOJobs #############################
#####
### Takes an Job XmlNode from the pipeline and starts the Job
Function  Start-AOJobs {
  [cmdletbinding()]
  Param ([parameter(ValueFromPipeline)]
    [System.Xml.XmlNode]$jobNode
   )
   Process {
     Write-Host ""
     Write-Host "Initialising $($MyInvocation.MyCommand)"
     $jobName=$jobNode.name.ToString()
     "$(Get-Date) - Starting Job: '$jobName'..." | ac $AOlogFilePath
     Write-Host "Job Name: '$jobName'"
     # Get full file path by combining working directory, relative jobs folder stored, and filename for this job
     $jobPath=[System.IO.Path]::GetFullPath((Join-Path $pwd $jobFolder ))
     $jobFilePath=Join-Path $jobPath $jobNode.filename 
     Write-Host "Job File: $jobFilepath"
     $jobDesc=$jobNode.description.ToString()
     Write-Host "Job Desc: '$jobDesc'"

     $paramsHash=@{}
     $jobNode | Select-Object -ExpandProperty params | `
       Select-Object -ExpandProperty param | `
       foreach { $paramsHash.Add("$($_.pname)","$($_.pvalue)") }
     $paramsHash.Add("logPath","`"$AOlogPath`"")
     $sb = [scriptblock]::create(".{$(get-content $jobFilepath -Raw)} $(&{$args} @paramsHash)")
     $jobExec=Start-Job -Init ([ScriptBlock]::Create("Set-Location '$jobPath'")) -Scriptblock $sb -Name $jobName
    #  Sleep 2
     "$(Get-Date) - Started Job '$jobName'. State = $($jobExec.State)" | ac $AOlogFilePath
     Write-Host "Job State: $($jobExec.State)"
     Write-Host ""
     ## TODO: Send email notification?
   }
}