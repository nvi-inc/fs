int fc_get_vtime__(centisec,fm_tim,ip,to)
long centisec[6];
int fm_tim[6];
long ip[5];
int *to;
{

  return get_vtime(centisec,fm_tim,ip,*to);

}
