function gitbot
    for PROJECT in (find . -name '.git' -type d | sed 's/\/.git//' | sort)
        cd $PROJECT
        set PROJECTNAME (echo $PROJECT | sed 's/\.\///')
		set PREFIX (printf "\033[0;35m%-32s\033[0m" $PROJECTNAME)
        git $argv | sed "s/^/$PREFIX/"
        cd ..
        printf "\n\n"
    end
end
