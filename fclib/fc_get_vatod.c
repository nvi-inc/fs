void fc_get_vatod__(ichan, volt, ip, indxtp)
int *ichan;
float *volt;
int ip[5];
int *indxtp;
{
    void get_vatod();

    get_vatod(*ichan, volt, ip, *indxtp);
    return;
}
