function gr
    set -l start_dir (pwd)
    for PROJECT in (find . -name '.git' -type d | sed 's/\/.git//' | sort)
        cd $start_dir/$PROJECT
        set PROJECTNAME (echo $PROJECT | sed 's/\.\///')
		set PREFIX (printf "\033[0;35m%-32s\033[0m" $PROJECTNAME)
        git $argv | sed "s/^/$PREFIX/"
        printf "\n\n"
    end
    cd $start_dir
end
