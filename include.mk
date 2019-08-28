# This file needs to be included at the end a makefile, since it includes targets and will override the default

ROOT := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

FC = f95

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

COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cc = $(CXX) $(DEPFLAGS) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
POSTCOMPILE = mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

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

../bin/%:
	$(LINK.o) $+ $(LOADLIBES) $(LDLIBS) -o $@

%.a:
	ar rcs $@ $^

clean: 
	-rm -f $(OBJECTS)
	-rm -f $(TARGETS)
	-rm -rf $(DEPDIR)
