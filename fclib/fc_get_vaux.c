void fc_set_vrptrk__(itrk, ip,indxtp)
int itrk[2];
long ip[5];
int *indxtp;
{
  void set_vrptrk();

  set_vrptrk( itrk, ip, *indxtp);

  return;
}
void fc_get_verate__(jperr,jsync,jbits,itrk,itper,ip)
long jperr[2];
long jsync[2];
long jbits[2];
int itrk[2];
int *itper;
long ip[5];
{
  void get_verate();

  get_verate(jperr,jsync,jbits,itrk,*itper,ip);

  return;
}
void fc_get_vaux__(iaux,itrk,ip)
int iaux[2];
int itrk[2];
long ip[5];
{
  void get_vaux();

  get_vaux(iaux,itrk,ip);

  return;
}
