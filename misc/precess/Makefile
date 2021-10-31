OBJECTS = precess.o kgetc.o kputc.o
LIBS = ../../fslb/fslb.a

.PHONY: start

#FFLAGS=-g
LDLIBS += $(FLIBS)
FFLAGS += -cpp
ifeq (sofa,$(wildcard sofa))
	SOFA = sofa/20210512/f77/src/libsofa.a
	FFLAGS += -DSOFA
endif

ifdef SOFA
start: remove precess2
else
start: remove precess
endif

remove:
	rm -f precess2 precess.o

precess: $(OBJECTS) $(LIBS)
ifdef SOFA
precess: $(SOFA)
endif

precess2: precess
	ln -fsn precess precess2

include ../../include.mk
