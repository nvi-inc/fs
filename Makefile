#
VERSION = 9
SUBLEVEL = 3
PATCHLEVEL = 114
FS_VERSION = $(VERSION).$(SUBLEVEL).$(PATCHLEVEL)
export VERSION SUBLEVEL PATCHLEVEL FS_VERSION
#
LIB_DIR = clib flib bosslb fclib fmpsee fslb lnfch newlb polb port rtelb vis \
poclb skdrut vex rclco/rcl
#
EXEC_DIR = rwand chekr fserr ddout fs fsalloc incom matcn oprin pcalr onoff \
fivpt pfmed error resid sigma xtrac boss antcn monit run labck setcl aquir \
quikv mcbcn brk moon logex headp fmset ibcon quikr go drudg rclcn pdplt logpl \
lognm pcald
#
all:	libs execs
#
dist:
	rm -rf /tmp/fs-$(FS_VERSION).tar.gz /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'core'     -print >  /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '#*#'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*~'       -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '.*~'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*.[oas]'  -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'y.tab.h'  -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION)/bin -mindepth 1 -name '*' -print >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/oprin/readline-2.0            >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/rclco/rcl/all                 >> /tmp/fsdist-exclude
	cd /; tar -czf /tmp/fs-$(FS_VERSION).tar.gz -X /tmp/fsdist-exclude usr2/fs-$(FS_VERSION)
#
clean:
	rm -f `find . -name 'core' -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
	rm -f `find . -name '.*~' -print`
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
		make --no-print-directory -C $$dir ;\
	done
#
execs:
	for dir in $(EXEC_DIR); do \
		make --no-print-directory -C $$dir; \
	done
install:
	sh misc/fsinstall
