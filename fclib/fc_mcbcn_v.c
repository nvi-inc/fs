void fc_mcbcn_d_(device,ierr)
char device[2];
int *ierr;
{
    void mcbcn_d();

    mcbcn_d(device,ierr);
    return;
}
void fc_mcbcn_v_(dtpi,ip)
double *dtpi;
long ip[5];
{
    void mcbcn_v();

    mcbcn_v(dtpi,ip);
    return;
}
