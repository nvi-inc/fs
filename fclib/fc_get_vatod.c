void fc_get_vatod_(ichan, volt, ip)
int *ichan;
float *volt;
long ip[5];
{
    void get_vatod();

    get_vatod(*ichan, volt, ip);
    return;
}
