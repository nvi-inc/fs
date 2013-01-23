#
LIB_DIR = port
#
EXEC_DIR = src
#
all:	libs execs
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
