
$Global:outputFolder = "C:\temp\" 
$Global:logType
$Global:logName
$Global:computerName
$Global:logInput
$Global:Target
$Global:fullpath

clear-host

#Ask user how they would like to search
function selectLog {
    do {
        Clear-Host
        Write-Host "How will you find your logs?"
        Write-Host "[1] for Log Name Search"
        Write-Host "[2] for Provider Search"
        $logSelect = Read-Host -Prompt "Make a selection"

        if ($LogSelect -eq 1) {
            Clear-Host
            $Global:logType = 'LogName'
            $Global:logInput = Read-Host -Prompt "Log name?"
            $Global:logName = "*$logInput*"
            $validSelection = $true
            
        } elseif ($LogSelect -eq 2) {
            Clear-Host
            $Global:logType = 'ProviderName'
            $Global:logInput = Read-Host -Prompt "Provider name?"
            $Global:logName = "*$logInput*"
            $validSelection = $true
            
        } else {
            Clear-Host
            Write-Host "$logSelect is not a valid response!" -ForegroundColor Red
            Read-Host -Prompt "Press Enter to Retry"
            $validSelection = $false
        }
    } while (-not $validSelection)
}

#Verify logName is not null or less than 4 characters
function verifyLog {
    if (!($Global:logName)){
        Clear-Host
        $confirm = "n"
        Write-Host "Log provider/name is blank! This will pull all Event Viewer logs for the specified period." -ForegroundColor Red
        $confirm = read-host -Prompt "Are you sure you want to continue? (y/n)"

        if ($confirm -ne 'y') {
            selectLog
        }
    } 
}

function verifyLogLength($logName) {
    if ($Global:logName.length -lt 4) {
        Write-Host "Log provider/name is less than 4 characters! This will likely pull a large amount of logs" -ForegroundColor Red
        $confirm = read-host -Prompt "Are you sure you want to continue? (y/n)"

        If ($confirm -ne 'y') {
            selectLog
        }
        
    } 
}

#Select date range, computer name and file path to save log
function selectDateRange {
    do {
        Clear-Host
        $DateInput = Read-Host "How many days back?"
        $Global:Target = (Get-Date).AddDays(-"$DateInput") 
        Clear-Host
        $Global:ComputerName = Read-Host "Computer name?"
        Clear-Host
        Write-Host "Computer Name: $Global:computerName"
        Write-Host $Global:logType ":" $Global:logInput
        Write-Host "Log Age: Starting from $Global:Target"
        $Confirm = Read-Host -Prompt "Is this Correct? (y/n)"
        
    } while ($Confirm -ne 'y')  # Loop through until user confirms
    
    $filename = "{0}_{1}_{2}.csv" -f ($Global:computerName -replace '\.',""),($Global:logInput -replace '\.',""),(Get-Date -Format "yyyyMMddHHmmss")
    $Global:fullpath = Join-Path $Global:outputFolder $filename  
}

#Create the log 
function createLog {
    try {
        Write-Host "Retrieving events, please wait"
        $Output = Get-WinEvent -FilterHashtable @{
            $Global:logType = $Global:logName
            StartTime = $Global:Target
            EndTime = Get-Date
        } -ComputerName $Global:computerName -ErrorAction Stop |
            Select-Object -Property recordid, timecreated, level, userid, processid, id, containerlog, logname, message
        
        $Output | Export-Csv -Path $Global:fullpath -Encoding utf8
        Clear-Host
        Write-Host "Done! Export $Global:fullpath has been created"
    }
    catch {
        Clear-Host
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "An error has occurred during the fetch, no file was created"
    }
    finally {
        $restart = Read-Host "Run new search? (y/n)"
        if ($restart -eq 'y') {
            # Re-run the entire script if user wants to restart the script 
            selectLog
            verifyLog 
            verifyLogLength
            selectDateRange
            createLog
        }
    }
}

#Acivate the functions to run the script 
selectLog
verifyLog 
verifyLogLength
selectDateRange
createLog