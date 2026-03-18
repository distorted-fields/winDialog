# ==============================================================================
# winDialog RMM Execution Script (NinjaOne Safe)
# ==============================================================================

$WinDialogPath = "C:\ProgramData\PretendCo\winDialog.exe"


if (-not (Test-Path $WinDialogPath)) {
    Write-Error "winDialog executable not found at $WinDialogPath. Aborting script."
    exit 1
}

# 1. Define your text blocks as variables first to keep things clean
$Title   = "System Restart Recommended"
$Message = "Your device hasn't been restarted in 4 days. To ensure you receive the latest security updates and maintain performance, company policy requires a reboot every 30 days.`n`nPlease save your work and select Reboot Now, or click Later to restart at a more convenient time today."
$Button1 = "Reboot Now"
$Button2 = "Later"
$Banner  = "https://github.com/distorted-fields/winDialog/blob/main/PretendCoBanner.png?raw=true"
$Icon    = ""
$Width   = ""
$Height  = ""

# 2. Build ONE single argument string. 
# We use `" to force PowerShell to pass literal double-quotes to the .exe
$ArgList = "--title `"$Title`" --message `"$Message`" --button1 `"$Button1`" --button2 `"$Button2`" --banner `"$Banner`" --icon `"$Icon`""

Write-Host "Prompting user with winDialog..."

# 3. Execute with the single, heavily-quoted string
$Process = Start-Process -FilePath $WinDialogPath -ArgumentList $ArgList -Wait -PassThru




# 4. Evaluate the user's response
switch ($Process.ExitCode) {
    0 {
        Write-Host "Result: User clicked 'Reboot Now' (Exit Code 0)."
        # Insert reboot logic
        exit 0 
    }
    2 {
        Write-Host "Result: User clicked 'Later' (Exit Code 2)."
        # Insert deferral logic
        exit 0 
    }
    default {
        Write-Warning "Result: Window was closed unexpectedly (Exit Code $($Process.ExitCode))."
        exit 1 
    }
}
