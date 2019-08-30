void fc_r2dbcn_d__(device,ierr,ip)
char device[2];
int *ierr;
long ip[5];
{
    void rdbcn_d();

    r2dbcn_d(device,ierr,ip);
    return;
}
void fc_r2dbcn_v__(dtpi,dtpi2,ip,icont,isamples)
double *dtpi,*dtpi2;
int *ip,*icont, *isamples;
{
    void rdbcn_v();

    r2dbcn_v(dtpi,dtpi2,ip,icont,isamples);
    return;
}
