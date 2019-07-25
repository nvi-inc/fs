void fc_mcbcn_d__(device,ierr,ip)
char device[2];
int *ierr;
long ip[5];
{
    void mcbcn_d();

    mcbcn_d(device,ierr,ip);
    return;
}
void fc_mcbcn_v__(dtpi,ip)
double *dtpi;
long ip[5];
{
    void mcbcn_v();

    mcbcn_v(dtpi,ip);
    return;
}
void fc_mcbcn_r__(ip)
long ip[5];
{
    void mcbcn_r();

    mcbcn_r(ip);
    return;
}
