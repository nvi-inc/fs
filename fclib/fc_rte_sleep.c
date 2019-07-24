int fc_rte_sleep_( centisec)
int *centisec;
{
    unsigned rte_sleep();

    return((int) rte_sleep((unsigned) *centisec));
}
