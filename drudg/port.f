      SUBROUTINE PORT

C   This routine will change the printer output destination and
C   the printer type and the output width.

C  COMMON BLOCKS:
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  History:
C  901018 NRV Changed variable name, changed logic to leave port
C             set if user types <return>.
C  901205 NRV Moved width option in here from main program.
C  911127 NRV Added EPSON24 option
C  940725 nrv Add dos/ux option
C  950829 nrv linux version, copied from PC-DRUDG
C 970207 nrv Change prompt to use the word "destination"
C 970207 nrv Remove FILE option in printer type. This is the
C            same as using a file name in printer port.
C 970301 nrv Add font size prompt.
C
C  Local:
      character*128 ctemp
      integer*2 itemp(10)
      integer trimlen
      integer nch,l,ierr,idummy,ichmv
C

C  1.0  Read the input from user and set port appropriatly.

      l=trimlen(cprport)
      write(luscn,9100) cprport(1:l)
9100  format(' Output destination set to ',A,'.  Just enter ',
     .       'return if you do not wish '/' to change, else type a ',
     .       'file name or PRINT  ? ')

      call gtrsp(ibuf,25,luusr,nch)
      if(nch .gt. 0) cprport(1:nch)=cbuf(1:nch)

      if (cprport(1:5).eq.'print') cprport='PRINT'

C  2.0  Now get printer type.

      ierr=1
      l=trimlen(cprttyp)
      do while (ierr.ne.0)
        write(luscn,9200) cprttyp(1:l)
9200    format(' Printer type set to ',A,'.  Just enter return ',
     .  'if you do not wish to change,'/' else type LASER, EPSON, ',
     .  'or EPSON24 ? ')

        cbuf=" "
        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          ctemp=cbuf(1:nch)
          if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER' .or.
     >        ctemp.eq.'EPSON24') then
            cprttyp=ctemp
            ierr=0
          else
            write(luscn,'(a)') " Invalid printer type.  Only LASER, "//
     >        "EPSON,  'or EPSON24 allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

C  3. Now get printer output orientation.

      if(cpaper_size(1:1) .eq. "D") then
        ctemp="DEFAULT"
      else if(cpaper_size(1:1) .eq. "P") then
        ctemp="Portrait"
      else if(cpaper_size(1:1) .eq. "L") then
        ctemp="Landscape"
      endif

      l=trimlen(ctemp)
      ierr=1
      do while (ierr.ne.0)
        write(luscn,9300) ctemp(1:l)
9300    format(' Output orientation set to ',a,'.  Just enter return ',
     .  'if you do not wish'/' to change else enter (P)ortrait or',
     .  ' (L)andscape or (D)efault ?  ')

        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          call capitalize(cbuf)
          if(cbuf(1:1) .eq. "L" .or. cbuf(1:1) .eq. "P" .or.
     >       cbuf(1:1) .eq. "D") then
             cpaper_size(1:1)=cbuf(1:1)
             ierr=0
          else
            write(luscn,'(a)') "' Invalid output width. "//
     >         "Only P, L, or D allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

C  4. Now get font size.
      if(cpaper_size(1:1) .eq. "D") then
        ctemp="DEFAULT"
      else if(cpaper_size(1:1) .eq. "S") then
        ctemp="Small"
      else if(cpaper_size(1:1) .eq. "L") then
        ctemp="Large"
      endif
      ierr=1
      l=trimlen(ctemp)
      do while (ierr.ne.0)
        write(luscn,9400) ctemp(1:l)
9400    format(' Output font size set to ',a,'.  Just enter return ',
     .  'if you do not wish'/' to change else enter (S)mall, ',
     .  '(L)arge or (D)efault ?  ')

        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          call capitalize(cbuf)
          if(cbuf(1:1) .eq. "L" .or. cbuf(1:1) .eq. "S" .or.
     >       cbuf(1:1) .eq. "D") then
             cpaper_size(2:2)=cbuf(1:1)
             ierr=0
          else
            write(luscn,'(a)') "' Invalid output width. "//
     >         "Only L, S, or D allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

      RETURN
      END
