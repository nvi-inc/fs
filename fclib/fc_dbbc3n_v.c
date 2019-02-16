void fc_dbbc3n_d__(device,ierr,ip)
char device[2];
int *ierr;
int ip[5];
{
    void dbbc3n_d();

    dbbc3n_d(device,ierr,ip);
    return;
}
void fc_dbbc3n_v__(dtpi,dtpi2,ip,icont,isamples)
double *dtpi,*dtpi2;
int ip[5];
int *icont, *isamples;
{
    void dbbc3n_v();

    dbbc3n_v(dtpi,dtpi2,ip,icont,isamples);
    return;
}
void fc_dbbc3n_r__(ip)
int ip[5];
{
    void dbbc3n_r();

    dbbc3n_r(ip);
    return;
}
