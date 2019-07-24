      logical function koutp(lu,idcb,idcbs,iapp,ipbuf)

      integer idcb(2)
      character*(*) ipbuf
C
      logical kexist
      integer IERR
      integer permissions
      integer ilen, trimlen
C
      inquire(file=ipbuf,exist=kexist)
      if (iapp.eq.1) then    ! Append
        call fmpopen(idcb,ipbuf,ierr,'a+',idum)
cxx      else if (iapp.eq.0) then  ! Overwrite
      else 
        call fmpopen(idcb,ipbuf,ierr,'w+',idum)
      endif
C
      if (ierr.eq.0) goto 2000
C
      koutp=.true.
      return
C
2000  continue
      if(.not.kexist) then
        permissions = o'0666'
        ilen=trimlen(ipbuf)
        call fc_chmod(ipbuf,permissions,ilen,ierr)
      endif
      koutp=.false.
c
      return
      end
