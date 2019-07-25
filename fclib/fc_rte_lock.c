void fc_rte_lock__(ivalue)
int *ivalue;
{
     void rte_lock();

     rte_lock(*ivalue);

     return;
}
