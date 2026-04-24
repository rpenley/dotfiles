#Requires -RunAsAdministrator

# Windows dotfiles installer
# Run from an elevated PowerShell:
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\windows\install.ps1

param(
    [switch]$SkipChrisTitus,
    [switch]$SkipWSL,
    [switch]$DryRun
)

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$ErrorActionPreference = "Continue"

$DotfilesDir = Split-Path $PSScriptRoot -Parent

function Write-Status  { param([string]$m) Write-Host "[INFO] $m"    -ForegroundColor Blue }
function Write-Success { param([string]$m) Write-Host "[OK] $m"      -ForegroundColor Green }
function Write-Warn    { param([string]$m) Write-Host "[WARN] $m"    -ForegroundColor Yellow }
function Write-Err     { param([string]$m) Write-Host "[ERROR] $m"   -ForegroundColor Red }

function New-Symlink {
    param([string]$Target, [string]$Link)

    if ($DryRun) { Write-Warn "DRY RUN: symlink $Link -> $Target"; return }

    $parentDir = Split-Path $Link -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path $Link) {
        $existing = Get-Item $Link -Force
        if ($existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $Target) {
            Write-Success "Already linked: $Link"
            return
        }
        $backup = "$Link.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Warn "Backing up: $Link -> $backup"
        Move-Item $Link $backup -Force
    }

    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    Write-Success "Linked: $Link -> $Target"
}

function Install-Winget {
    try { $null = Get-Command winget -ErrorAction Stop; Write-Success "winget present"; return } catch {}
    Write-Status "Installing winget..."
    try {
        $uri = (Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url |
               Where-Object { $_ -like "*.msixbundle" }
        $bundle = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest -Uri $uri -OutFile $bundle
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile "$env:TEMP\VCLibs.appx"
        Add-AppxPackage "$env:TEMP\VCLibs.appx"
        Add-AppxPackage $bundle
        Write-Success "winget installed"
    } catch {
        Write-Err "winget install failed: $($_.Exception.Message)"
    }
}

function Install-Packages {
    $packages = @(
        @{ Id = "Microsoft.WindowsTerminal";    Name = "Windows Terminal" },
        @{ Id = "Microsoft.PowerToys";          Name = "PowerToys" },
        @{ Id = "Mozilla.Firefox";              Name = "Firefox" },
        @{ Id = "Notepad++.Notepad++";          Name = "Notepad++" },
        @{ Id = "7zip.7zip";                    Name = "7-Zip" },
        @{ Id = "ImageGlass.ImageGlass";        Name = "ImageGlass" },
        @{ Id = "PeterPawlowski.foobar2000";    Name = "foobar2000" },
        @{ Id = "vim.vim";                      Name = "Vim" },
        @{ Id = "Neovim.Neovim";                Name = "Neovim" },
        @{ Id = "BurntSushi.ripgrep.MSVC";      Name = "ripgrep" },
        @{ Id = "Git.Git";                      Name = "Git" },
        @{ Id = "Starship.Starship";            Name = "Starship" },
        @{ Id = "eza-community.eza";            Name = "eza" }
    )

    Write-Status "Updating winget sources..."
    if (-not $DryRun) { winget source update }

    foreach ($pkg in $packages) {
        Write-Status "Installing $($pkg.Name)..."
        if ($DryRun) { Write-Warn "DRY RUN: would install $($pkg.Name)"; continue }
        winget install --id $pkg.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

function Install-HackNerdFont {
    Write-Status "Installing Hack Nerd Font..."
    if ($DryRun) { Write-Warn "DRY RUN: would install font"; return }
    try {
        $zip = "$env:TEMP\Hack.zip"
        $dir = "$env:TEMP\HackFont"
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath $dir -Force
        $shell = (New-Object -ComObject Shell.Application).Namespace(0x14)
        Get-ChildItem $dir -Filter "*.ttf" | ForEach-Object { $shell.CopyHere($_.FullName) }
        Remove-Item $zip, $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Hack Nerd Font installed"
    } catch {
        Write-Err "Font install failed: $($_.Exception.Message)"
    }
}

function Enable-WSL {
    Write-Status "Enabling WSL..."
    if ($DryRun) { Write-Warn "DRY RUN: would enable WSL"; return }
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    wsl --set-default-version 2
    Write-Success "WSL enabled (restart required)"
}

function Link-DotFiles {
    Write-Status "Linking dotfiles..."

    $configDir = Join-Path $DotfilesDir "windows\config"

    # PowerShell profile
    New-Symlink -Target (Join-Path $configDir "Microsoft.PowerShell_profile.ps1") -Link $PROFILE

    # Windows Terminal settings (only if WT is installed)
    $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path (Split-Path $wtSettings -Parent)) {
        New-Symlink -Target (Join-Path $configDir "settings.json") -Link $wtSettings
    } else {
        Write-Warn "Windows Terminal not found, skipping settings.json link (install WT first, then re-run)"
    }
}

function Invoke-ChrisTitusScript {
    Write-Status "Running Chris Titus Windows Utility..."
    if ($DryRun) { Write-Warn "DRY RUN: would run CTT"; return }
    try {
        Invoke-RestMethod christitus.com/win | Invoke-Expression
        Write-Success "CTT executed"
    } catch {
        Write-Err "CTT failed: $($_.Exception.Message)"
        Write-Warn "Run manually: irm christitus.com/win | iex"
    }
}

# --- Main ---

Write-Status "Starting Windows dotfiles install..."

Install-Winget
Install-Packages
Install-HackNerdFont
Link-DotFiles

if (-not $SkipWSL) { Enable-WSL }

if (-not $SkipChrisTitus) { Invoke-ChrisTitusScript }

Write-Success "Done!"
Write-Status "Next steps:"
Write-Status "  1. Restart to complete WSL setup"
Write-Status "  2. Install a Linux distro: wsl --install -d Ubuntu"
Write-Status "  3. Open a new PowerShell — starship prompt should load"
