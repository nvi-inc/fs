unsigned rte_alarm( centisec)
unsigned centisec;
{
    unsigned alarm();

    return( alarm( (centisec+99)/100));
}
