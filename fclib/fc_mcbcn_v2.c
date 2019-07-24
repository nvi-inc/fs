void fc_mcbcn_d2_(device1,device2,ierr)
char device1[2],device2[2];
int *ierr;
{
    void mcbcn_d2();

    mcbcn_d2(device1,device2,ierr);
    return;
}
void fc_mcbcn_v2_(dtpi1,dtpi2,ip)
double *dtpi1,*dtpi2;
long ip[5];
{
    void mcbcn_v2();

    mcbcn_v2(dtpi1,dtpi2,ip);
    return;
}
