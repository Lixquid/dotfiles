################################################################################
################################### Aliases ####################################
################################################################################

alias calc 'bc -l'
alias clip 'xsel --clipboard'
alias refresh_wifi 'sudo iwlist scan'

alias l 'ls -alhF --color=yes --group-directories-first'

alias apt 'sudo apt'
alias apt-get 'sudo apt-get'
alias dpkg 'sudo dpkg'


## Git ###########################################

alias co 'git checkout'
function com
	git commit -m "$argv"
end
alias coq 'git commit --amend --no-edit'
alias pu 'git push'
alias pl 'git pull'
alias st 'git status'
alias gaa 'git add -A; and git status -sb'
