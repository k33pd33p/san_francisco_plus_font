FONTDIR=$MODPATH/custom
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

patch() {
	cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	sed -i '/\"sans-serif\">/i \
	<family name="sans-serif">\
		<font weight="100" style="normal">Roboto-Thin.ttf</font>\
		<font weight="100" style="italic">Roboto-ThinItalic.ttf</font>\
		<font weight="300" style="normal">Roboto-Light.ttf</font>\
		<font weight="300" style="italic">Roboto-LightItalic.ttf</font>\
		<font weight="400" style="normal">Roboto-Regular.ttf</font>\
		<font weight="400" style="italic">Roboto-Italic.ttf</font>\
		<font weight="500" style="normal">Roboto-Medium.ttf</font>\
		<font weight="500" style="italic">Roboto-MediumItalic.ttf</font>\
		<font weight="900" style="normal">Roboto-Black.ttf</font>\
		<font weight="900" style="italic">Roboto-BlackItalic.ttf</font>\
		<font weight="700" style="normal">Roboto-Bold.ttf</font>\
		<font weight="700" style="italic">Roboto-BoldItalic.ttf</font>\
	</family>' $SYSXML
	sed -i ':a;N;$!ba; s/name=\"sans-serif\"//2' $SYSXML
}

headline() {
	cp $FONTDIR/hf/*ttf $SYSFONT
	sed -i '/\"sans-serif\">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $SYSXML
}

body() {
	cp $FONTDIR/bf/*ttf $SYSFONT 
	sed -i '/\"sans-serif\">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $SYSXML
	nsss
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

nsss() {
	if [ $API -ge 29 ] && i=$(grep 'NotoSerif\|NS-' $SYSXML) && i=$(grep SourceSansPro $SYSXML); then
		if [ $PART -eq 1 ]; then
			sed -i 's/NotoSerif-/NS-/' $SYSXML
			SRC=$FONTDIR/hf
			cp $SRC/BoldItalic.ttf $SYSFONT/NS-BoldItalic.ttf
			if [ $HF -eq 2 ]; then SRC=$FONTDIR/rd/hf; fi
			cp $SRC/Bold.ttf $SYSFONT/NS-Bold.ttf
			SRC=$FONTDIR/bf
			cp $SRC/Italic.ttf $SYSFONT/NS-Italic.ttf
			if [ $HF -eq 2 ]; then SRC=$FONTDIR/rd/bf; fi
			cp $SRC/Regular.ttf $SYSFONT/NS-Regular.ttf
		fi
		sed -i 's/SourceSansPro-SemiBold/SSP-Medium/;s/SourceSansPro-/SSP-/' $SYSXML
		SRC=$FONTDIR/hf
		cp $SRC/BoldItalic.ttf $SYSFONT/SSP-BoldItalic.ttf
		cp $SRC/MediumItalic.ttf $SYSFONT/SSP-MediumItalic.ttf
		if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/hf; fi
		cp $SRC/Bold.ttf $SYSFONT/SSP-Bold.ttf
		cp $SRC/Medium.ttf $SYSFONT/SSP-Medium.ttf
		SRC=$FONTDIR/bf
		cp $SRC/Italic.ttf $SYSFONT/SSP-Italic.ttf
		if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/bf
		elif [ $BF -eq 3 ]; then SRC=$FONTDIR/tx; fi
		cp $SRC/Italic.ttf $SYSFONT/SSP-Italic.ttf
		if $LEGIBLE; then SRC=$SRC/hl; fi
		cp $SRC/Regular.ttf $SYSFONT/SSP-Regular.ttf
	fi
}

rounded() {
	if [ $HF -eq 2 ]; then cp $FONTDIR/rd/hf/*ttf $SYSFONT; fi
	if [ $BF -eq 2 ]; then cp $FONTDIR/rd/bf/*ttf $SYSFONT; fi
}

text() { cp $FONTDIR/tx/*ttf $SYSFONT; }

bold() {
	SRC=$FONTDIR/bf/bd
	if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/bf/bd
	elif [ $BF -eq 3 ]; then SRC=$FONTDIR/tx/bd; fi
	if [ $BOLD -eq 1 ]; then cp $SRC/25/*ttf $SYSFONT
	elif [ $BOLD -eq 2 ]; then cp $SRC/50/*ttf $SYSFONT
	else
		sed -i '/\"sans-serif\">/,/family>/{/400/d;/>Light\./{N;h;d};/MediumItalic/G;/>Black\./{N;h;d};/BoldItalic/G}' $SYSXML
		sed -i '/\"sans-serif-condensed\">/,/family>/{/400/d;/-Light\./{N;h;d};/MediumItalic/G}' $SYSXML
	fi
}

legible() {
	SRC=$FONTDIR/bf/hl
	if [ $BF -eq 2 ]; then SRC=$FONTDIR/rd/bf/hl
	elif [ $BF -eq 3 ]; then SRC=$FONTDIR/tx/hl; fi
	cp $SRC/*ttf $SYSFONT
}

cleanup() {
	rm -rf $FONTDIR
	rmdir -p $SYSETC $PRDFONT
}

pixel() {
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ]; then
		DEST=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		DEST=$SYSFONT
	fi
	if [ ! -z $DEST ]; then
		if [ $PART -eq 1 ]; then
			SRC=$FONTDIR/bf
			if [ $HF -eq 2 ]; then SRC=$FONTDIR/rd/bf; fi
			cp $SRC/Regular.ttf $DEST/GoogleSans-Regular.ttf
			cp $FONTDIR/bf/Italic.ttf $DEST/GoogleSans-Italic.ttf
			cp $SYSFONT/Medium.ttf $DEST/GoogleSans-Medium.ttf
			cp $SYSFONT/MediumItalic.ttf $DEST/GoogleSans-MediumItalic.ttf
			cp $SYSFONT/Bold.ttf $DEST/GoogleSans-Bold.ttf
			cp $SYSFONT/BoldItalic.ttf $DEST/GoogleSans-BoldItalic.ttf
			if [ $BOLD -eq 3 ]; then
				cp $DEST/GoogleSans-Medium.ttf $DEST/GoogleSans-Regular.ttf
				cp $DEST/GoogleSans-MediumItalic.ttf $DEST/GoogleSans-Italic.ttf
			fi
		fi
		sed -ie 3's/$/-pxl&/' $MODPROP
		PXL=true
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		cp $SYSFONT/Black.ttf $SYSFONT/SlateForOnePlus-Black.ttf
		cp $SYSFONT/Bold.ttf $SYSFONT/SlateForOnePlus-Bold.ttf
		cp $SYSFONT/Medium.ttf $SYSFONT/SlateForOnePlus-Medium.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Regular.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		cp $SYSFONT/Light.ttf $SYSFONT/SlateForOnePlus-Light.ttf
		cp $SYSFONT/Thin.ttf $SYSFONT/SlateForOnePlus-Thin.ttf
		sed -ie 3's/$/-oos&/' $MODPROP
		OOS=true
	fi
}

miui() {
	if i=$(grep miui $SYSXML); then
		if [ $PART -eq 1 ]; then
			sed -i '/\"miui\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"miui-regular\"/,/family>/{/700/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"miui-bold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"mipro-regular\"/,/family>/{/700/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
			sed -i '/\"mipro-medium\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-demibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-semibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/700/,/>/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-bold\"/,/family>/{/400/,/>/s/MiLanProVF/Bold/;/700/,/>/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
			sed -i '/\"mipro-heavy\"/,/family>/{/400/,/>/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
		fi	
		sed -i '/\"miui\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -i '/\"miui-thin\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/700/,/>/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/\"miui-light\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/700/,/>/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/\"miui-regular\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -i '/\"mipro\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -i '/\"mipro-thin\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/700/,/>/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-extralight\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/700/,/>/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-light\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/700/,/>/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-normal\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/700/,/>/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/\"mipro-regular\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
		sed -ie 3's/$/-miui&/' $MODPROP
		MIUI=true
	fi
}

rom() {
	pixel
	if ! $PXL; then oxygen
		if ! $OOS; then miui
		fi
	fi
}

googlesans() {
	if i=$(grep '\-hf-' $MODULEROOT/googlesansplus/module.prop); then
		SYSXML=$MODULEROOT/googlesansplus/system/etc/fonts.xml
		GS=true
	elif i=$(grep '\-hf-' $NVBASE/googlesansplus/module.prop); then
		SYSXML=$NVBASE/modules/googlesansplus/system/etc/fonts.xml
		GS=true
	fi
}

### SELECTIONS ###

OPTION=false
PART=1
HF=1
BF=1
BOLD=0
LEGIBLE=false

GS=false
googlesans

ui_print "   "
ui_print "- Enable OPTIONS?"
ui_print "  Vol+ = Yes; Vol- = No"
ui_print "   "
if $VKSEL; then
	OPTION=true	
	ui_print "  Selected: Yes"
else
	ui_print "  Selected: No"	
fi

if $OPTION; then

	if $GS; then
		ui_print "   "
		ui_print "- WHERE to install?"
		ui_print "  Vol+ = Select; Vol- = Ok"
		ui_print "   "
		ui_print "  1. Full"
		ui_print "  2. Body"
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $PART"
			if $VKSEL; then
				PART=$((PART + 1))
			else 
				break
			fi
			if [ $PART -gt 2 ]; then
				PART=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $PART"
	fi

	if [ $PART -eq 1 ]; then
		ui_print "   "
		ui_print "- Which HEADLINE font style?"
		ui_print "  Vol+ = Select; Vol- = OK"
		ui_print "   "
		ui_print "  1. Default"
		ui_print "  2. Rounded"
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $HF"
			if $VKSEL; then
				HF=$((HF + 1))
			else 
				break
			fi
			if [ $HF -gt 2 ]; then
				HF=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $HF"
	fi

	ui_print "   "
	ui_print "- Which BODY font style?"
	ui_print "  Vol+ = Select; Vol- = OK"
	ui_print "   "
	ui_print "  1. Default"
	ui_print "  2. Rounded"
	ui_print "  3. Text"
	ui_print "   "
	ui_print "  Select:"
	while true; do
		ui_print "  $BF"
		if $VKSEL; then
			BF=$((BF + 1))
		else 
			break
		fi
		if [ $BF -gt 3 ]; then
			BF=1
		fi
	done
	ui_print "   "
	ui_print "  Selected: $BF"

	ui_print "   "
	ui_print "- Use BOLD font?"
	ui_print "  Vol+ = Yes; Vol- = No"
	ui_print "   "
	if $VKSEL; then
		BOLD=1
		ui_print "  Selected: Yes"
	else
		ui_print "  Selected: No"	
	fi

	if [ $BOLD -eq 1 ]; then
		ui_print "   "
		ui_print "- How much BOLD?"
		ui_print "  Vol+ = Select; Vol- = OK"
		ui_print "   "
		ui_print "  1. Light"
		ui_print "  2. Medium"
		if [ $HF -eq $BF ] && [ $PART -eq 1 ]; then
			ui_print "  3. Strong"
		fi
		ui_print "   "
		ui_print "  Select:"
		while true; do
			ui_print "  $BOLD"
			if $VKSEL; then
				BOLD=$((BOLD + 1))
			else 
				break
			fi
			if [ $BOLD -eq 3 ]; then
				if [ $HF -ne $BF ] || [ $PART -ne 1 ]; then
					BOLD=1
				fi
			fi
			if [ $BOLD -gt 3 ] ; then
				BOLD=1
			fi
		done
		ui_print "   "
		ui_print "  Selected: $BOLD"
	fi

	if [ $BOLD -eq 0 ]; then
		ui_print "   "
		ui_print "- High Legibility?"
		ui_print "  Vol+ = Yes; Vol- = No"
		ui_print "   "
		if $VKSEL; then
			LEGIBLE=true
			ui_print "  Selected: Yes"
		else
			ui_print "  Selected: No"	
		fi
	fi

fi #OPTIONS

### INSTALLATION ###
ui_print "   "
ui_print "- Installing"

mkdir -p $SYSFONT $SYSETC $PRDFONT
if [ $PART -eq 1 ]; then patch; fi

case $PART in
 	1 ) full;;
 	2 ) body; condensed; mono; sed -ie 3's/$/-bf&/' $MODPROP;;
esac

case $HF in
	2 ) rounded; sed -ie 3's/$/-hfrnd&/' $MODPROP;;
esac

case $BF in
	2 ) rounded; sed -ie 3's/$/-bfrnd&/' $MODPROP;;
	3 ) text; sed -ie 3's/$/-bftxt&/' $MODPROP;;
esac

if [ $BOLD -ne 0 ]; then
	bold; sed -ie 3's/$/-bld&/' $MODPROP
fi

if $LEGIBLE; then
	legible; sed -ie 3's/$/-lgbl&/' $MODPROP
fi

PXL=false; OOS=false; MIUI=false
rom

### CLEAN UP ###
ui_print "- Cleaning up"
cleanup

ui_print "   "
