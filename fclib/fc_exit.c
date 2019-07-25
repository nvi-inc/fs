void fc_exit__( status)
int *status;
{
    void exit();

    exit( *status);
}
