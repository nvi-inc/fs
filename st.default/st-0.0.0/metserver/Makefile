#
LIB_DIR = lib
ST_ROOT = /usr2/st
#
EXEC_DIR = src lib
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
