void fc_nsem_put__( name, lenn)
char	name[5];	
int     lenn;
{
   void nsem_put();

   nsem_put(name);

   return;
}
