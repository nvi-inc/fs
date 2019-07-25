#
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
file=/boot/gpib0.o
if [ -f ${file} ]
then
	/sbin/insmod ${file}
	/sbin/lsmod
fi
file=/usr/bin/X11/xdm
if [ -f ${file} ]
then
	${file}
fi
