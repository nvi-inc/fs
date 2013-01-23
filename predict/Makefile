CFLAGS = -Wall -O3 -s -fomit-frame-pointer -lm -lncurses -pthread
#
../bin/predict: predict.c
	cc $(CFLAGS) predict.c -o ../bin/predict
	strip ../bin/predict

predict:
	rm -f ../bin/predict
	make
#
