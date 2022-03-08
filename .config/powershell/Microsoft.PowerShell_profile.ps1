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

    ## SSH Agent ###############################################################
    $sshAgentSocket = "/tmp/.sshAgentSocket"
    $env:SSH_AUTH_SOCK = $sshAgentSocket
    $sshAgent = Get-Process ssh-agent -EA SilentlyContinue
    if (!$sshAgent) {
        if (Test-Path $sshAgentSocket -PathType Leaf) {
            Remove-Item $sshAgentSocket -Force
        }

        $agentProcess = Start-Process ssh-agent `
            -ArgumentList @("-a", $sshAgentSocket) `
            -PassThru

        $env:SSH_AGENT_PID = $agentProcess.Id

	echo "ID: $env:SSH_AGENT_PID SOCK: $env:SSH_AUTH_SOCK"
        & ssh-add
    } else {
        $env:SSH_AGENT_PID = $sshAgent.Id
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

function vinix { sudo vim /etc/nixos/configuration.nix }
