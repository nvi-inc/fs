#
pwd := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
FS_DIRECTORY := $(shell echo $(pwd) | rev | cut -d/ -f1 | rev )
#look for git first
FS_COMMIT := $(shell git describe --always --tags 2>/dev/null)
ifneq ($(FS_COMMIT),)
  #for old git, 1.5.6.5 in FSL8 anyway, --dirty isn't supported by
  # git describe, so we do a git diff HEAD instead (for all versions)
  # further, in 1.5.6.5, git diff HEAD --quiet thinks there is a change
  # after root does a make install, redirecting output has the opposite
  # problem, no changes are detected, but doing a git status first
  # seems to clean it up and seems benign for other versions
  FS_VERSION := $(shell git status 2>&1 >/dev/null)
  FS_VERSION := $(FS_COMMIT)$(shell git diff HEAD --quiet || echo "-dirty")
else
  #alternatively, an archive version
  # there should be no other dashes except in the basename:
  #  fs-VERSION.SUBLEVEL.PATCHLEVEL-RELEASE
  #  -RELEASE is optional
  FS_VERSION := $(shell echo $(pwd) | cut -d- -f2-)
endif
#
VERSION    := $(shell echo $(FS_VERSION) | cut -d. -f1 -s )
SUBLEVEL   := $(shell echo $(FS_VERSION) | cut -d. -f2 -s )
PATCHLEVEL := $(shell echo $(FS_VERSION) | cut -d. -f3 -s | cut -d- -f1)
RELEASE    := $(shell echo $(FS_VERSION) | cut -d- -f2- -s)

ifeq (root,$(shell whoami))
  ifneq (install,$(MAKECMDGOALS))
    $(error root can only use 'make install')
  endif
  ifeq ($(wildcard $(pwd)/.git),)
    ifeq ($(VERSION),)
      $(info Directory '$(pwd)' from archive has no VERSION value in name.)
      $(error Please fix)
    endif
    ifeq ($(SUBLEVEL),)
      $(info Directory '$(pwd)' from archive has no SUBLEVEL value in name.)
      $(error Please fix)
    endif
    ifeq ($(PATCHLEVEL),)
      $(info Directory '$(pwd)' from archive has no PATCHLEVEL value in name.)
      $(error Please fix)
    endif
  endif
#
else
  ifeq (install,$(findstring install,$(MAKECMDGOALS)))
    $(error only root can use 'make install')
  endif
  ifeq ($(VERSION),)
    ifeq ($(wildcard $(pwd)/.git),)
      $(info Improperly installed archive, the directory name is ill-formed.)
    endif
    $(error no VERSION value)
  endif
  ifeq ($(SUBLEVEL),)
    ifeq ($(wildcard $(pwd)/.git),)
      $(info Improperly installed archive, the directory name is ill-formed.)
    endif
    $(error no SUBLEVEL value)
  endif
  ifeq ($(PATCHLEVEL),)
    ifeq ($(wildcard $(pwd)/.git),)
      $(info Improperly installed archive, the directory name is ill-formed.)
    endif
    $(error no PATCHLEVEL value)
  endif
endif
export VERSION SUBLEVEL PATCHLEVEL FS_VERSION RELEASE FS_DIRECTORY
# print variable,  use 'make print-VERSION' to print VERSION
print-%  : ; @echo $* = $($*)
#
# If environment variable FS_SERIAL_CLOCAL is define with a non-empty value
#  the port library and mcbcn program will be compiled with a O_NONBLOCK
#  open of the serial port, then set CLOCAL, and then closed and re-opened
#  without O_NONBLOCK. This also impacts and programs that call
#  portopen(), including ibcon.
#
LIB_DIR = clib flib bosslb fclib fmpsee fslb lnfch newlb polb port rtelb vis \
poclb skdrlnfch skdrut vex rclco/rcl s2das

ifndef FS_DISPLAY_SERVER_NO_MAKE
LIB_DIR += third_party
endif

EXE_DIR = rwand chekr fserr ddout fs fsalloc incom matcn oprin pcalr onoff \
fivpt pfmed error resid sigma xtrac boss antcn monit run labck setcl aquir \
quikv mcbcn brk moon logex headp fmset ibcon quikr rte_go drudg rclcn pdplt \
lognm pcald msg fsvue fs.prompt inject_snap erchk mk5cn tpicd flagr \
gnfit gndat dscon systests autoftp logpl1 holog gnplt1 predict \
dbbcn rdbcn rdtcn mk6cn popen udceth0 rack mcicn lgerr fesh\
plog new_ifdbb streamlog dbtcn core3h_conf

ifeq ($(FS_PYTHON_VERSION),2)
EXE_DIR += logpl-python2 gnplt-python2 monpcal-python2 be_client-python2 s_client-python2 rdbemsg-python2
else
EXE_DIR += logpl gnplt monpcal be_client s_client rdbemsg
endif

ifndef FS_DISPLAY_SERVER_NO_MAKE
EXE_DIR += fsserver
endif

export LDFLAGS += -L$(shell pwd)/third_party/lib
export CPPFLAGS += -I$(shell pwd)/third_party/include

.PHONY: all $(LIB_DIR) $(EXE_DIR) version

all: version $(EXE_DIR)

FS_VERSION_FILE=.fs_version
ifeq ($(FS_VERSION_FILE),$(wildcard $(FS_VERSION_FILE)))
	FS_VERSION_FILE_STRING :=$(shell cat $(FS_VERSION_FILE))
else
	FS_VERSION_FILE_STRING =
endif

version:
ifneq ($(FS_VERSION),$(FS_VERSION_FILE_STRING))
	rm -f drudg/get_version.o drudg/crelease.o incom/sincom.o incom/crelease.o
	echo -n $(FS_VERSION) >$(FS_VERSION_FILE)
else
	
endif

$(EXE_DIR): bin $(LIB_DIR)

bin:
	mkdir bin

$(LIB_DIR) $(EXE_DIR):
	$(MAKE) -C $@

.PHONY: dist clean rmexe rmdoto install tag_archive archive
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
			! -iname '*.tar.gz'   \
			! -iname '*.template' \
			! -iname '*.make'                     -print >> /tmp/fsdist-exclude 
	echo usr2/fs-$(FS_VERSION)/third_party/lib                   >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/third_party/include               >> /tmp/fsdist-exclude
	echo usr2/fs-$(FS_VERSION)/rclco/rcl/all                     >> /tmp/fsdist-exclude
	cd /; tar -czf /tmp/fs-$(FS_VERSION).tgz -X /tmp/fsdist-exclude usr2/fs-$(FS_VERSION)
	chmod a+rw /tmp/fs-$(FS_VERSION).tgz

clean:
	rm -f `find . -name 'core' -type f -print`
	rm -f `find . -name '#*#' -print`
	rm -f `find . -name '*~' -print`
	rm -f `find . -name '.*~' -print`
	rm -f `find . -name '*.pyc' -print`
	rm -rf third_party/include third_party/lib third_party/bin
	find third_party/src/* \
		! -iname '*.tar.gz' \
		! -iname '*.make' \
		! -iname '*.template' \
		-delete
#
rmexe:
	rm -fr bin/*

rmdoto:
	rm -f `find . -name '*.[oas]' -print`
	rm -rf oprin/readline-2.0
	rm -f `find . -name '*.pyc' -print`
	rm -rf third_party/include third_party/lib third_party/bin
	find third_party/src/* \
		! -iname '*.tar.gz' \
		! -iname '*.make' \
		! -iname '*.template' \
		-delete
#
libs:
	for dir in $(LIB_DIR); do\
		$(MAKE) --no-print-directory -C $$dir ;\
	done
#
execs:
	for dir in $(EXEC_DIR); do \
		$(MAKE) --no-print-directory -C $$dir; \
	done
install:
	sh misc/fsinstall
#
# use 'make TAG=value tag_archive' to make an archive for a git tag
# TO DO: detect missing TAG value and print error
tag_archive:
	git archive --format=tgz --prefix=usr2/fs-$(TAG)/ -o /tmp/fs-$(TAG).tgz $(TAG)
#
# the following works to make an archive for commits after 10.0.0-alpha2
# checkout the commit and then 'make archive'
archive:
	git archive --format=tgz --prefix=usr2/fs-$(FS_COMMIT)/ -o /tmp/fs-$(FS_COMMIT).tgz HEAD
