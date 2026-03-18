# winDialog

> **A Windows take on [swiftDialog](https://github.com/swiftDialog/swiftDialog) — built by an Apple Endpoint Engineer who refused to let Windows have all the boring popups.**

I'm a Mac admin at heart. When I discovered swiftDialog, I fell in love with how easy it made user-facing dialogs. Then someone handed me a Windows environment and I thought: *why do all these prompts look like Windows 98?* So I vibe coded this little tool into existence. It's not perfect, but it gets the job done.

---

## Installation

1. Download `winDialog.exe`
2. Drop it somewhere stable — we recommend:
   ```
   C:\ProgramData\PretendoCo\winDialog.exe
   ```
3. That's it. No installer, no dependencies, no drama.

---

## Usage

### Step 1 — Define your variables

Set up your content as variables first. Empty variables are safely ignored.

```powershell
$WinDialogPath = "C:\ProgramData\Pretendco\winDialog.exe"

$Title   = "System Restart Recommended"
$Message = "Your device hasn't been restarted in 4 days. To ensure you receive the latest security updates and maintain performance, company policy requires a reboot every 30 days.`n`nPlease save your work and select Reboot Now, or click Later to restart at a more convenient time today."
$Button1 = "Reboot Now"
$Button2 = "Later"
$Banner  = "https://github.com/Techvera-MSP/branding-files/blob/main/Techvera-Banner.png?raw=true"
$Icon    = ""
$Width   = "1600"
$Height  = "600"
```

### Step 2 — Build the argument string

Combine everything into a single argument string. The backtick-quotes force PowerShell to pass literal double-quotes to the `.exe`.

```powershell
$ArgList = "--title `"$Title`" --message `"$Message`" --button1 `"$Button1`" --button2 `"$Button2`" --banner `"$Banner`" --icon `"$Icon`" --width `"$Width`" --height `"$Height`""
```

### Step 3 — Launch the dialog

```powershell
$Process = Start-Process -FilePath $WinDialogPath -ArgumentList $ArgList -Wait -PassThru
```

### Step 4 — Handle the response

winDialog communicates the user's choice via exit code.

```powershell
switch ($Process.ExitCode) {
    0 {
        Write-Host "Result: User clicked 'Reboot Now' (Exit Code 0)."
        # Insert reboot logic here
        exit 0
    }
    2 {
        Write-Host "Result: User clicked 'Later' (Exit Code 2)."
        # Insert deferral logic here
        exit 0
    }
    default {
        Write-Warning "Result: Window was closed unexpectedly (Exit Code $($Process.ExitCode))."
        exit 1
    }
}
```

---

## Parameters

| Parameter  | Description                              | Required |
|------------|------------------------------------------|----------|
| `--title`  | Dialog window title                      | No       |
| `--message`| Body text (supports `` `n `` for newlines) | No     |
| `--button1`| Primary button label                     | No       |
| `--button2`| Secondary button label                   | No       |
| `--banner` | URL or local path to a banner image      | No       |
| `--icon`   | URL or local path to an icon image       | No       |
| `--width`  | Dialog width in pixels                   | No       |
| `--height` | Dialog height in pixels                  | No       |

> All parameters are optional — empty values are omitted from the rendered dialog.

---

## Exit Codes

| Code | Meaning                        |
|------|--------------------------------|
| `0`  | User clicked Button 1          |
| `2`  | User clicked Button 2          |
| Other | Window closed unexpectedly   |

---

## Inspiration

This tool was inspired by **[swiftDialog](https://github.com/swiftDialog/swiftDialog)** — the gold standard for user-facing dialogs in macOS/Jamf environments. If you're a Mac admin and haven't checked it out, you're missing out.
