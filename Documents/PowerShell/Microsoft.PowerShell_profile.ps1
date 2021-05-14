$module = Get-Module posh-git -ListAvailable
if ($module) {
    Import-Module $module
}

$module = Get-Module oh-my-posh -ListAvailable
if ($module) {
    Import-Module $module
    Set-Theme Agnoster
}
