#!/bin/bash
set -e

name="ax-feed978"
repo="https://github.com/wiedehopf/$name"
ipath="/usr/local/share/$name"

mkdir -p $ipath

if ! command -v dump1090-fa &>/dev/null; then
	echo "Requires dump1090-fa to be installed."
	echo "Fatal Error, exiting!"
fi

if ! command -v dump978-fa &>/dev/null; then
	echo "Requires dump1090-fa to be installed."
	echo "Fatal Error, exiting!"
fi

packages="git socat"
install=""

for PKG in $packages; do
	if ! command -v "$PKG" &>/dev/null
	then
		echo "command $PKG not found, will try to install package $PKG"
		install+="$PKG "
	fi
done

if [[ -n "$install" ]]
then
	echo "Installing required packages: $install"
	apt-get update || true
	if ! apt-get install -y $install
	then
		echo "Failed to install required packages: $install"
		echo "Exiting ..."
		exit 1
	fi
	hash -r || true
fi

if ! [ -f /usr/local/bin/uat2esnt ]; then
	rm -rf /tmp/dump978 &>/dev/null || true
	git clone https://github.com/flightaware/dump978.git /tmp/dump978 --depth 1
	cd /tmp/dump978/legacy
	make uat2esnt
	mkdir -p /usr/local/bin
	cp uat2esnt /usr/local/bin
fi


if [[ "$1" == "test" ]]
then
	rm -r $ipath/test 2>/dev/null || true
	mkdir -p $ipath/test
	cp -r ./* $ipath/test
	cd $ipath/test

elif git clone --depth 1 $repo $ipath/git 2>/dev/null || cd $ipath/git
then
	cd $ipath/git
	git checkout -f master
	git fetch
	git reset --hard origin/master

else
	echo "Unable to download files, exiting! (Maybe try again?)"
	exit 1
fi

cp -n default "/etc/default/$name"
cp default convert.sh $ipath

cp 1090.service "/lib/systemd/system/$name-1090.service"
cp convert.service "/lib/systemd/system/$name-convert.service"

systemctl enable "$name-1090"
systemctl enable "$name-convert"
systemctl restart "$name-1090"
systemctl restart "$name-convert"
