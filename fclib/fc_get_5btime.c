int fc_get_5btime__(centisec,fm_tim,ip,to,m5sync,m5pps,m5freq,m5clock,
		    sz_m5sync,sz_m5pps,sz_m5freq,sz_m5clock)
long centisec[6];
int fm_tim[6];
long ip[5];
int *to;
char *m5sync;
int sz_m5sync;
char *m5pps;
int sz_m5pps;
char *m5freq;
int sz_m5freq;
char *m5clock;
int sz_m5clock;
{

  return get_5btime(centisec,fm_tim,ip,*to,m5sync,sz_m5sync,m5pps,sz_m5pps,
		    m5freq,sz_m5freq,m5clock,sz_m5clock);

}
