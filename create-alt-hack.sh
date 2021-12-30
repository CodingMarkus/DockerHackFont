#!/bin/sh

set -e
althackdir="alt-hack"


badargs ( ) {
	bin="./$(basename "$0")"
	syntax="
Syntax:

    $bin <path> [<mod>] [<mod>] [<mod>] ...


<path> is the location of the modified font source, e.g.

	$bin ~/Documents/hack.font
	$bin ../hack-modified
	$bin /tmp/custom_hack_build


The path is followed by a list of desired modifactions. Modifications have to
be named as in the alt-hack repository. E.g. to get a zero with forward slash

	$bin /tmp/hack_slashed-zero u0030-forwardslash


Any number of modifications is valid, including zero:

	$bin /hack u012F-slab u0033-flattop u0129-slab


Conflicting modifications will override each other, e.g. the result of

	$bin ../modified_hack u0030-diamond u0030-dotted

will be a setup for a dotted zero, as the second mod overrides the first one.
"
	printf "%s" "$syntax" >&2
	exit 1
}


if [ $# -lt 1 ]
then
	badargs
fi


# Check if all mods exist
targetdir="$1"
shift

if [ -n "$1" ]
then
	echo "Verifying modifications..."

	for mod in "$@"
	do
		if [ ! -d "./$althackdir/glyphs/$mod" ]
		then
			echo "Unkonwn mod: $1" >&2
			exit 1
		fi
	done
fi


# Create target directory
mkdir -p "$targetdir"

# Copy the build files and folders
echo "Copying build files..."
cp -p -- *.sh Makefile "$targetdir/"
cp -pr config postbuild_processing source tools "$targetdir/"


# If there are no modifications we are done
if [ -z "$1" ]
then
	echo "No modifications requested. All done."
	exit 0
fi


# Apply requested modifications


echo "Applying modifications... "
while [ -n "$1" ]
do
	for kind in "Bold" "BoldItalic" "Italic" "Regular"
	do
		kind_lc=$(printf "%s" "$kind" | tr "[:upper:]" "[:lower:]")
		patchsrc="$althackdir/glyphs/$1/$kind_lc"

		if [ -d "$patchsrc" ]
		then
			patchdst="$targetdir/source/Hack-$kind.ufo/glyphs"

			if [ ! -d "$patchdst" ]
			then
				echo "Critical error!" >&2
				echo "Missing directory at target: $patchdst" >&2
				exit 1
			fi

			# Copy the glyph itself
			cp -pf -- "$patchsrc"/*.glif "$patchdst/"

			glyphname=""
			for file in "$patchsrc"/*.glif
			do
				glyphname=$(basename "$file")
				glyphname=${glyphname%".glif"}
				break
			done

			# Patch the manual hinting
			if [ -n "$glyphname" ]
			then
				hintdir="$targetdir/postbuild_processing/tt-hinting"
				hintfile="$hintdir/Hack-${kind}-TA.txt"
				regex="s/^$glyphname /#$glyphname /"
				cp -p -- "$hintfile" "$hintfile.bak"
				sed -E "$regex" "$hintfile.bak" > "$hintfile"
				rm "$hintfile.bak"
			fi
		fi
	done
	shift
done

echo "All done."