exec >&2
redo-ifchange t/shelltest.od

rm -rf $1.new $1/sh
mkdir $1.new

GOOD=
WARN=

for sh in dash sh /usr/xpg4/bin/sh ash posh mksh ksh ksh88 ksh93 pdksh \
		bash zsh busybox; do
	printf "Testing %s... " "$sh"
	FOUND=`which $sh 2>/dev/null` || { echo "missing"; continue; }
	
	# It's important for the file to actually be named 'sh'.  Some
	# shells (like bash and zsh) only go into POSIX-compatible mode if
	# they have that name.  If they're not in POSIX-compatible mode,
	# they'll fail the test.
	rm -f $1.new/sh
	ln -s $FOUND $1.new/sh
	
	set +e
	( cd t && ../$1.new/sh shelltest.od >/dev/null 2>&1 )
	RV=$?
	set -e
	
	case $RV in
		0) echo "good"; [ -n "$GOOD" ] || GOOD=$FOUND ;;
		42) echo "warnings"; [ -n "$WARN" ] || WARN=$FOUND ;;
		*) echo "failed" ;;
	esac
done

rm -rf $1 $1.new $3

if [ -n "$GOOD" ]; then
	echo "Selected perfect shell: $GOOD"
	mkdir $3
	ln -s $GOOD $3/sh
elif [ -n "$WARN" ]; then
	echo "Selected mostly good shell: $WARN"
	mkdir $3
	ln -s $WARN $3/sh
else
	echo "No good shells found!  Maybe install dash, bash, or zsh."
	exit 1
fi
