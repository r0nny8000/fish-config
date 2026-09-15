function gr --description 'Run a git command across all repos in subdirectories'
    set -l start_dir (pwd)
    set -l projects (find . -name '.git' -type d | path dirname | sort)

    if test (count $projects) -eq 0
        echo
        echo "gr: no git repository below $start_dir"
        return 0
    end

    for project in $projects
        cd $start_dir/$project
        set -l name (string replace -r '^\./' '' -- $project)
        # Prefixing with sed would break here: a nested repo name contains a
        # slash, which ends sed's replacement early.
        set -l prefix (printf "\033[0;35m%-32s\033[0m" $name)
        git $argv 2>&1 | while read -l line
            printf '%s%s\n' $prefix $line
        end
        printf "\n\n"
    end

    cd $start_dir
end
