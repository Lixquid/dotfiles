## Git Util Functions ##########################################################

set -g __fish_prompt_git_ignored_paths "/home/$USER/.git"

function __fish_prompt_git
	# check if git repo
	set -l gp ( command git rev-parse --git-dir ^/dev/null )

	test -z "$gp"
	or contains -- ( readlink -f $gp ^/dev/null ) \
		$__fish_prompt_git_ignored_paths
	and return

	set -l branch_name ( command git symbolic-ref --short HEAD ^/dev/null )

	echo -n " "
	if test -n "$branch_name"
		command git diff --no-ext-diff --quiet --exit-code
			and set_color green
			or set_color yellow

		echo -n $branch_name
	else
		set_color red
		command git show-ref --head -s --abbrev ^/dev/null | \
			head -n1 ^/dev/null | tr -d '\n'
	end
end

################################################################################

# Uses two universal variables:
# fish_prompt_default_user         Does not display this user
# fish_prompt_git_ignored_paths    Paths not to display git info for

set -g __fish_prompt_bg ""

# <text> [bg] [fg]
function __fish_prompt_block
	if test -n $__fish_prompt_bg
		echo -n " "
	end

	switch (count $argv)
		case 1
			echo -n $argv[1]
		case 2
			if test $__fish_prompt_bg = $argv[2]
				echo -n "$argv[1]"
			else
				set __fish_prompt_bg $argv[2]
				set_color -b $argv[2]
				echo -n "$argv[1]"
			end
		case 3
			set_color $argv[3]
			if test $__fish_prompt_bg = $argv[2]
				echo -n $argv[1]
			else
				set __fish_prompt_bg $argv[2]
				set_color -b $argv[2]
				echo -n " $argv[1]"
			end
	end
end

function fish_prompt --description "Writes the current prompt"

	set -l last_status $status
	set __fish_prompt_bg ""

	## User ######################################

	switch $USER
		case root
			__fish_prompt_block (echo "$USER@"(hostname)) red black
		case "$fish_prompt_default_user"
			__fish_prompt_block (hostname) yellow black
		case '*'
			__fish_prompt_block (echo "$USER@"(hostname)) yellow black
	end

	## Background Jobs ###########################

	if test (jobs | wc -l) -gt 0
		__fish_prompt_block J black cyan
	end

	## Return Code ###############################

	if test $last_status != 0
		__fish_prompt_block X red black
		if test $last_status != 1
			__fish_prompt_block $last_status red black
		end
	end

	## Directory #################################

	__fish_prompt_block (echo -n (pwd | sed "s|$HOME|~|")) blue black

	## End Cap ###################################

	echo -n " "
	set_color -b normal
	set_color normal
	echo -n " "

end
