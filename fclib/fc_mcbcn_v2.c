void fc_mcbcn_d2__(device1,device2,ierr,ip)
char device1[2],device2[2];
int *ierr;
long ip[5];
{
    void mcbcn_d2();

    mcbcn_d2(device1,device2,ierr,ip);
    return;
}
void fc_mcbcn_v2__(dtpi1,dtpi2,ip)
double *dtpi1,*dtpi2;
long ip[5];
{
    void mcbcn_v2();

    mcbcn_v2(dtpi1,dtpi2,ip);
    return;
}
void fc_mcbcn_r2__(ip)
long ip[5];
{
    void mcbcn_r2();

    mcbcn_r2(ip);
    return;
}
