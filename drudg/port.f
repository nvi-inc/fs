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
      character*128 ctemp,ctemp2
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

      if (nch.gt.0) call hol2char(ibuf,1,nch,cprport)
      if (cprport(1:5).eq.'print') cprport='PRINT'

C  2.0  Now get printer type.

      ierr=1
      l=trimlen(cprttyp)
      do while (ierr.ne.0)
        write(luscn,9200) cprttyp(1:l)
9200    format(' Printer type set to ',A,'.  Just enter return ',
     .  'if you do not wish to change,'/' else type LASER, EPSON, ',
     .  'or EPSON24 ? ')

        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          idummy = ichmv(itemp,1,ibuf,1,nch)
          call hol2upper(itemp,nch)
          call hol2char(itemp,1,nch,ctemp)
          if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER'
     .      .or.ctemp.eq.'EPSON24') then
            call c2upper(ctemp,cprttyp)
            ierr=0
          else
            write(luscn,9210)
9210        format(' Invalid printer type.  Only LASER, EPSON, '
     .      'or EPSON24 allowed.  Try again.')
          endif
        else
          ierr=0
        endif
      enddo

C  3. Now get printer output orientation.

      ierr=1
      ctemp2 = 'DEFAULT'
      if (iwidth.eq.80) ctemp2='PORTRAIT'
      if (iwidth.eq.137) ctemp2='LANDSCAPE'
      l=trimlen(ctemp2)
      do while (ierr.ne.0)
        write(luscn,9300) ctemp2(1:l)
9300    format(' Output orientation set to ',a,'.  Just enter return ',
     .  'if you do not wish'/' to change else enter (P)ortrait or',
     .  ' (L)andscape or (D)efault ?  ')

        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          idummy = ichmv(itemp,1,ibuf,1,nch)
          call hol2upper(itemp,nch)
          call hol2char(itemp,1,nch,ctemp)
          if (ctemp.eq.'L') then
            iwidth = 137
            ierr=0
          else if (ctemp.eq.'P') then
            iwidth = 80
            ierr=0
          else if (ctemp.eq.'D') then
            iwidth = -1
            ierr=0
          else
            write(luscn,9310)
9310        format(' Invalid output width. Only P, L, or D',
     .      ' allowed.  Try again.')
          endif
        else
          ierr=0
        endif
      enddo

C  4. Now get font size.

      ierr=1
      ctemp2 = 'DEFAULT'
      if (csize.eq.'S') ctemp2='SMALL'
      if (csize.eq.'L') ctemp2='LARGE'
      l=trimlen(ctemp2)
      do while (ierr.ne.0)
        write(luscn,9400) ctemp2(1:l)
9400    format(' Output font size set to ',a,'.  Just enter return ',
     .  'if you do not wish'/' to change else enter (S)mall, ',
     .  '(L)arge or (D)efault ?  ')

        call gtrsp(ibuf,15,luusr,nch)

        if (nch.gt.0) then
          idummy = ichmv(itemp,1,ibuf,1,nch)
          call hol2upper(itemp,nch)
          call hol2char(itemp,1,nch,ctemp)
          if (ctemp(1:1).eq.'D') then
            csize = 'D'
            ierr=0
          else if (ctemp(1:2).eq.'S') then
            csize = 'S'
            ierr=0
          else if (ctemp(1:2).eq.'L') then
            csize = 'L'
            ierr=0
          else
            write(luscn,9410)
9410        format(' Invalid font size. Only S, L, or D',
     .      ' allowed.  Try again.')
          endif
        else
          ierr=0
        endif
      enddo


      RETURN
      END
