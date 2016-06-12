# PoSH:AOJobs.Engine
Powershell engine that robustly ensures your scripts/jobs are always running. Jobs that have a limited lifetime will
be restarted on a given cycle; scripts that are intended to be "always running" will be restarted if they happen to fail.

Monitor config items in real time, and be confidant that your jobs are never down for more than seconds.

Examples:
1) Replicate file system changes as soon as they occur in a master location
2) Monitor results of a webservice/filesystem to initiate a workflow in real time
3) Home automation. E.g. Turn on night-light when a luminocity sensor is below X. Turn off/on TV when video box is turned off/on
		  
## Getting Started

Place all files into the folder structure as organized in the project (you can define locations later if desired).
Launch with the sample jobs by running `& .\AOJobs.Engine.Main.ps1` in the "App Root" folder.

Most simply, after saving the project to a desired location:
 1) Use Powershell ISE to run `& .\AOJobs.Engine.Main.ps1`
 2) Watch as jobs start
 3) Use Windows Task Manager to stop a powershell.exe process
 4) Watch as it is restarted seconds later
 5) Stop script execution, and type `Get-Job` to see your jobs are still running
 6) Use `receive-job [id]` to get the host output for that a specific job id
 7) Use `get-job | stop job` to stop all jobs
 8) Run `\AOJobs.Engine.Main.ps1` again to see all jobs restarted 

Check `..\Job Logs\` for logged output.

To add your own PoSH scripts, place them in `.\Job Files\` and then edit `.\App Root\application.config` to create your <job> node.

### Prerequisities

Powershell v4+ is excpected. Please let me know if you identify any specific pre-requisites

### Installing

No installer suggested right now, and you can launch `.\App Root\AOJobs.Engine.Main.ps1` however you like. Interactive, background process,
Jenkins Job, Windows Scheduled Task, create a service, etc. Tell us how you like to run `AOJobs.Engine`!

## Package Description

- .\AOJobs.Engine\              # Service Root
- .\AOJobs.Engine\readme.md     # This file
- .\AOJobs.Engine\App Root\     # Core Engine
- .\AOJobs.Engine\Job Files\    # ps1 PoSH scripts 
- .\AOJobs.Engine\Log Files\    # Default location for all log files
- .\AOJobs.Engine\Sync Test\    # Used for example of sync'ing director paths
 
## Creating your Own Job
- Write your ps1 script file
-- All jobs are executed in the working directory defined for Jobs
-- All jobs are passed at least 1 parameter `logPath` which is the full directory path to where logs are gennerally created. Your scripts should receive this paramater and create its log file there
-- Other paramaters your script recieves can by defined in the applications.config file in your job node
-- Add a job node to `application.config` defining your job name, description, active (0/1), script file and parameters
--- Job Names must be unique.


     <job>
        <name>Sync Folders - Sample</name>
        <description>Example of sync'ing relative folders. UNC or FullPaths also accepted</description>
        <fileName>syncDirectory.ps1</fileName>
        <active>TRUE</active>
        <params>
            <param>
               <pname>sourceDir</pname>
               <pvalue>"..\Sync Test\Source"</pvalue>
            </param>
            <param>
               <pname>destDirsCsv</pname>
               <pvalue>"..\Sync Test\Dest1,..\Sync Test\Dest2"</pvalue>
            </param>
            <param>
               <pname>pause</pname>
               <pvalue>3</pvalue>
            </param>
        </params>
     </job>


vvvvvvvvvvvvvvvvvvvvvvvvv

More to come. Comments can be added here or (for now) sent directly to me, Curtis, at ckayfish@gmail.com
