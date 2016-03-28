void fc_rdbcn_d__(device,ierr,ip)
char device[2];
int *ierr;
long ip[5];
{
    void rdbcn_d();

    rdbcn_d(device,ierr,ip);
    return;
}
void fc_rdbcn_v__(dtpi,dtpi2,ip,icont,isamples)
double *dtpi,*dtpi2;
int *ip,*icont, *isamples;
{
    void rdbcn_v();

    rdbcn_v(dtpi,dtpi2,ip,icont,isamples);
    return;
}
