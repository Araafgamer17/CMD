# Requires Administrator privileges
# Run-As-Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "[!] Restarting PowerShell as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Clear terminal screen
Clear-Host

# Header Display
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "        MY CUSTOM WINDOWS SETUP TOOL            " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Function to Install Software via Winget
function Install-Apps {
    Write-Host "[+] Installing common software via Winget..." -ForegroundColor Yellow
    
    # List software IDs you want to install
    $apps = @(
        "7zip.7zip",
        "Git.Git",
        "VideoLAN.VLC"
    )

    foreach ($app in $apps) {
        Write-Host "--> Installing $app..." -ForegroundColor Cyan
        winget install --id $app -e --source winget --accept-package-agreements --accept-source-agreements
    }
    Write-Host "[✓] App installation complete!" -ForegroundColor Green
}

# Function for Windows Tweaks
function Apply-Tweaks {
    Write-Host "[+] Applying performance tweaks..." -ForegroundColor Yellow
    
    # Example Tweak: Show File Extensions in Windows Explorer
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    
    # Example Tweak: Set Power Plan to High Performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    Write-Host "[✓] Tweaks applied successfully!" -ForegroundColor Green
}

# Interactive Menu Loop
do {
    Write-Host "Please select an option:" -ForegroundColor White
    Write-Host "1) Install Essential Apps" -ForegroundColor Cyan
    Write-Host "2) Apply Windows Tweaks" -ForegroundColor Cyan
    Write-Host "3) Run Both" -ForegroundColor Cyan
    Write-Host "Q) Quit" -ForegroundColor Red
    Write-Host ""
    
    $input = Read-Host "Enter choice"

    switch ($input) {
        '1' { Install-Apps }
        '2' { Apply-Tweaks }
        '3' { 
            Install-Apps 
            Apply-Tweaks 
        }
        'Q' { Write-Host "Exiting script..." -ForegroundColor Yellow; break }
        'q' { Write-Host "Exiting script..." -ForegroundColor Yellow; break }
        default { Write-Host "Invalid option, please try again." -ForegroundColor Red }
    }
    
    Write-Host ""
} while ($input -ne 'Q' -and $input -ne 'q')
