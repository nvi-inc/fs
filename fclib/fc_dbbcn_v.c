void fc_dbbcn_d__(device,ierr,ip)
char device[2];
int *ierr;
int ip[5];
{
    void dbbcn_d();

    dbbcn_d(device,ierr,ip);
    return;
}
void fc_dbbcn_v__(dtpi,dtpi2,ip,icont,isamples)
double *dtpi,*dtpi2;
int ip[5];
int *icont, *isamples;
{
    void dbbcn_v();

    dbbcn_v(dtpi,dtpi2,ip,icont,isamples);
    return;
}
void fc_dbbcn_r__(ip)
int ip[5];
{
    void dbbcn_r();

    dbbcn_r(ip);
    return;
}
