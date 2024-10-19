# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

DESTDIR =
rootprefix =
gentoofuncs = $(rootprefix)/lib/gentoo/functions.sh
prefix = $(rootprefix)/usr
bindir = $(prefix)/bin
libdirname = lib
datadir = $(prefix)/share
patchdir = $(datadir)/elt-patches

all: eltpatch
install: install-bin install-patch
distclean: clean

eltpatch: eltpatch.in
	rm -f $@ $@.tmp
	sed -e 's^@ELT_patchdir@^$(patchdir)^' \
		-e 's^@ELT_libdir@^$(libdirname)^' \
		-e 's^@ELT_gentoofuncs@^$(gentoofuncs)^' \
		$< > $@.tmp
	chmod +x $@.tmp
	mv $@.tmp $@

clean:
	rm -f eltpatch
	rm -rf tests/*.tmp
	rm -rf tests/libtools

check: eltpatch
	cd tests && ./setup.sh && ./run.sh

install-bin: eltpatch
	install -d $(DESTDIR)$(bindir)
	install -m0755 $< $(DESTDIR)$(bindir)

install-patch:
	install -d $(DESTDIR)$(patchdir)
	cd patches && \
	for dir in */; do \
		install -d $(DESTDIR)$(patchdir)/$${dir} || exit 1; \
		for file in $${dir}/*; do \
			install -m0644 $${file} $(DESTDIR)$(patchdir)/$${dir} \
				|| exit 1; \
		done; \
	done

dist:
	rm -f elt-patches-$$(date +%Y%m%d).tar.xz elt-patches-$$(date +%Y%m%d).tar
	git archive -o elt-patches-$$(date +%Y%m%d).tar \
		--prefix=elt-patches-$$(date +%Y%m%d)/ \
		--format=tar \
		HEAD
	xz -9 elt-patches-$$(date +%Y%m%d).tar
