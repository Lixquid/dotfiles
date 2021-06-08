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

## Settings ####################################################################
# Ctrl-D will exit the terminal
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit -ErrorAction SilentlyContinue

## Utility #####################################################################
. $HOME/.dotfiles/powershell/ProfileFunctions.ps1

## Aliases #####################################################################
Set-Alias ue Use-Env
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }
function ...... { Set-Location ../../../../.. }
