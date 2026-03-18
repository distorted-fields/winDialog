# ==============================================================================
# winDialog RMM Execution Script with Text Inputs (NinjaOne Safe)
# ==============================================================================

# 1. Define paths (Using a hidden temp or ProgramData folder is best for the text file)
$WinDialogPath = "C:\ProgramData\PretendCo\winDialog.exe"
$OutputFile    = "C:\ProgramData\PretendCo\assigned_user.txt"

# Verify the executable exists
if (-not (Test-Path $WinDialogPath)) {
    Write-Error "winDialog executable not found at $WinDialogPath. Aborting script."
    exit 1
}

# 2. Define your text blocks and labels
$Title   = "Assigned User Verification"
$Message = "Please enter the **required** information to properly assign your device in our systems."
$Input1  = "Full Name"
$Input2  = "Corporate Email Address"
$Button1 = "Submit"
$Banner  = "https://github.com/distorted-fields/winDialog/blob/main/PretendCoBanner.png?raw=true"

# 3. Build ONE single argument string. 
# We use `" to force PowerShell to pass literal double-quotes to the .exe
$ArgList = "--title `"$Title`" --message `"$Message`" --input1 `"$Input1`" --input2 `"$Input2`" --output `"$OutputFile`" --button1 `"$Button1`" --banner `"$Banner`""

Write-Host "Prompting user with winDialog..."

# 4. Execute the tool and wait for the window to close
$Process = Start-Process -FilePath $WinDialogPath -ArgumentList $ArgList -Wait -PassThru

# 5. Evaluate the user's response
switch ($Process.ExitCode) {
    0 {
        Write-Host "Result: User clicked 'Submit' (Exit Code 0)."
        
        # Check if the output file was successfully created by the app
        if (Test-Path $OutputFile) {
            Write-Host "Successfully captured user input:`n"
            
            # Read the raw data
            $RawData = Get-Content $OutputFile
            
            # Print it to the RMM console
            $RawData | ForEach-Object { Write-Host "  > $_" -ForegroundColor Cyan }
            
            # # IMPORTANT: Delete the file so PII isn't left sitting on the drive
            # Remove-Item $OutputFile -Force
        } else {
            Write-Warning "The output file was not found. The user may have submitted blank data."
        }
        
        exit 0 
    }
    default {
        Write-Warning "Result: Window was closed unexpectedly or crashed (Exit Code $($Process.ExitCode))."
        
        exit 1 
    }
}
