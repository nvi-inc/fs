#
VERSION = 0
SUBLEVEL = 0
PATCHLEVEL = 0
ST_VERSION = $(VERSION).$(SUBLEVEL).$(PATCHLEVEL)
export VERSION SUBLEVEL PATCHLEVEL ST_VERSION
#
LIB_DIR =
#LIB_DIR = stlib
#
EXEC_DIR =
#EXEC_DIR = antcn cheks pcald stalloc sterp stqkr
#
ifdef LIB_DIR
all:    libs execs
else
all:    execs
endif
#
backup:
	rm -rf /tmp/st-$(ST_VERSION).tar.gz /tmp/stbackup-exclude /tmp/stbackup-include
	cp misc/stbackup-exclude      /tmp/stbackup-exclude
	cd /; find usr2/st-$(ST_VERSION) -name 'core'     -print >> /tmp/stbackup-exclude
	cd /; find usr2/st-$(ST_VERSION) -name '#*#'      -print >> /tmp/stbackup-exclude
	cd /; find usr2/st-$(ST_VERSION) -name '*~'       -print >> /tmp/stbackup-exclude
	cd /; find usr2/st-$(ST_VERSION) -name '*.[oas]'  -print >> /tmp/stbackup-exclude
	cd /; find usr2/st-$(ST_VERSION)/bin/ -mindepth 1 -name '*' -print    >> /tmp/stbackup-exclude
	cp misc/stbackup-include      /tmp/stbackup-include
	echo usr2/st-$(ST_VERSION) >> /tmp/stbackup-include
	cd /; tar -czf /tmp/st-$(ST_VERSION).tar.gz \
-X /tmp/stbackup-exclude -T /tmp/stbackup-include
#
clean:
	rm -f `find . -name 'core' -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
#
rmexe:
	rm -f bin/*
#
rmdoto:
	rm -f `find . -name '*.[oas]' -print`
#
ifdef LIB_DIR
libs:
	for dir in $(LIB_DIR); do\
		make -C $$dir ;\
	done
endif
#
execs:
	for dir in $(EXEC_DIR); do \
		make -C $$dir; \
	done
#
install:
	sh misc/stinstall

