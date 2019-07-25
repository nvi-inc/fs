void fc_chmod__(filename,permissions,ilen,error,flen)
char *filename;
int *permissions;
int *ilen;
int *error;
int flen;
{
    cchmod(filename,permissions,ilen,error,flen);
}
