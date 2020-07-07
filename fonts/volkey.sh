# External Tools

chmod 755 $FONTDIR/keycheck
alias keycheck="$FONTDIR/keycheck"

chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  while true; do
    keycheck
    keycheck
    local SEL=$?
    if [ "$1" == "UP" ]; then
      UP=$SEL
      break
    elif [ "$1" == "DOWN" ]; then
      DOWN=$SEL
      break
    elif [ $SEL -eq $UP ]; then
      return 0
    elif [ $SEL -eq $DOWN ]; then
      return 1
    fi
  done
}

SEL=chooseportold
ui_print " "
ui_print "- Vol Key Programming -"
ui_print "  Press Vol Up"
$SEL "UP"
ui_print "  Press Vol Down"
$SEL "DOWN"

KEY1=Vol+; KEY2=Vol-
