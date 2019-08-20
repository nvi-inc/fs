void fc_vget_att__(lwho,ip,ichain1,ichain2)
char lwho[2];
int ip[5];
int *ichain1,*ichain2;
{
    void vget_att();

    vget_att(lwho,ip,*ichain1,*ichain2);
    return;
}
void fc_vset_zero__(lwho,ip)
char lwho[2];
int ip[5];
{
    void vset_zero();

    vset_zero(lwho,ip);
    return;
}
void fc_vrst_att__(lwho,ip)
char lwho[2];
int ip[5];
{
    void vrst_att();

    vrst_att(lwho,ip);
    return;
}
