#
pwd = $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
# TODO fallback to this for non-git paths
# FS_VERSION := $(shell echo $(pwd) | cut -d- -f2-)
FS_VERSION := $(shell git describe --tags --dirty)
VERSION    := $(shell echo $(FS_VERSION) | cut -d. -f1 )
SUBLEVEL   := $(shell echo $(FS_VERSION) | cut -d. -f2 )
PATCHLEVEL := $(shell echo $(FS_VERSION) | cut -d. -f3 | cut -d- -f1)
RELEASE    := $(shell echo $(FS_VERSION) | cut -d- -f2- -s)
#
ifeq ($(VERSION),)
$(error no VERSION value)
endif
ifeq ($(SUBLEVEL),)
$(error no SUBLEVEL value)
endif
ifeq ($(PATCHLEVEL),)
$(error no PATCHLEVEL value)
endif
export VERSION SUBLEVEL PATCHLEVEL FS_VERSION RELEASE
# print variable,  use 'make print-version' to print VERSION
print-%  : ; @echo $* = $($*)
#
# If environment variable FS_SERIAL_CLOCAL is define with a non-empty value
#  the port library and mcbcn program will be compiled with a O_NONBLOCK
#  open of the serial port, then set CLOCAL, and then closed and re-opened
#  without O_NONBLOCK. This also impacts and programs that call
#  portopen(), including ibcon.
#
LIB_DIR = clib flib bosslb fclib fmpsee fslb lnfch newlb polb port rtelb vis \
poclb skdrut vex rclco/rcl s2das third_party
#
EXEC_DIR = antcn aquir autoftp be_client boss brk chekr dbbcn ddout drudg dscon \
erchk error fesh fivpt flagr fmset fs fs.prompt fsalloc fserr fsserver \
fsvue gndat gnfit gnplt gnplt1 go headp holog ibcon incom inject_snap \
labck lgerr logex lognm logpl logpl1 matcn mcbcn mcicn mk5cn mk6cn monit \
monpcal moon msg onoff oprin pcald pcalr pdplt pfmed plog popen predict \
quikr quikv rack rclcn rdbcn rdtcn resid run rwand s_client setcl sigma \
spubsub systests tpicd udceth0 xtrac

export LDFLAGS += -L$(shell pwd)/third_party/lib
export CPPFLAGS += -I$(shell pwd)/third_party/include

all:	libs execs
#
dist:
	rm -rf /tmp/fs-$(FS_VERSION).tgz /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'core' -type f -print >  /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '#*#'          -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*~'           -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '.*~'          -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*.[oas]'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name '*.pyc'        -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION) -name 'y.tab.h'      -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION)/bin -mindepth 1 \
	                                            -name '*' -print >> /tmp/fsdist-exclude
	cd /; find usr2/fs-$(FS_VERSION)/third_party/src/* \
			! -iname '*.tar.gz' \
			! -iname '*.make'                     -print >> /tmp/fsdist-exclude 
	echo usr2/fs-$(FS_VERSION)/third_party/lib                   >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/third_party/include               >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/rclco/rcl/all                     >> /tmp/fsdist-exclude
	cd /; tar -czf /tmp/fs-$(FS_VERSION).tgz -X /tmp/fsdist-exclude usr2/fs-$(FS_VERSION)
	chmod a+rw /tmp/fs-$(FS_VERSION).tgz
#
clean:
	rm -f `find . -name 'core' -type f -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
	rm -f `find . -name '.*~' -print`
	rm -f `find . -name '*.pyc' -print`
	rm -rf third_party/include third_party/lib third_party/bin
	find third_party/src/* ! -iname '*.tar.gz' ! -iname '*.make' -delete
#
rmexe:
	rm -fr bin/*
#
rmdoto:
	rm -f `find . -name '*.[oas]' -print`
	rm -rf oprin/readline-2.0
	rm -f `find . -name '*.pyc' -print`
	rm -rf third_party/include third_party/lib third_party/bin
	find third_party/src/* ! -iname '*.tar.gz' ! -iname '*.make' -delete
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
