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

        foreach ($log in $oldLogs) {
            # Define the destination subdirectory with the same name as the source directory
            $sourceDirectoryName = $log.Directory.Name
            $destinationSubDirectory = Join-Path -Path $filerLocation -ChildPath $sourceDirectoryName

            if (-not (Test-Path -Path $destinationSubDirectory)) {
                New-Item -Path $destinationSubDirectory -ItemType Directory | Out-Null
            }

            $destination = Join-Path -Path $destinationSubDirectory -ChildPath $log.Name
            Move-Item -Path $log.FullName -Destination $destination
            LogMessage "Moved $($log.Name) to $destination"
        }

        # ... (rest of the script remains the same)
    } else {
        LogMessage "No log files older than 30 minutes found."
    }
} else {
    LogMessage "D: drive is $freeSpaceBefore% free, no action needed."
}
