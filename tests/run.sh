#!/bin/bash
# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Run eltpatch against copies of libtool for quick testing.

set -e
cd "$(dirname "$(realpath "$0")")"

export LD=ld
export CHOST=x86_64-gentoo-linux-gnu
export ELT_patchdir="${PWD}/../patches"
eltpatch=${PWD}/../eltpatch

test() {
	local PV="$1"

	rm -rf "${PV}.tmp"
	cp -a "${PV}" "${PV}.tmp"
	export S="${PWD}/${PV}.tmp"
	export TMPDIR=${S}
	"${eltpatch}"
}

mkdir -p libtools
for f in *.*/configure.ac ; do
	v=${f%/*}
	[[ ${v} == *.tmp ]] && continue
	echo "### ${v}"
	test "${v}"
done
