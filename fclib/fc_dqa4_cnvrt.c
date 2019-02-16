void fc_dqa4_cnvrt__(ibuf,jfrms,jperr,jsync,ierr)
char *ibuf;
int jfrms[2];
int jperr[2];
int jsync[2];
int *ierr;
{
  void dqa4_cnvrt();

  dqa4_cnvrt(ibuf,jfrms,jperr,jsync,ierr);

  return;
}
