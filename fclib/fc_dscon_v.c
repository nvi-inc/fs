void fc_dscon_d__(device,ierr,ip)
char device[2];
int *ierr;
long ip[5];
{
    void dscon_d();

    dscon_d(device,ierr,ip);
    return;
}
void fc_dscon_v__(dtpi,ip)
double *dtpi;
long ip[5];
{
    void dscon_v();

    dscon_v(dtpi,ip);
    return;
}
