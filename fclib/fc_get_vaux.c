void fc_set_vrptrk_(itrk, ip)
int itrk[2];
long ip[5];
{
  void set_vrptrk();

  set_vrptrk( itrk, ip);

  return;
}
void fc_get_verate_(jperr,jsync,itrk,itper,ip)
long jperr[2];
long jsync[2];
int itrk[2];
int *itper;
long ip[5];
{
  void get_verate();

  get_verate(jperr,jsync,itrk,*itper,ip);

  return;
}
void fc_get_vaux_(iaux,itrk,ip)
int iaux[2];
int itrk[2];
long ip[5];
{
  void get_vaux();

  get_vaux(iaux,itrk,ip);

  return;
}
