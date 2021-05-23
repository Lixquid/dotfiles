$private:module = Get-Module posh-git -ListAvailable
if ($private:module) {
    Import-Module $private:module
}

$private:module = Get-Module oh-my-posh -ListAvailable
if ($private:module) {
    Import-Module $private:module
    Set-Theme Agnoster
}

. $HOME/.dotfiles/powershell/ProfileFunctions.ps1
