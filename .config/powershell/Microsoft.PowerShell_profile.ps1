Invoke-Command {

    ## Modules #################################################################
    $module = Get-Module posh-git -ListAvailable
    if ($module) {
        Import-Module $module
    }

    $module = Get-Module oh-my-posh -ListAvailable
    if ($module) {
        Import-Module $module
        Set-Theme Agnoster
    }

    ## Tooling #################################################################

    # Rust
    $cargo = $env:CARGO_HOME
    if (-not $cargo) {
        $cargo = Join-Path $HOME .cargo
    }
    $cargo = Join-Path $private:cargo bin
    if (Test-Path -LiteralPath $cargo -PathType Container) {
        $env:PATH = $cargo + ":" + $env:PATH
    }

}

## Utility #####################################################################
. $HOME/.dotfiles/powershell/ProfileFunctions.ps1
