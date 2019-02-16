void fc_skd_wait__( name, ip, centisec, len)
char name[5];
int *ip;
int *centisec, len;
{
      void skd_wait();

      skd_wait( name, ip, (unsigned) *centisec);

      return;
}
