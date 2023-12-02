#!/bin/bash

for fn in autoconf.info.gz	autoconf.info \
	autoconf-2.5x.info.gz	autoconf-2.5x.info \
	autoconf-2.60.info.gz	autoconf-2.60.info \
	autoconf2.60.info.gz	autoconf2.60.info \
	standards.info.gz	standards.info \
	standards-2.5x.info.gz	standards-2.5x.info \
	standards-2.13.info.gz	standards-2.13.info \
	standards-2.60.info.gz	standards-2.60.info \
	standards2.60.info.gz	standards2.60.info \
	autoconf2.61.info.gz	autoconf2.61.info \
	autoconf2.63.info.gz	autoconf2.63.info
do
	if [ -f /usr/share/info/${fn} ]
	then
		/usr/bin/install-info --delete --quiet \
		    --dir-file=/usr/share/info/dir \
		    --info-file=/usr/share/info/${fn} 2>/dev/null || /bin/true
	fi
done

# remove unversion man pages
pushd /usr/share/man/man1 >/dev/null 2>&1
for fn in autoconf autoheader autom4te autoreconf autoscan \
	autoupdate config.guess config.sub ifnames
do
	rm -f ${fn}.1.gz 2>/dev/null || /bin/true
done
popd >/dev/null 2>&1

