void fc_get_vtime_(cpu_bef,cpu_aft,fm_tim,ip)
int cpu_bef[6];
int cpu_aft[6];
int fm_tim[6];
long ip[5];
{
  void get_vtime();

  get_vtime(cpu_bef,cpu_aft,fm_tim,ip);

  return;
}
