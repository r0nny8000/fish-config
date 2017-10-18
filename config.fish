echo -n init global config... 

set fish_color_autosuggestion BD93F9
set fish_color_cancel \x2dr
set fish_color_command F8F8F2
set fish_color_comment 6272A4
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end 50FA7B
set fish_color_error FFB86C
set fish_color_escape bryellow\x1e\x2d\x2dbold
set fish_color_history_current \x2d\x2dbold
set fish_color_host normal
set fish_color_match \x2d\x2dbackground\x3dbrblue
set fish_color_normal normal
set fish_color_operator bryellow
set fish_color_param FF79C6
set fish_color_quote F1FA8C
set fish_color_redirection 8BE9FD
set fish_color_search_match bryellow\x1e\x2d\x2dbackground\x3dbrblack
set fish_color_selection white\x1e\x2d\x2dbold\x1e\x2d\x2dbackground\x3dbrblack
set fish_color_user brgreen
set fish_color_valid_path \x2d\x2dunderline
set fish_pager_color_completion \x1d
set fish_pager_color_description B3A06D\x1eyellow
set fish_pager_color_prefix white\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
set fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan

set fish_key_bindings fish_default_key_bindings

set fish_greeting 'Welcome'

set -U EDITOR vim

echo done.
source ~/.config/fish/config.local.fish
