void fc_rte_lock_(ivalue)
int *ivalue;
{
     void rte_lock();

     rte_lock(*ivalue);

     return;
}
