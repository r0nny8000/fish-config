function gc
  echo "git status, add, commit and push"
  echo ""
  git status 
  git add .
  git commit -a
  git push
  git status
end
