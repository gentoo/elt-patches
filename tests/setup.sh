#!/bin/bash
# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Setup local copies of pristine libtool for testing against.

set -e
cd "$(dirname "$(realpath "$0")")"

: "${DISTDIR:=/var/cache/distfiles}"
URI_BASE="https://ftpmirror.gnu.org/libtool/"

setup() {
	local PV="$1"
	local P="libtool-${PV}"
	local A="${P}.tar.xz"

	script="libtools/${P}/destdir/bin/libtool"
	if [[ -e ${script} ]] ; then
		return
	fi

	pushd libtools >/dev/null
	rm -rf "${P}"
	if [[ -e ${DISTDIR}/${A} ]] ; then
		printf "unpack "
		tar xf "${DISTDIR}/${A}"
	else
		if [[ ! -e ${A} ]] ; then
			printf "fetch "
			wget -nv "${URI_BASE}/${A}"
		fi
		printf "unpack "
		tar xf "${A}"
	fi

	printf "compile "
	cd "${P}"
	./configure --prefix="${PWD}/destdir" -q >/dev/null
	make install -j -s >/dev/null

	popd >/dev/null
}

build() {
	local PV="$1"

	pushd "${PV}" >/dev/null
	PATH="${PWD}/../libtools/libtool-${PV}/destdir/bin:${PATH}"
	autoreconf -i
	popd >/dev/null
}

mkdir -p libtools
for f in *.*/configure.ac ; do
	v=${f%/*}
	[[ ${v} == *.tmp ]] && continue
	printf "${v}: "
	setup "${v}"
	build "${v}"
	echo "done"
done
