      subroutine redsk(ibufsk,iskbw)
C
C  REDSK - This routine reads the schedule file until the $SKED section
C          is encountered.
C
C  COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C  MODIFICATIONS:
C
C     DATE     WHO  DESCRIPTION
C     820513   KNM  SUBROUTINE CREATED
C
C  INPUT VARIABLES:
C
      integer*2 ibufsk(80)
C        - Buffer for schedule file.
      integer fmpread
C
C     ISKBW - Number of words in IBUFSK
C
C  OUTPUT VARIABLES:
C
C     ICODE - Error flag.
C
C  SUBROUTINE INTERFACES:
C
C     CALLED SUBROUTINES:
C
C       LXSUM - SUMMARY command.
C
C  **********************************************************
C
C  Read the schedule file until the $SKED section is reached.
C  If the $SKED section is not found before the end of file,
C  write a message.
C
C  **********************************************************
C
C
100   call ifill_ch(ibufsk,1,160,' ')
      id = fmpread(idcbsk,ierr,ibufsk,iskbw*2)
      ilensk = iflch(ibufsk,iskbw*2)
C
      if (ierr.lt.0) then
        write(luusr,9000) ierr,lskna
9000    format("REDSK10 - error "i3" reading sked file "4a2)
        icode=-1
        goto 300
      end if
C
      if (ichcm(ibufsk,1,5h$sked,1,5).eq.0) goto 300
      if (ilensk.ge.0) goto 100
        call po_put_c('eof was encountered before $sked section')
        icode=-1
C
300   continue
      return
      end
