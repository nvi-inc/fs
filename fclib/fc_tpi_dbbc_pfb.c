void fc_tpi_dbbc_pfb__(ip,itpis_dbbc_pfb)
int ip[5];
int itpis_dbbc_pfb[];
{
    void tpi_dbbc_pfb();

    tpi_dbbc_pfb(ip,itpis_dbbc_pfb);

    return;
}
    
void fc_tpput_dbbc_pfb__(ip,itpis_dbbc_pfb,isub,ibuf,nch,ilen)
int ip[5];
int itpis_dbbc_pfb[];
int *isub;
char *ibuf;
int *nch;
int *ilen;
{
    void tpput_v();

    tpput_dbbc_pfb(ip,itpis_dbbc_pfb,*isub,ibuf,nch,*ilen);

    return;
}

void fc_tsys_dbbc_pfb__(ip,itpis_dbbc_pfb,ibuf,nch,itask)
int ip[5];
int itpis_dbbc_pfb[];
char *ibuf;
int *nch;
int *itask;
{
    void tsys_dbbc_pfb();

    tsys_dbbc_pfb(ip,itpis_dbbc_pfb,ibuf,nch,*itask);

    return;
}
