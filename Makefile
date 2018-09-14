#
pwd = $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
FS_VERSION := $(shell echo $(pwd) | cut -d- -f2-)
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
poclb skdrut vex rclco/rcl s2das
#
EXEC_DIR = rwand chekr fserr ddout fs fsalloc incom matcn oprin pcalr onoff \
fivpt pfmed error resid sigma xtrac boss antcn monit run labck setcl aquir \
quikv mcbcn brk moon logex headp fmset ibcon quikr go drudg rclcn pdplt logpl \
lognm pcald msg fsvue fs.prompt inject_snap erchk mk5cn tpicd flagr \
gnfit gndat gnplt dscon systests autoftp monpcal logpl1 holog gnplt1 predict \
dbbcn popen s_client lgerr fesh plog
#

# If environment variable FS_DISPLAY_SERVER is defined with a non-empty value
# the FS will be build with the display client/server.

ifdef FS_DISPLAY_SERVER
export LDFLAGS += -L$(shell pwd)/third_party/lib
export CPPFLAGS += -I$(shell pwd)/third_party/include
LIB_DIR += third_party
EXEC_DIR += spubsub fsserver
endif

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
