# quick backup for st
ulimit 409600
cd /usr2/
rm /tmp/FSS
rm /tmp/st.cpio
find st \! -name '*.o' \! -name '*.a' \! -perm -1 -print > /tmp/FSS
find st  -type d -print >> /tmp/FSS
find proc -print      >> /tmp/FSS
find control -print >> /tmp/FSS
find oper -print >> /tmp/FSS
find prog -print >> /tmp/FSS
find dos  -print >> /tmp/FSS
ls sched/*hdcal.snp >> /tmp/FSS
ls sched/prepass.snp >> /tmp/FSS
cat /tmp/FSS | cpio -ovcB > /tmp/st.cpio
/usr/bin/X11/compress /tmp/st.cpio
