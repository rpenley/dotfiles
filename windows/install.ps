#Requires -RunAsAdministrator

# Windows Development Environment Setup Script
# Installs essential tools and configures Windows Terminal with Gruvbox theme

param(
    [switch]$SkipChrisTitus,
    [switch]$SkipWSL,
    [switch]$DryRun
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$ErrorActionPreference = "Continue"

# Colors for output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install winget if not present
function Install-Winget {
    Write-Status "Checking for winget..."
    try {
        $null = Get-Command winget -ErrorAction Stop
        Write-Success "winget is already installed"
        return
    }
    catch {
        Write-Status "Installing winget..."
    }

    # Install winget via Microsoft Store or GitHub
    try {
        $progressPreference = 'silentlyContinue'
        $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
        $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
        
        Write-Status "Downloading winget..."
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage $latestWingetMsixBundle
        
        # Clean up
        Remove-Item $latestWingetMsixBundle -Force -ErrorAction SilentlyContinue
        Remove-Item Microsoft.VCLibs.x64.14.00.Desktop.appx -Force -ErrorAction SilentlyContinue
        
        Write-Success "winget installed successfully"
    }
    catch {
        Write-Error "Failed to install winget: $($_.Exception.Message)"
        Write-Warning "Please install winget manually from the Microsoft Store"
        return
    }
}

# Function to install packages via winget
function Install-Package {
    param(
        [string]$PackageId,
        [string]$Name,
        [string]$Source = "winget"
    )
    
    Write-Status "Installing $Name..."
    
    if ($DryRun) {
        Write-Warning "DRY RUN: Would install $Name ($PackageId)"
        return
    }
    
    try {
        $result = winget install --id $PackageId --source $Source --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed successfully"
        } else {
            Write-Warning "$Name may already be installed or installation had issues"
        }
    }
    catch {
        Write-Error "Failed to install $Name: $($_.Exception.Message)"
    }
}

# Function to enable WSL
function Enable-WSL {
    Write-Status "Enabling WSL..."
    
    if ($DryRun) {
        Write-Warning "DRY RUN: Would enable WSL"
        return
    }
    
    try {
        # Enable WSL and Virtual Machine Platform
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        
        # Set WSL 2 as default
        wsl --set-default-version 2
        
        Write-Success "WSL enabled successfully"
        Write-Warning "A restart may be required for WSL to work properly"
    }
    catch {
        Write-Error "Failed to enable WSL: $($_.Exception.Message)"
    }
}

# Function to install Hack Nerd Font
function Install-HackNerdFont {
    Write-Status "Installing Hack Nerd Font..."
    
    if ($DryRun) {
        Write-Warning "DRY RUN: Would install Hack Nerd Font"
        return
    }
    
    try {
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
        $fontZip = "$env:TEMP\Hack.zip"
        $fontDir = "$env:TEMP\Hack"
        
        # Download font
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
        
        # Extract font
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
        
        # Install fonts
        $fonts = Get-ChildItem -Path $fontDir -Filter "*.ttf"
        $fontFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
        
        foreach ($font in $fonts) {
            $fontFolder.CopyHere($font.FullName)
        }
        
        # Clean up
        Remove-Item $fontZip -Force -ErrorAction SilentlyContinue
        Remove-Item $fontDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Success "Hack Nerd Font installed successfully"
    }
    catch {
        Write-Error "Failed to install Hack Nerd Font: $($_.Exception.Message)"
    }
}

# Function to configure Windows Terminal with Gruvbox theme
function Configure-WindowsTerminal {
    Write-Status "Configuring Windows Terminal with Gruvbox theme..."
    
    if ($DryRun) {
        Write-Warning "DRY RUN: Would configure Windows Terminal"
        return
    }
    
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    
    if (Test-Path $settingsPath) {
        try {
            $settings = Get-Content $settingsPath | ConvertFrom-Json -Depth 100
            
            # Add Gruvbox Dark theme
            $gruvboxTheme = @{
                name = "Gruvbox Dark"
                black = "#282828"
                red = "#cc241d"
                green = "#98971a"
                yellow = "#d79921"
                blue = "#458588"
                purple = "#b16286"
                cyan = "#689d6a"
                white = "#a89984"
                brightBlack = "#928374"
                brightRed = "#fb4934"
                brightGreen = "#b8bb26"
                brightYellow = "#fabd2f"
                brightBlue = "#83a598"
                brightPurple = "#d3869b"
                brightCyan = "#8ec07c"
                brightWhite = "#ebdbb2"
                background = "#282828"
                foreground = "#ebdbb2"
                cursorColor = "#ebdbb2"
                selectionBackground = "#504945"
            }
            
            # Ensure schemes array exists
            if (-not $settings.schemes) {
                $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @()
            }
            
            # Add Gruvbox theme if it doesn't exist
            $existingGruvbox = $settings.schemes | Where-Object { $_.name -eq "Gruvbox Dark" }
            if (-not $existingGruvbox) {
                $settings.schemes += $gruvboxTheme
            }
            
            # Set default font and theme for profiles
            foreach ($profile in $settings.profiles.list) {
                if (-not $profile.font) {
                    $profile | Add-Member -NotePropertyName font -NotePropertyValue @{}
                }
                $profile.font.face = "Hack Nerd Font"
                $profile.colorScheme = "Gruvbox Dark"
            }
            
            # Save settings
            $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding UTF8
            Write-Success "Windows Terminal configured with Gruvbox theme"
        }
        catch {
            Write-Error "Failed to configure Windows Terminal: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Windows Terminal settings file not found. Make sure Windows Terminal is installed and has been run at least once."
    }
}

# Function to run Chris Titus script
function Invoke-ChrisTitusScript {
    Write-Status "Running Chris Titus Windows Utility..."
    
    if ($DryRun) {
        Write-Warning "DRY RUN: Would run Chris Titus script"
        return
    }
    
    try {
        Invoke-RestMethod christitus.com/win | Invoke-Expression
        Write-Success "Chris Titus script executed"
    }
    catch {
        Write-Error "Failed to run Chris Titus script: $($_.Exception.Message)"
        Write-Warning "You can run it manually later with: irm christitus.com/win | iex"
    }
}

# Main installation function
function Start-Installation {
    Write-Status "Starting Windows development environment setup..."
    
    # Check if running as administrator
    if (-not (Test-Administrator)) {
        Write-Error "This script must be run as Administrator!"
        Write-Status "Please right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }
    
    # Install winget first
    Install-Winget
    
    # Update winget sources
    Write-Status "Updating winget sources..."
    if (-not $DryRun) {
        winget source update
    }
    
    # Install packages
    $packages = @(
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" },
        @{ Id = "Microsoft.PowerToys"; Name = "PowerToys" },
        @{ Id = "Mozilla.Firefox"; Name = "Firefox" },
        @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" },
        @{ Id = "7zip.7zip"; Name = "7-Zip" },
        @{ Id = "ImageGlass.ImageGlass"; Name = "ImageGlass" },
        @{ Id = "PeterPawlowski.foobar2000"; Name = "foobar2000" },
        @{ Id = "vim.vim"; Name = "Vim" },
        @{ Id = "Neovim.Neovim"; Name = "Neovim" },
        @{ Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep" },
        @{ Id = "Git.Git"; Name = "Git" }
    )
    
    foreach ($package in $packages) {
        Install-Package -PackageId $package.Id -Name $package.Name
    }
    
    # Install Hack Nerd Font
    Install-HackNerdFont
    
    # Enable WSL if requested
    if (-not $SkipWSL) {
        Enable-WSL
    } else {
        Write-Warning "Skipping WSL installation (use -SkipWSL:$false to enable)"
    }
    
    # Configure Windows Terminal
    Start-Sleep -Seconds 2  # Give Windows Terminal time to install
    Configure-WindowsTerminal
    
    # Run Chris Titus script if requested
    if (-not $SkipChrisTitus) {
        Invoke-ChrisTitusScript
    } else {
        Write-Warning "Skipping Chris Titus script (use -SkipChrisTitus:$false to enable)"
    }
    
    Write-Success "Installation completed!"
    Write-Status "Recommended next steps:"
    Write-Status "1. Restart your computer to complete WSL installation"
    Write-Status "2. Open Windows Terminal to verify Gruvbox theme"
    Write-Status "3. Install a Linux distribution for WSL: wsl --install -d Ubuntu"
    Write-Status "4. Configure your development tools as needed"
}

# Show help
function Show-Help {
    Write-Host @"
Windows Development Environment Setup Script

USAGE:
    .\windows-setup.ps1 [OPTIONS]

OPTIONS:
    -SkipChrisTitus    Skip running the Chris Titus Windows Utility
    -SkipWSL          Skip WSL installation
    -DryRun           Show what would be installed without making changes
    -Help             Show this help message

INSTALLED SOFTWARE:
    • Windows Terminal (with Gruvbox Dark theme)
    • Hack Nerd Font
    • PowerToys
    • Firefox
    • Notepad++
    • ImageGlass
    • foobar2000
    • Vim & Neovim
    • ripgrep
    • Git
    • 7-Zip
    • WSL (Windows Subsystem for Linux)

REQUIREMENTS:
    • Windows 10/11
    • PowerShell 5.1 or later
    • Administrator privileges
    • Internet connection

"@ -ForegroundColor Cyan
}

# Parse parameters and run
if ($args -contains "-Help" -or $args -contains "--help" -or $args -contains "/?") {
    Show-Help
    exit 0
}

# Run the installation
Start-Installation
