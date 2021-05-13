################################################################################
## Bash Aliases                                                               ##
################################################################################

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias l='ls -alhF --color=yes --group-directories-first'

alias dotfiles='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'

## These commands will never work for anyone but the root user #################

alias apt='sudo apt'
alias apt-get='sudo apt-get'
alias dpkg='sudo dpkg'
