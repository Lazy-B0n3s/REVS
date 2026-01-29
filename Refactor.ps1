
$Global:outputFolder = "C:\temp\" 
$Global:logType
$Global:logName 

clear-host
#Ask user how they would like to search
function selectLog {

    clear-host
    write-host "How will you find your logs?"
    write-host "[1] for Log Name Search"
    write-host "[2] for Provider Search"
    $logSelect = Read-Host -Prompt "Make a selection"

    if ($LogSelect -eq 1) {
        clear-host
        $logType = 'LogName'
        $logInput = Read-Host -Prompt "Log name?"
        $logName = "*$LogInput*"
        return $logName

    } elseif ($LogSelect -eq 2) {
        clear-host
        $logType = 'ProviderName'
        $logInput = Read-Host -Prompt "Provider name?"
        $logName = "*$LogInput*"
        return $logName
    }
    else {
        Clear-Host
        write-host "$logSelect is not a valid response!" -foregroundcolor red
        Read-Host -Prompt "Press Enter to Retry"
        $confirm = "N"
        $logName = "N"
        
    }
}

function verifyLog($logName) {

    if (!($logName)) {
        $confirm='y'

        return $confirm
    } else {
        Clear-Host
        $confirm = "N"
        Write-Host "Log provider/name is blank! This will pull all Event Viewer logs for the specified period." -ForegroundColor Red
        $confirm = read-host -Prompt "Are you sure you want to continue? (y/n)"

        return $confirm
    }
}


selectLog

verifyLog