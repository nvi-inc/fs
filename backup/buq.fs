# backup script for /usr2/fs, for root user only
ulimit 409600
cd /usr2/
rm /tmp/FSS
rm /tmp/fs.cpio
find fs  -type d -print > /tmp/FSS
find fs \! -name '*.o' \! -name '*.a' \! -perm -1 -print >> /tmp/FSS
find st.default -perm -1 ! -type d -print >>/tmp/FSS
cat /tmp/FSS | cpio -ocB > /tmp/fs.cpio
/usr/bin/X11/compress /tmp/fs.cpio
