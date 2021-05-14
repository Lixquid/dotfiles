<#
.SYNOPSIS
    Runs Git Commands against the dotfiles repository.
.EXAMPLE
    dotfiles add changed_file.txt
    dotfiles commit -m "Changed the file"
#>
function dotfiles {
    & git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME $args
}
