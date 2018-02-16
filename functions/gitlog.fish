function gitlog
  git log --graph --abbrev-commit --decorate --format=format:'%C(blue)%h%C(reset)   %C(magenta)%d%C(reset) %C(dim white)%aD (%ar)%C(reset)%n''           %C(white)%s%C(reset)%C(dim white) - %an (%ae)%C(reset)%n''%n''' $argv
end
