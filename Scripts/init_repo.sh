#!/bin/sh
#
# init_repo.sh
# Patchworks
#
# Created by Jonathon Mah on 2005-12-17.
# Copyright 2005 Playhaus. All rights reserved.
# This file is in the public domain. Feel free to copy and use it in any way.
# This file is specifically excluded from the conditions in 'LICENSE.txt'.


# This file is intented to be run from the project root
defaults_file=".darcs-defaults"

# Check we have the necessary files
if [[ !(-f "$defaults_file" &&  -d "_darcs/prefs")]]; then
	echo "This file must be run from the root of the repository."
	exit 1
fi


# Copy new defaults file
if [ -f "_darcs/prefs/defaults" ]; then
	count=''
	suffix=''
	while [ -e "_darcs/prefs/defaults.old$suffix" ]; do
		let count+=1
		suffix=".$count"
	done
	cmd="mv _darcs/prefs/defaults _darcs/prefs/defaults.old$suffix"
	echo "$cmd"
	$cmd
fi

cmd='cp .darcs-defaults _darcs/prefs/defaults'
echo "$cmd"
$cmd


# Make symlinks
cmd="ruby Scripts/build_symlinks.rb"
echo "$cmd"
$cmd > /dev/null


# Make Patchworks proxies
cmd="ruby Scripts/make_patchworks_proxies.rb"
echo "$cmd"
$cmd > /dev/null
echo
echo "Patch proxies will only be imported after building and running the Patchworks target."
echo "To import existing patches (such as those just created), run the command:"
echo "  mdimport -r build/Debug/Patchworks.app/Contents/Library/Spotlight/Patchworks.mdimporter"
