int fc_rte_alarm_( centisec)
int *centisec;
{
    unsigned rte_alarm();

    return((int) rte_alarm((unsigned) *centisec));
}
