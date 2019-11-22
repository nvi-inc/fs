# This file needs to be included at the end a makefile, since it includes targets and will override the default

ROOT := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

ifndef FC
FC = f95
endif

CFLAGS += -Werror=int-to-pointer-cast

ifeq ($(FC),fort77)
FLIBS   += -lf2c -lm
else
FFLAGS  += -ff2c -I$(ROOT)/include -fno-range-check -finit-local-zero -fno-automatic -fbackslash
FLIBS   += -lgfortran -lm
endif

LDFLAGS += -L$(ROOT)/third_party/lib
CPPFLAGS += -I$(ROOT)/third_party/include

DEBUG_FLAGS = -g3 -ggdb

ifeq ($(DEBUG),1)
FFLAGS  += $(DEBUG_FLAGS)
CFLAGS  += $(DEBUG_FLAGS)
CPPFLAGS  += $(DEBUG_FLAGS)
LDFLAGS += $(DEBUG_FLAGS)
endif


# Dependency generation, see http://make.mad-scientist.net/papers/advanced-auto-dependency-generation
DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

CP = cp

ifndef V
CCCOLOR="\033[34m"
LINKCOLOR="\033[34;1m"
SRCCOLOR="\033[33m"
BINCOLOR="\033[37;1m"
MAKECOLOR="\033[32;1m"
ENDCOLOR="\033[0m"

OLD_CC := $(CC)
OLD_FC := $(FC)
OLD_LINK := $(LINK)
OLD_AR := $(AR)
OLD_INSTALL := $(INSTALL)
OLD_MAKE := $(MAKE)

QUIET_CC      = @printf '    %b %b\n' $(CCCOLOR)CC$(ENDCOLOR) $(SRCCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_FC      = @printf '    %b %b\n' $(CCCOLOR)FC$(ENDCOLOR) $(SRCCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_AR      = @printf '    %b %b\n' $(LINKCOLOR)AR$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_LINK    = @printf '    %b %b\n' $(LINKCOLOR)LINK$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_MAKE    = @printf '    %b %b\n' $(MAKECOLOR)MAKE$(ENDCOLOR) $@ 1>&2;

CC   = $(QUIET_CC)$(OLD_CC)
FC   = $(QUIET_FC)$(OLD_FC)
LD   = $(QUIET_LINK)$(OLD_LD)
AR   = $(QUIET_AR)$(OLD_AR)
MAKE = $(QUIET_MAKE)$(OLD_MAKE) --no-print-directory

endif


COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cc = $(CXX) $(DEPFLAGS) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

%.o : %.c
%.o : %.c $(DEPDIR)/%.d
	$(COMPILE.c) $(OUTPUT_OPTION) $<
	$(POSTCOMPILE)

%.o : %.cc
%.o : %.cc $(DEPDIR)/%.d
	$(COMPILE.cc) $(OUTPUT_OPTION) $<
	$(POSTCOMPILE)

%.o : %.cxx
%.o : %.cxx $(DEPDIR)/%.d
	$(COMPILE.cc) $(OUTPUT_OPTION) $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(OBJECTS))))

../bin/%: | %.f
	$(FC) $+ $(LOADLIBES) $(LDLIBS) -o $@

../bin/%:
	$(LINK.o) $+ $(LOADLIBES) $(LDLIBS) -o $@

%.a:
	$(AR) rcs $@ $^

clean: 
	-rm -f $(OBJECTS)
	-rm -f $(TARGETS)
	-rm -rf $(DEPDIR)
