int fc_get_fila10gtime__(centisec,fm_tim,ip,to)
long centisec[6];
int fm_tim[6];
long ip[5];
int *to;
{

  return get_fila10gtime(centisec,fm_tim,ip,*to);

}
