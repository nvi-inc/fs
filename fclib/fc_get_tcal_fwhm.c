void get_tcal_fwhm();

void fc_get_tcal_fwhm__(device,tcal,fwhm,epoch,flux,corr,ssize,ierr)
char device[2];
float *tcal,*fwhm, *epoch, *flux, *corr, *ssize;
int *ierr;
{
  get_tcal_fwhm(device,tcal,fwhm,*epoch,flux,corr,ssize,ierr);
}
