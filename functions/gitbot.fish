function gitbot
    for PROJECT in (find . -name '.git' -type d | sed 's/\/.git//' | sort)
        printf "\n\033[0;35m $PROJECT \033[0m\n"
        cd $PROJECT
        git $argv
        cd ..
        printf "\n\n\n"
    end
end
