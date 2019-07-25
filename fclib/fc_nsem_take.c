int fc_nsem_take__( name, flags, lenn)
char	name[5];	
int     *flags, lenn;
{
    int nsem_take();

    return( nsem_take( name, *flags));
}
