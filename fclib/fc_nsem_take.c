int fc_nsem_take_( name, flags, lenn)
char	name[5];	
int     *flags, lenn;
{
    int nsem_take();

    return( nsem_take( name, *flags));
}
