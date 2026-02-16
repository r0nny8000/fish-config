function c
  echo ""
  for file in $argv
    switch (string lower -- $file)
      case '*.md' '*.markdown'
        glow $file
      case '*'
        ccat $file
    end
  end
end
