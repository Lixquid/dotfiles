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

}

## Utility #####################################################################
. $HOME/.dotfiles/powershell/ProfileFunctions.ps1

## Aliases #####################################################################
Set-Alias ue Use-Env
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }
function ...... { Set-Location ../../../../.. }
