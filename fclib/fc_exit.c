void fc_exit_( status)
int *status;
{
    void exit();

    exit( *status);
}
