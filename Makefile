#
VERSION = 9
SUBLEVEL = 0
PATCHLEVEL = 3
FS_VERSION = $(VERSION).$(SUBLEVEL).$(PATCHLEVEL)
export VERSION SUBLEVEL PATCHLEVEL FS_VERSION
#
LIB_DIR = clib flib bosslb fclib fmpsee fslb lnfch newlb polb port rtelb vis \
poclb
#
EXEC_DIR = rwand chekr fserr ddout fs fsalloc incom matcn oprin pcalr onoff \
fivpt pfmed error resid sigma xtrac boss antcn monit run labck setcl aquir \
quikv mcbcn brk moon logex headp fmset ibcon quikr go
#
all:	libs execs
#
dist:	clean
	rm -rf /tmp/fs-$(FS_VERSION).tar.gz
	cd /; tar -czf /tmp/fs-$(FS_VERSION).tar.gz usr2/fs-$(FS_VERSION)
#
clean:	rmexe rmdoto
	rm -f `find . -name 'core' -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
#
rmexe:
	rm -f bin/*
#
rmdoto:
	rm -f `find . -name '*.[oas]' -print`
	rm -rf oprin/readline-2.0
#
libs:
	for dir in $(LIB_DIR); do\
		make -C $$dir ;\
	done
#
execs:
	for dir in $(EXEC_DIR); do \
		make -C $$dir; \
	done
install:
	sh misc/fsinstall