CFLAGS = -Wall -O3 -s -fomit-frame-pointer -lm -lncurses -pthread
ifdef FS_TINFO_LIB
CFLAGS = -Wall -O3 -s -fomit-frame-pointer -ltinfo -lm -lncurses -pthread
endif
#
../bin/predict: predict.c
	cc $(CFLAGS) predict.c -o ../bin/predict
	strip ../bin/predict

predict:
	rm -f ../bin/predict
	make
#
