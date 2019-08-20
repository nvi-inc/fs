void fc_dbbcn_pfb_d__(device,ierr,ip)
char device[2];
int *ierr;
int ip[5];
{
    void dbbcn_pfb_d();

    dbbcn_pfb_d(device,ierr,ip);
    return;
}
void fc_dbbcn_pfb_v__(dtpi,ip)
double *dtpi;
int ip[5];
{
    void dbbcn_pfb_v();

    dbbcn_pfb_v(dtpi,ip);
    return;
}
void fc_dbbcn_pfb_r__(ip)
int ip[5];
{
    void dbbcn_pfb_r();

    dbbcn_pfb_r(ip);
    return;
}
