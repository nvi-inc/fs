LDLIBS += -lm -lncurses -pthread

ifdef FS_TINFO_LIB
LDLIBS += -ltinfo
endif

../bin/predict: predict.c

include ../include.mk
