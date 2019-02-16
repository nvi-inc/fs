int fc_skd_end_insnp__( name, ip)
char name[5];
int *ip;
{
      int skd_end_inject_snap();

      return skd_end_inject_snap( name, ip);
}
