      Subroutine wrdate(lu,iyr,idayr)
C  Write a line in the VLBA output file with the new date.
C  NRV 910705

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Input:
      integer lu,iyr,idayr
C  lu - output unit
C  iyr - year, e.g. 1991
C  idayr - day of year, e.g. 201
C
C Local:
      integer*2 lmon(2),lday(2)
      integer izero2,Z4000,Z100
      integer imon,ida,iblen,idum,ierr
      integer ib2as,ichmv
      data Z4000/Z'4000'/, Z100/Z'100'/
      
      izero2 = 2+Z4000+Z100*2

      iblen = 2*IBUF_LEN
      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      call ifill(ibuf,1,iblen,32)
      call char2hol('date = ',ibuf(1),1,7)
      idum = ib2as(iyr-1900,ibuf,8,izero2)
      idum = ichmv(ibuf,10,lmon,1,3)
      idum = ib2as(ida,ibuf,13,izero2)
      call writf_asc(lu,ierr,ibuf,7)
      call ifill(ibuf,1,iblen,32)

      return
      end
