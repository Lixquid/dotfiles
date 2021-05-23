## Modules #####################################################################
$private:module = Get-Module posh-git -ListAvailable
if ($private:module) {
    Import-Module $private:module
}

$private:module = Get-Module oh-my-posh -ListAvailable
if ($private:module) {
    Import-Module $private:module
    Set-Theme Agnoster
}

## Tooling #####################################################################

# Rust
$private:cargo = $env:CARGO_HOME
if (-not $private:cargo) {
    $private:cargo = Join-Path $HOME .cargo
}
$private:cargo = Join-Path $private:cargo bin
if (Test-Path -LiteralPath $private:cargo -PathType Container) {
    $env:PATH = $private:cargo + ":" + $env:PATH
}

## Utility #####################################################################
. $HOME/.dotfiles/powershell/ProfileFunctions.ps1
