      Subroutine wrdate(lu,iyr,idayr)
C  Write a line in the VLBA output file with the new date.
C  NRV 910705
C 980910 nrv Write out the full 4-digit year.
! 2006Sep28 rewritten to use ascii.

C Input:
      integer lu,iyr,idayr
C  lu - output unit
C  iyr - year, e.g. 1991, i.e. 4-digits
C  idayr - day of year, e.g. 201
C
C Local:
      integer*2 lmon(2),lday(2)
      character*3 cmon
      equivalence (lmon,cmon)

      integer imon,ida
      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      write(lu,'("date = ",i4,a,i2.2)') iyr,cmon,ida
      return
      end
