      subroutine drchmod(cname,iperm,ierr)
C 960223 nrv New.
C Input
      character*128 cname
      integer iperm
C Output
      integer ierr
C Local
      integer trimlen,ic

      ic=trimlen(cname)
      if (ic.le.64) then
        call fc_chmod(cname(1:64),iperm,ic,ierr)
        if (ierr.ne.0) then
          write(luscn,9903) ierr,iperm,cname(1:ic)
9903      format(' DRCHMOD01 - Error ',i5,' changing permissions ',
     .    'to ',o4,' for file ',a)
        endif
      else
        write(luscn,9904) cname(1:ic)
9904    format(' DRCHMOD02 - File name ',a,' too long for Field ',
     .  'System use. Permissions not changed.')
      endif

      return
      end
