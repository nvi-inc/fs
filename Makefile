#
VERSION = 9
SUBLEVEL = 12
PATCHLEVEL = 10
FS_VERSION = $(VERSION).$(SUBLEVEL).$(PATCHLEVEL)
export VERSION SUBLEVEL PATCHLEVEL FS_VERSION
#
# If environment variable FS_SERIAL_CLOCAL is define with a non-empty value
#  the port library and mcbcn program will be compiled with a O_NONBLOCK
#  open of the serial port, then set CLOCAL, and then closed and re-opened
#  without O_NONBLOCK. This also impacts and programs that call
#  portopen(), including ibcon.
#
LIB_DIR = clib flib bosslb fclib fmpsee fslb lnfch newlb polb port rtelb vis \
poclb skdrut vex rclco/rcl s2das
#
EXEC_DIR = rwand chekr fserr ddout fs fsalloc incom matcn oprin pcalr onoff \
fivpt pfmed error resid sigma xtrac boss antcn monit run labck setcl aquir \
quikv mcbcn brk moon logex headp fmset ibcon quikr go drudg rclcn pdplt logpl \
lognm pcald msg fsvue fs.prompt inject_snap erchk mk5cn tpicd flagr \
gnfit gndat gnplt dscon systests autoftp monpcal logpl1 holog gnplt1 predict \
dbbcn rdbcn rdtcn mk6cn popen udceth0 rack mcicn be_client s_client lgerr fesh\
plog
#
all:	libs execs
#
dist:
	rm -rf /tmp/fs-$(FS_VERSION).tgz /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'core'     -print >  /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '#*#'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*~'       -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '.*~'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*.[oas]'  -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*.pyc'  -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'y.tab.h'  -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION)/bin -mindepth 1 -name '*' -print >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/oprin/readline-2.0            >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/rclco/rcl/all                 >> /tmp/fsdist-exclude
	cd /; tar -czf /tmp/fs-$(FS_VERSION).tgz -X /tmp/fsdist-exclude usr2/fs-$(FS_VERSION)
	chmod a+rw /tmp/fs-$(FS_VERSION).tgz
#
clean:
	rm -f `find . -name 'core' -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
	rm -f `find . -name '.*~' -print`
	rm -f `find . -name '*.pyc' -print`
#
rmexe:
	rm -fr bin/*
#
rmdoto:
	rm -f `find . -name '*.[oas]' -print`
	rm -rf oprin/readline-2.0
	rm -f `find . -name '*.pyc' -print`
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
