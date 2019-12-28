#!/bin/bash

name="ax-feed978"
ipath="/usr/local/share/$name"


systemctl disable --now "$name-1090"
systemctl disable --now "$name-convert"

rm -f "/lib/systemd/system/$name-1090.service"
rm -f "/lib/systemd/system/$name-convert.service"

rm -f "/etc/default/$name"
rm -rf $ipath

echo "$name removed!"
