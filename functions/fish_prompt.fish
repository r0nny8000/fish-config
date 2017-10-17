set -g fish_prompt_pwd_dir_length 0

set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_char_upstream_prefix ' '

set __fish_git_prompt_color_prefix black
set __fish_git_prompt_color_suffix black
set __fish_git_prompt_color_branch magenta
set __fish_git_prompt_color_flags magenta
set __fish_git_prompt_color_upstream magenta

function fish_prompt --description 'Write out the prompt'

	set -l last_status $status

    echo
    echo
    echo
    echo

    # User
    set_color brblack
    echo -n (whoami)
    set_color normal

    echo -n ' '

    # Host
    set_color brblack

    if not test $last_status -eq 0
        set_color red
    end

    echo -n (prompt_hostname)
    set_color normal

    echo -n '  '

    # PWD
    set_color blue
    echo -n (prompt_pwd)
    set_color normal

    set_color magenta
	echo (__fish_git_prompt)
    set_color normal


end
