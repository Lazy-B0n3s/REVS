# First Do - While loop that goes on until var $restart = '(y|yes)'
do
{
    clear-host
    $outputfolder = "C:\temp\"
    # Second loop going until var $Confirm = (y|yes)
    do  {  

        do  { 
            clear-host
            write-host "How will you find your logs?"
            write-host "[1] for Log Name Search"
            write-host "[2] for Provider Search"
            $LogSelect = Read-Host "Make a selection"

            switch($LogSelect) {
                1 {
                    clear-host
                    $LogType = 'LogName'
                    $Loginput = Read-Host "Log name?"
                    $LogName = "*$LogInput*"
                    break
                } 2 {
                    clear-host
                    $LogType = 'ProviderName'
                    $Loginput = Read-Host "Provider name?"
                    $LogName = "*$LogInput*"
                    break
                } Default {
                    Clear-Host
                    write-host "$LogSelect is not a valid response!" -foregroundcolor red
                    read-host "Press Enter to Retry"
                    $Confirm = "N"
                    $LogName = "N"
                    continue
                }
            }

            if($Null -eq $LogName)
                {   
                    Clear-Host
                    $Confirm = "N"
                    Write-Host "Log provider/name is blank! This will pull all Event Viewer logs for the specified period." -ForegroundColor Red
                    $Confirm = read-host "Are you sure you want to continue? (y/n)"
                }else{$Confirm='y'}
            if( 4 -gt $LogName.length)
                {   
                    Clear-Host
                    $Confirm = "N"
                    Write-Host "Log provider/name is less than 4 characters! This will likely pull a large amount of logs" -ForegroundColor Red
                    $Confirm = read-host "Are you sure you want to continue? (y/n)"
                }else{$Confirm='y'}
        } until($Confirm -match '(y|yes)')


        clear-host
        $DateInput = Read-Host "How many days back?"
        $Target = (get-date).AddDays(-"$DateInput")
        clear-host
        $ComputerName = Read-Host "Computer name?"
        clear-host
        write-host "Computer Name: $ComputerName"
        Write-host "${Logtype}: $LogInput"
        write-host "Log Age: Starting from $target"
        $Confirm = "N"
        $Confirm = read-host -prompt "Is this Correct? (y/n)"
        $filename = "{0}_{1}_{2}.csv" -f ($ComputerName -replace '\.',""),($loginput -replace '\.',""),(get-date -format "yyyyMMddHHmmss")
        $fullpath = Join-path $outputfolder $filename
    } until($Confirm -match '(y|yes)')

    try
    {
        write-host "Retrieving events, please wait"
        $Output = Get-WinEvent -FilterHashtable @{
            "$LogType"=$LogName
            StartTime=$Target
            EndTime=Get-Date} -ComputerName $ComputerName -erroraction stop|
                select-object -Property recordid,timecreated,level,userid,processid,id,containerlog,logname,message
            $Output|export-csv -path $fullpath -Encoding utf8
        clear-host
        Write-Host "Done! Export $Fullpath has been created"
    }

    catch
    {
        Clear-Host
        write-host "$PSitem.Exception"
        Write-Host "An error has ocurred during the fetch, no file was created"
        }

    finally{$restart = Read-Host "Run new search? (y/n)"}

    } while ($restart -match '(y|yes)')
