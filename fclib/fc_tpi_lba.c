void fc_tpi_lba__(ip,itpis_lba)
long ip[5];
int itpis_lba[34];
{
    void tpi_lba();

    tpi_lba(ip,itpis_lba);

    return;
}
    
void fc_tpput_lba__(ip,itpis_lba,isub,ibuf,nch,ilen)
long ip[5];
int itpis_lba[34];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_lba();

    tpput_lba(ip,itpis_lba,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_lba__(ip,itpis_lba,ibuf,nch,itask)
long ip[5];
int itpis_lba[34];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_lba();

    tsys_lba(ip,itpis_lba,ibuf,nch,*itask);

    return;
}
