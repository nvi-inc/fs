ST_ROOT = /usr2/st
#
EXEC_DIR = src
#
all:	execs
#
execs:
	for dir in $(EXEC_DIR); do \
		make --no-print-directory -C $$dir; \
	done
