# Set the threshold for D: drive to 85%
$threshold = 85

# Get the current disk usage for D: drive before operations
$diskBefore = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'"
$freeSpaceBefore = [math]::Round(($diskBefore.FreeSpace / $diskBefore.Size) * 100)

# Logging function
function LogMessage {
    param(
        [string]$message
    )
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timeStamp] $message"
}

# Log disk usage before operations
LogMessage "D: drive is $freeSpaceBefore% full before operations."

# Check if D: drive is 85% full or more
if ($freeSpaceBefore -le $threshold) {
    # Define the directory where log files are stored
    $logDirectory = "D:\logs"

    # Get log files older than 30 minutes
    $cutoffTime = (Get-Date).AddMinutes(-30)
    $oldLogs = Get-ChildItem -Path $logDirectory -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoffTime }

    if ($oldLogs.Count -gt 0) {
        LogMessage "$($oldLogs.Count) log files found older than 30 minutes."

        # Define the filer location
        $filerLocation = "//filer/log"

        # Move old log files to the filer location
        foreach ($log in $oldLogs) {
            $destination = Join-Path -Path $filerLocation -ChildPath $log.Name
            Move-Item -Path $log.FullName -Destination $destination
            LogMessage "Moved $($log.Name) to $filerLocation"
        }

        # Compress log files in the filer location
        $compressionPath = Join-Path -Path $filerLocation -ChildPath "logs.zip"
        Compress-Archive -Path $filerLocation\* -DestinationPath $compressionPath
        LogMessage "Log files compressed to $compressionPath"

        # Get the current disk usage for D: drive after operations
        $diskAfter = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'"
        $freeSpaceAfter = [math]::Round(($diskAfter.FreeSpace / $diskAfter.Size) * 100)

        # Log disk usage after operations
        LogMessage "D: drive is $freeSpaceAfter% full after operations."

        # Send an email
        $emailBody = @"
        D: drive usage before operations: $freeSpaceBefore%
        D: drive usage after operations: $freeSpaceAfter%
"@

        $emailParams = @{
            From       = "sender@example.com"
            To         = "faiz@faiz.com"
            Subject    = "Disk Usage Report"
            Body       = $emailBody
            SmtpServer = "smtp.example.com"
        }

        Send-MailMessage @emailParams
    } else {
        LogMessage "No log files older than 30 minutes found."
    }
} else {
    LogMessage "D: drive is $freeSpaceBefore% free, no action needed."
}
