ui_print "  "
ui_print "- Selector -"
ui_print "  Volume Key"
(i=$(getevent -qc 30) && ( ui_print "  ✓"; sleep 0.4 )) & sleep 1; pkill getevent || { . $FONTDIR/volkey.sh; return; }
ui_print "  Touch Screen"
i=$(timeout 2 getevent -qc 30) && { ui_print "  ✓"; sleep 0.4 & SEL=selector; } || return

selector() {
	rm swipe tap
	(i=$(getevent -qc 5) && touch tap) & (i=$(getevent -qc 30) && touch swipe) &
	while :; do [ -f tap ] && break; done
	sleep 0.2; pkill getevent
	[ -f swipe ] && return 1 || return 0
}

KEY1=Tap; KEY2=Swipe
