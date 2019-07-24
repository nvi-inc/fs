# backup script for /usr2/fs, for root user only
ulimit 409600
cd /usr2/
rm /tmp/FSS
rm /tmp/fs.cpio
find fs \! -name '*.o' \! -name '*.a' \! -perm -1 -print > /tmp/FSS
find fs  -type d -print >> /tmp/FSS
cat /tmp/FSS | cpio -ocvB > /tmp/fs.cpio
/usr/bin/X11/compress /tmp/fs.cpio
