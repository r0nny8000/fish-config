function gp
  echo "git status"
  echo ""
  git status; or return $status

  echo ""
  echo "git add ."
  echo ""
  git add .; or return $status

  echo ""
  echo "git commit"
  echo ""
  git commit; or return $status

  echo ""
  echo "git push"
  echo ""
  git push; or return $status

  echo ""
  echo "git status"
  echo ""
  git status
end
