      Subroutine wrdate(lu,iyr,idayr)
C  Write a line in the VLBA output file with the new date.
C  NRV 910705
C 980910 nrv Write out the full 4-digit year.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Input:
      integer lu,iyr,idayr
C  lu - output unit
C  iyr - year, e.g. 1991, i.e. 4-digits
C  idayr - day of year, e.g. 201
C
C Local:
      integer*2 lmon(2),lday(2)
      integer izero2,Z4000,Z100,izero4
      integer imon,ida,iblen,ierr,nch
      integer ib2as,ichmv,ichmv_ch
      data Z4000/Z'4000'/, Z100/Z'100'/
      
      izero2 = 2+Z4000+Z100*2
      izero4 = 4+Z4000+Z100*4

      iblen = 2*IBUF_LEN
      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      call ifill(ibuf,1,iblen,32)
      nch = ichmv_ch(ibuf,1,'date = ')
C     Format the date for the "date" command.
      nch = nch + ib2as(iyr,ibuf,nch,izero4)
      nch = ichmv(ibuf,nch,lmon,1,3)
      nch = nch + ib2as(ida,ibuf,nch,izero2)
      call writf_asc(lu,ierr,ibuf,(nch+1)/2)

      return
      end
