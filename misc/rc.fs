#!/bin/sh
### BEGIN INIT INFO
# Provides:          fs
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     S
# Default-Stop:      
# Short-Description: Allocate FS shared memory
# Description:       Run /usr2/fs/bin/fsalloc and /usr2/st/bin/stalloc if they exist
#                    to allocate the shared memory blocks used by the Field System.
### END INIT INFO

file=/usr2/fs/bin/fsalloc
if [ -f ${file} ]
then
	${file}
fi
#
file=/usr2/st/bin/stalloc
if [ -f ${file} ]
then
	${file}
fi
#
