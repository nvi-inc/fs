void fc_dqa4_cnvrt__(ibuf,jfrms,jperr,jsync,ierr)
char *ibuf;
long jfrms[2];
long jperr[2];
long jsync[2];
int *ierr;
{
  void dqa4_cnvrt();

  dqa4_cnvrt(ibuf,jfrms,jperr,jsync,ierr);

  return;
}
