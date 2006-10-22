      Subroutine wrday(lu,iyr,idayr)
C  Write a line in the SNAP summary with the new date.
C History
C 990305 nrv New. Copied from wrdate.
!     2006Sep28 Rewrriten to remove hollerith

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

      imon = 0
      ida = idayr
      call clndr(iyr,imon,ida,lmon,lday)
      write(lu,'("date = ",i4,a3,i2,"  DOY = ",i3)')
     > iyr,cmon,ida,idayr

      return
      end
