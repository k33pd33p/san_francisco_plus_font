[ ! $MAGISKTMP ] && MAGISKTMP=$(magisk --path)/.magisk
[ -d $MAGISKTMP ] && ORIGDIR=$MAGISKTMP/mirror
FONTDIR=$MODPATH/fonts
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

patch() {
	[ -f $ORIGDIR/system/etc/fonts.xml ] && cp $ORIGDIR/system/etc/fonts.xml $SYSXML || abort "! $ORIGDIR/system/etc/fonts.xml: file not found"
	if grep -q 'family >' /system/etc/fonts.xml; then
		cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	else
		find /data/adb/modules* -type f -name fonts.xml -exec rm {} \;
		cp /system/etc/fonts.xml $SYSXML
		version !
	fi
	sed -i '/"sans-serif">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
	sed -i ':a;N;$!ba;s/name="sans-serif"//2' $SYSXML
}

headline() {
	cp $FONTDIR/hf/*ttf $SYSFONT
	sed -i '/"sans-serif">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $SYSXML
}

body() {
	cp $FONTDIR/bf/*ttf $SYSFONT 
	sed -i '/"sans-serif">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $SYSXML
}

condensed() {
	cp $FONTDIR/cf/*ttf $SYSFONT
	sed -i 's/RobotoC/C/' $SYSXML
}

mono() {
	cp $FONTDIR/mo/*ttf $SYSFONT
	sed -i 's/DroidSans//' $SYSXML
}

full() { headline; body; condensed; mono; }

rounded() {
	[ $HF -eq 2 ] && ( cp $FONTDIR/rd/hf/*ttf $SYSFONT; version hfrnd )
	[ $BF -eq 2 ] && ( cp $FONTDIR/rd/bf/*ttf $SYSFONT; version bfrnd )
}

text() {
	cp $FONTDIR/tx/*ttf $SYSFONT
	version bftxt
}

bold() {
	if [ $BOLD -eq 3 ]; then
		sed -i '/"sans-serif">/,/family>/{/400/d;/>Light\./{N;h;d};/MediumItalic/G;/>Black\./{N;h;d};/BoldItalic/G}' $SYSXML
		sed -i '/"sans-serif-condensed">/,/family>/{/400/d;/-Light\./{N;h;d};/MediumItalic/G}' $SYSXML
	else
		local x=25
		[ $BOLD -eq 2 ] && x=50
		cp $FONTDIR/bf/bd/$x/*ttf $SYSFONT
		if [ $BF -eq 2 ]; then
			cp $FONTDIR/rd/bf/bd/$x/*ttf $SYSFONT
		elif [ $BF -eq 3 ]; then
			cp $FONTDIR/tx/bd/$x/*ttf $SYSFONT
		fi
	fi
	version bld
}

legible() {
	local src=$FONTDIR/bf/hl
	[ $BF -eq 2 ] && src=$FONTDIR/rd/bf/hl || { [ $BF -eq 3 ] && src=$FONTDIR/tx/hl; } 
	cp $src/*ttf $SYSFONT
	version lgbl
}

tracking() {
	cp $FONTDIR/bf/tr/*ttf $SYSFONT
	if [ $BF -eq 2 ]; then
		cp $FONTDIR/rd/tr/*ttf $SYSFONT
	elif [ $BF -eq 3 ]; then
		cp $FONTDIR/tx/tr/*ttf $SYSFONT
	fi
}

clean_up() {
	rm -rf $FONTDIR $MODPATH/LICENSE
	rmdir -p $PRDFONT $SYSETC
}

pixel() {
	local src dest
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ] || [ -f $ORIGDIR/system/product/fonts/GoogleSans-Regular.ttf ]; then
		dest=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		dest=$SYSFONT
	fi
	if [ $dest ]; then
		if [ $PART -eq 1 ]; then
			set BoldItalic Bold MediumItalic Medium
			for i do cp $SYSFONT/$i.ttf $dest/GoogleSans-$i.ttf; done
			src=$FONTDIR/bf
			cp $src/Italic.ttf $dest/GoogleSans-Italic.ttf
			[ $HF -eq 2 ] && src=$FONTDIR/rd/bf
			cp $src/Regular.ttf $dest/GoogleSans-Regular.ttf
			if [ $BOLD -ne 0 ]; then
				if [ $BOLD -eq 3 ]; then
					cp $dest/GoogleSans-Medium.ttf $dest/GoogleSans-Regular.ttf
					cp $dest/GoogleSans-MediumItalic.ttf $dest/GoogleSans-Italic.ttf
				else
					src=$FONTDIR/bf/bd
					local x
					[ $BOLD -eq 1 ] && x=25 || x=50
					cp $src/$x/Italic.ttf $dest/GoogleSans-Italic.ttf
					[ $HF -eq 2 ] && src=$FONTDIR/rd/bf/bd
					cp $src/$x/Regular.ttf $dest/GoogleSans-Regular.ttf
				fi
			fi
		fi
		version pxl
	else
		false
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		set Black Bold Medium Regular Light Thin
		for i do cp $SYSFONT/$i.ttf $SYSFONT/SlateForOnePlus-$i.ttf; done
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		version oos
	else
		false
	fi
}

miui() {
	if grep -q miui $SYSXML; then
		if [ $PART -eq 1 ]; then
			sed -i '/"mipro"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="400"/d}' $SYSXML
			sed -i '/"mipro-regular"/,/family>/{/700/s/MiLanProVF/Medium/;/stylevalue="400"/d}' $SYSXML
			sed -i '/"mipro-medium"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-demibold"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-semibold"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-bold"/,/family>/{/400/s/MiLanProVF/Bold/;/700/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-heavy"/,/family>/{/400/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
		fi	
		sed -i '/"mipro"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
		sed -i '/"mipro-thin"/,/family>/{/400/s/MiLanProVF/Thin/;/700/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-extralight"/,/family>/{/400/s/MiLanProVF/Thin/;/700/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-light"/,/family>/{/400/s/MiLanProVF/Light/;/700/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-normal"/,/family>/{/400/s/MiLanProVF/Light/;/700/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-regular"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
		version miui
	else
		false
	fi
}

lg() {
	local lg=false
	if grep -q lg-sans-serif $SYSXML; then
		sed -i '/"lg-sans-serif">/,/family>/{/"lg-sans-serif">/!d};/"sans-serif">/,/family>/{/"sans-serif">/!H};/"lg-sans-serif">/G' $SYSXML
		lg=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		cp $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		local lgxml=$SYSETC/fonts_lge.xml
		sed -i '/"default_roboto">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $lgxml
		if [ $PART -eq 1 ]; then
			sed -i '/"default_roboto">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $lgxml
			[ $BOLD -eq 3 ] && sed -i '/"default_roboto">/,/family>/{/400/d;/>Light\./{N;h;d};/MediumItalic/G}' $lgxml
		fi
		lg=true
	fi
	$lg && version lg || false
}

samsung() {
	if grep -q Samsung $SYSXML; then
		sed -i 's/SECRobotoLight-//;s/SECCondensed-/Condensed-/' $SYSXML
		[ $PART -eq 1 ] && sed -i 's/SECRobotoLight-Bold/Medium/' $SYSXML
		version sam
	else
		false
	fi
}

rom() {
	pixel || oxygen || miui || lg || samsung
}

version() { sed -i 3"s/$/-$1&/" $MODPROP; }

gsp() {
	GSP=false
	local gsp=/data/adb/modules_update/googlesansplus
	if grep -q -e 'hf-' -e 'hf$' $gsp/module.prop; then
		SYSXML=$gsp/system/etc/fonts.xml
		GSP=true
	fi
	$GSP && version gsp
}

### SELECTIONS ###
OPTION=false
PART=1
HF=1
BF=1
BOLD=0
LEGIBLE=false
TRACK=0

gsp

. $FONTDIR/selector.sh

if [ $SEL ]; then
	OPTION=true	
	ui_print "  "
	ui_print "- CUSTOMIZATIONS -"
	sleep 0.5
fi

if $OPTION; then

	if ! $GSP; then
		ui_print "  "
		ui_print "- Which HEADLINE font style?"
		ui_print "  $KEY1 = Next Option; $KEY2 = OK"
		ui_print "  "
		ui_print "  1. Default"
		ui_print "  2. Rounded"
		ui_print "  "
		ui_print "  Select:"
		while :; do
			ui_print "  $HF"
			$SEL && HF=$((HF + 1)) || break
			[ $HF -gt 2 ] && HF=1
		done
		ui_print "  "
		ui_print "  Selected: $HF"
		sleep 0.4
	else
		PART=2
	fi

	ui_print "  "
	ui_print "- Which BODY font style?"
	ui_print "  $KEY1 = Next Option; $KEY2 = OK"
	ui_print "  "
	ui_print "  1. Default"
	ui_print "  2. Rounded"
	ui_print "  3. Text"
	ui_print "  "
	ui_print "  Select:"
	while :; do
		ui_print "  $BF"
		$SEL && BF=$((BF + 1)) || break
		[ $BF -gt 3 ] && BF=1
	done
	ui_print "  "
	ui_print "  Selected: $BF"
	sleep 0.4

	ui_print "  "
	ui_print "- Use BOLD font?"
	ui_print "  $KEY1 = Yes; $KEY2 = No"
	ui_print "  "
	$SEL && { BOLD=1; ui_print "  Selected: Yes"; } ||  ui_print "  Selected: No"
	sleep 0.4

	if [ $BOLD -eq 1 ]; then
		ui_print "  "
		ui_print "- How much BOLD?"
		ui_print "  $KEY1 = Next Option; $KEY2 = OK"
		ui_print "  "
		ui_print "  1. Light"
		ui_print "  2. Medium"
		[ $HF -eq $BF ] && ui_print "  3. Strong"
		ui_print "  "
		ui_print "  Select:"
		while :; do
			ui_print "  $BOLD"
			$SEL && BOLD=$((BOLD + 1)) || break
			([ $BOLD -gt 2 ] && [ $HF -ne $BF ] || [ $BOLD -gt 3 ]) && BOLD=1
		done
		ui_print "  "
		ui_print "  Selected: $BOLD"
		sleep 0.4
	fi

	if [ $BOLD -eq 0 ]; then
		ui_print "  "
		ui_print "- High Legibility?"
		ui_print "  $KEY1 = Yes; $KEY2 = No"
		ui_print "  "
		$SEL && { LEGIBLE=true; ui_print "  Selected: Yes"; } || ui_print "  Selected: No"	
		sleep 0.4
	fi

	if [ $BOLD -eq 0  && ! $LEGIBLE ]; then
		ui_print "  "
		ui_print "- Letter-Spacing?"
		ui_print "  $KEY1 = Next Option; $KEY2 = OK"
		ui_print "  "
		ui_print "  1. Default"
		[ $BF -eq 3 ] && ui_print "  2. Less"  || ui_print "  2. More"
		while :; do
			ui_print "  $TRACK"
			$SEL && TRACK=$((TRACK + 1)) || break
			[ $TRACK -gt 2 ] && TRACK=1
		done
		ui_print "  "
		ui_print "  Selected: $TRACK"
		sleep 0.4
	fi

fi #OPTIONS

### INSTALLATION ###
ui_print "  "
ui_print "- Installing"
mkdir -p $SYSFONT $SYSETC $PRDFONT
[ $PART -eq 1 ] && ( patch; full ) || ( body; condensed; mono; version bf )
[ $HF -eq 2 ] || [ $BF -eq 2 ] && rounded
[ $BF -eq 3 ] && text
[ $BOLD -ne 0 ] && bold
$LEGIBLE && legible
[ $TRACK -ne 0 ] && tracking
rom

### CLEAN UP ###
ui_print "- Cleaning up"
clean_up
