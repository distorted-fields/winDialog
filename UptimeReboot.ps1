# ==============================================================================

# --- 1. Calculate Midpoint & Uptime ---
# Calculate the Urgent threshold as the exact midpoint, rounded to the nearest whole day
[int]$urgentDays = [Math]::Round(($env:warnDays + $env:criticalDays) / 2.0)

$WinDialogPath = "C:\ProgramData\PretendCo\winDialog.exe"

if (-not (Test-Path $WinDialogPath)) {
    Write-Error "winDialog executable not found at $WinDialogPath. Aborting script."
    exit 1
}

$LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$UptimeDays = (New-TimeSpan -Start $LastBoot -End (Get-Date)).Days

Write-Host "Detected System Uptime: $UptimeDays days."
Write-Host "Active Policy Thresholds - Warn: $WarnDays | Urgent: $UrgentDays (Calculated) | Critical: $CriticalDays"
Write-Host "Force Reboot Policy: $Force_Reboot"

# --- 2. Define Conditional Content ---
$Title   = "System Restart Recommended"
$Button1 = "Reboot Now"
$Button2 = "Later" # Default is to have the Later button
$Banner  = "https://github.com/distorted-fields/winDialog/blob/main/PretendCoBanner.png?raw=true"
$TimeoutSeconds = 0 

# Logic for dynamic messages using the calculated variables
switch ($UptimeDays) {
    { $_ -ge $criticalDays } {
        $Icon    = "https://YOUR-PUBLIC-URL/red-warning.png"
        
        # Check our new toggle to determine how aggressive to be
        if ($env:forceReboot -eq "Yes") {
            $Title   = "CRITICAL: Mandatory Restart Required"
            $Message = "Your device hasn't been restarted in over $CriticalDays days. To maintain security and performance, a reboot is now MANDATORY.`n`nPlease save all work immediately. If you do not make a selection, your computer will automatically restart in 5 minutes."
            $TimeoutSeconds = 300 
            $Button2 = "" # Clears the 'Later' button
        } else {
            # Deferrable version of the Critical prompt
            $Message = "Your device hasn't been restarted in over $CriticalDays days. To maintain security and performance, a reboot is highly recommended.`n`nPlease save your work and restart as soon as possible."
            # We leave $TimeoutSeconds at 0, and $Button2 remains "Later"
        }
    }
    { $_ -ge $urgentDays } {
        $Message = "Your device has been running for $UptimeDays days. Performance may begin to degrade. Please schedule a restart today to ensure your system stays healthy."
        $Icon    = "https://YOUR-PUBLIC-URL/orange-warning.png"
    }
    { $_ -ge $warnDays } {
        $Message = "It has been $UptimeDays days since your last restart. We recommend rebooting soon to apply pending updates and keep things running smoothly."
        $Icon    = "https://YOUR-PUBLIC-URL/green-warning.png"
    }
    Default {
        Write-Host "System uptime ($UptimeDays days) is within healthy limits. No prompt needed."
        exit 0 
    }
}

# --- 3. Construct Arguments & Execute winDialog ---
$ArgList = "--title `"$Title`" --message `"$Message`" --button1 `"$Button1`" --banner `"$Banner`" --icon `"$Icon`""

if (-not [string]::IsNullOrWhiteSpace($Button2)) {
    $ArgList += " --button2 `"$Button2`""
}

Write-Host "Prompting user with winDialog..."
$Process = Start-Process -FilePath $WinDialogPath -ArgumentList $ArgList -PassThru

# --- 4. Handle Timeout Logic ---
if ($TimeoutSeconds -gt 0) {
    Write-Host "Starting $TimeoutSeconds second countdown for critical prompt..."
    try {
        $Process | Wait-Process -Timeout $TimeoutSeconds -ErrorAction Stop
    } catch {
        Write-Warning "User ignored the prompt for 5 minutes. Enforcing reboot."
        if (-not $Process.HasExited) { Stop-Process -Id $Process.Id -Force }
        shutdown.exe /r /t 60 /f /c "Mandatory $CriticalDays-day uptime reboot enforced. You have 60 seconds to save your work."
        exit 0
    }
} else {
    # If Force_Reboot is "No", the script safely waits here indefinitely for a user click.
    $Process | Wait-Process
}

# --- 5. Evaluate Response ---
switch ($Process.ExitCode) {
    0 {
        Write-Host "Result: User clicked 'Reboot Now'. Initiating restart..."
        Restart-Computer -Force
    }
    2 {
        Write-Host "Result: User clicked 'Later'."
        exit 0 
    }
    default {
        Write-Warning "Result: Window closed or timed out (Code: $($Process.ExitCode))."
        
        if ($TimeoutSeconds -gt 0) {
            Write-Warning "User attempted to bypass mandatory prompt. Enforcing reboot."
            shutdown.exe /r /t 60 /f /c "Mandatory $CriticalDays-day uptime reboot enforced. You have 60 seconds to save your work."
        }
        
        exit 1 
    }
}
