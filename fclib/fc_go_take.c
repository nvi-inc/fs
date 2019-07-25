int fc_go_take__( name, flags, lenn)
char	name[5];	
int     *flags, lenn;
{
    int go_take();

    return( go_take( name, *flags));
}
