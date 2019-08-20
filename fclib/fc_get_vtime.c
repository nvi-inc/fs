int fc_get_vtime__(centisec,fm_tim,ip,to)
int centisec[6];
int fm_tim[6];
int ip[5];
int *to;
{

  return get_vtime(centisec,fm_tim,ip,*to);

}
