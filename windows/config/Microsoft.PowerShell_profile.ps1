# PowerShell profile
# Linked by windows/install.ps1 to $PROFILE

# Starship prompt
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
Invoke-Expression (&starship init powershell)

# Aliases
Set-Alias -Name vim -Value nvim
function which { Get-Command $args[0] | Select-Object -ExpandProperty Source }
function grep { Select-String $args }

# Better ls
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls   { eza --icons $args }
    function ll   { eza --icons -l $args }
    function la   { eza --icons -la $args }
    function tree { eza --icons --tree $args }
} else {
    function ll { Get-ChildItem -Force $args }
}

# Git shortcuts
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git log --oneline --graph --decorate $args }
