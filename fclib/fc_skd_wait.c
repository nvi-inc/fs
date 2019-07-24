void fc_skd_wait_( name, ip, centisec, len)
char name[5];
long *ip;
int *centisec, len;
{
      void skd_wait();

      skd_wait( name, ip, (unsigned) *centisec);

      return;
}
