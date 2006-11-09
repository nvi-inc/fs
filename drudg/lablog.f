      SUBROUTINE LABLOG(clogfile,carg1,carg2,carg3,ierr)
C  Write tape labels from reading the log file.
!  Based on labsnp
!  2005Jul28 JMGipson
!  2005Aug04 JMGipson.  Modifed make_pslabel to accept 8 character VSN.
!                       Can select on vsn.
! 2006Oct17 JMGipson. Added argument to cclose(fp, clabtyp). Clabyp indicates kind of printer.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
! passed
      character*(*) clogfile
      integer ierr              !<>0 means an error.
      character*(*) carg1,carg2,carg3
      integer nch1,nch2,nch3
      character*8 cvsn_in
! functions
      integer trimlen
      integer copen
      integer cclose
C Local
      character*128 cfilnam
      integer iy1(5),id1(5),ih1(5),im1(5),iy2(5),id2(5),ih2(5),im2(5)
      integer ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2
      integer isec
      integer nout,newlab
      integer iyear,idayr,ihr,imn
      integer nlabpr            !number printed.
      character*128 ctmp
      character*80 cline(0:4)
      integer iline
      integer ind
      integer inew
      integer nch

      integer nlab_per_row
      logical kexist
      logical kfirst_scan
      logical kdone
      character*80 vsn_now,vsn_old

      logical kfound
      integer num_disk

      integer istart
      integer MaxToken
      integer NumToken
      parameter(MaxToken=5)
      character*8 ltoken(MaxToken)

      inquire(file=clogfile,exist=kexist)
      nch=trimlen(clogfile)
      if(.not. kexist) then
         write(*,*) "File not found. ",clogfile(1:nch)
         ierr=-1
         return
      endif

      nch1=trimlen(carg1)
      nch2=trimlen(carg2)
      nch3=trimlen(carg3)

      ilabrow=1
      ilabcol=1

      if(nch1 .eq. 0) then
        cvsn_in="ALL"
      else
        if(nch1 .le. 8) then
          cvsn_in=carg1
        else
          cvsn_in=carg1(1:8)
        endif
        call capitalize(cvsn_in)
        if(nch2 .ne. 0) then
           read(carg2,*,err=910) ilabrow
        endif
        if(nch3 .ne. 0) then
           read(carg3,*,err=910) ilabcol
        endif
      endif
      call capitalize(cvsn_in)
     
! Get a handle to the printer.
      if (cprport.eq.'PRINT') then ! temp file name
          cfilnam = labname
      else ! specified file name
          cfilnam = cprport
      endif
      call null_term(cfilnam)
      kfound=.false.

      klab=.true.   !indicate we are printing labels
! Setup for non Postscript printer.  Taken from label.f
      if(klabel_ps) then
         nlab_per_row=1    !postscript
         ierr = copen(fileptr,cfilnam,len(cfilnam))
         if (ierr.eq.0) then
           write(luscn,'("LABLOG - Can''t open output file ",a)')
     >        cfilnam
           return
         endif
      else
        call setprint(ierr,0)
        IF(IERR.NE.0) THEN
          WRITE(LUSCN,'("Lablog error: ",i5," accessing printer.")')ierr
          RETURN
        ENDIF

        IF(clabtyp.eq.'LASER+BARCODE_CARTRIDGE'.or.
     >     cprttyp.eq.'FILE') THEN
C                            !set up laser printer
            NLAB_per_row=3           !3 labels across on laser paper
C
C <esc>&l2H   manual paper feed
C <esc>&l0O   portrait
C <esc>&l48D  set to 48 lines/inch
C <esc>&l528P 528 lines/page
C <esc>&l2E   set top margin at line 2 (1/24" from top)
C <esc>&l526F 526 lines of text
C <esc>&a0R   start with row 0
C <esc>&a0L   set left margin at left edge of paper
C <esc>&l0L   perf skip disable
C <esc>&l6D   6 lines/inch
C
           WRITE(luprt,'(a)')  CHAR(27)//'&l0O'//CHAR(27)//
     >        '&l48d528p2e526F'//CHAR(27)//'&a0R'//CHAR(27)//'&a0L'//
     >         CHAR(27)//'&l0L'//CHAR(27)//'&l6D'//char(13)

        else if (clabtyp.eq.'EPSON24') then ! Epson 24-pin setup
           write(luprt,'(a,$)')
     >             char(27)//char(64)//char(27)//char(65)//char(12)
!           <esc>@ power up reset  plus <esc> A 12 for 24-pin
            nlab_per_row = 1  !1 across
        else ! Epson setup
           write(luprt,'(a,$)') char(27)//char(65) !<esc>@ power up reset
           nlab_per_row = 1  !1 across
        ENDIF !set up printers
      endif ! laser-epson/ps

      write(*,*) "Opening file for proccessing: ",clogfile(1:nch)
      open(lu_infile,file=clogfile)
      kfirst_scan=.true.

      vsn_old="VSN_OLD"
      vsn_now=""

! Now start parsing log file.
C 1.  Initialize variables
      ierr=0
      nout = 0
      nlabpr = 0
      newlab = 1
      inew=1
      kdone=.false.

! Get some of the initial information.
! This is complicated because this information appears in the log file before
! the line "drudg version"
      iline=0
10    continue
      iline=mod(iline+1,5)
      read(lu_infile,'(a)',end=950,err=950) cline(iline)
      if(index(cline(iline),"drudg") .eq. 0) goto 10

! Parse the line that looks like:
!2005.055.18:04:38.83:" R4162     2005 SVETLOE  S  Sv. This is 4 before "drudg", or 1 after.

      iline=mod(iline+1,5)
      istart=24
!      cline(iline)(1:istart)=" "        !get rid of stuff at front that doesn't matter
      call splitNtokens(cline(iline)(istart:),ltoken,Maxtoken,NumToken)
      cexper=ltoken(1)
      cstnna(1)=ltoken(3)
      cstcod(1)=ltoken(4)

! Read in next line and check to see if Mark5
      read(lu_infile,'(a)') cline(iline)
      write(*,'(a)') cline(iline)(1:80)
      if(index(cline(iline), "Mark5") .eq. 0) then
         write(*,*) "Can only process log files for Mark5 recorders"
         ierr=-2
         return
      endif

      ind=trimlen(cexper)
      WRITE(LUSCN,'("Generating disk labels for ",a,1x,a)')
     >  cexper(1:ind)  ,cstnna(1)
!done with this information.
      call capitalize(cvsn_in)

      num_disk=0
! 1. Loop over log records.
100   continue
      read(lu_infile,'(a)',err=960,end=105,iostat=IERR) ctmp
      if(ierr .ne. 0) then
        write(*,*) "Lablog: io_error ", ierr
        return
      endif

      call capitalize(ctmp)

      if(index(ctmp,"DATA_VALID=ON") .ne. 0) then
        if(kfirst_scan) then
          nout=1
          kfirst_scan=.false.
          nlabpr=nlabpr+1
          read(ctmp,'(i4,1x,i3,1x,i2,1x,i2,1x,i2)')
     >      iy1(nout),id1(nout),ih1(nout),im1(nout),isec
            iy1(nout)=mod(iy1(nout),100)
        endif
      else if(index(ctmp,"DATA_VALID=OFF") .ne. 0) then
          read(ctmp,'(i4,1x,i3,1x,i2,1x,i2,1x,i2)')
     >      iy2(nout),id2(nout),ih2(nout),im2(nout),isec
            iy2(nout)=mod(iy2(nout),100)
            if(isec .gt. 30) then
              im2(nout)=im2(nout)+1
              if(im2(nout) .eq. 60) then
                im2(nout)=0
                ih2(nout)=ih2(nout)+1
                if(ih2(nout) .eq. 24) then
                   ih2(nout)=0
                   id2(nout)=id2(nout)+1
                endif
              endif
            endif
      else if(index(ctmp,"/BANK_CHECK/") .ne. 0) then
!        read(ctmp,'(i4,1x,i3,1x,i2,1x,i2)') iyear,idayr,ihr,imn
        ind=index(ctmp,",")
        vsn_now=ctmp(33:ind-1)
        call capitalize(vsn_now)
        if(vsn_old .ne. "VSN_OLD") goto 110
        vsn_old=vsn_now
      endif
      goto 100

!-----Here is where we print a label---------------------
105   continue            !come here on EOF
      vsn_now="DONE"      !this makes sure that we print one last label
      kdone=.true.

110   continue
      if(vsn_now .ne. vsn_old .and.
     >   (cvsn_in .eq. "ALL" .or. cvsn_in .eq. vsn_old(1:8))) then

        kfirst_scan=.true.
        kfound=.true.
        num_disk=num_disk+1

        if (nout.ge.nlab_per_row .or. kdone) then !print a row
           write(luscn, '(i2,1x,a,1x,2(2x,i3,"-",i2.2,":",i2.2))')
     >         num_disk, vsn_old(1:8),
     >         id1(1),ih1(1),im1(1), id2(1),ih2(1),im2(1)
          if (.not.klabel_ps) then
            call blabl(luprt,nout,lexper,lstnna(1,1),lstcod(1),
     .      iy1,id1,ih1,im1,iy2,id2,ih2,im2,ilabrow,
     .      cprttyp,clabtyp,cprport)
            nout = 0
            ilabrow = ilabrow + 1
            if (ilabrow.gt.8) ilabrow=ilabrow-8
          else ! postscript
            ipsy1=mod(iy1(1),100)
            ipsd1=id1(1)
            ipsh1=ih1(1)
            ipsm1=im1(1)
            ipsy2=mod(iy2(1),100)
            ipsd2=id2(1)
            ipsh2=ih2(1)
            ipsm2=im2(1)
            if(clabtyp .eq. "DYMO") then
               ilabcol=1
               ilabrow=1
            endif

            nout=0
            call make_pslabel(fileptr,cstnna(1),cstcod(1),
     >         cexper,clabtyp,vsn_old(1:8),
     .      ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,
     .      inew,rlabsize,ilabrow,ilabcol,inewpage)
            ilabcol=ilabcol+1
            if (ilabcol.gt.rlabsize(4)) then
              ilabcol=1
              ilabrow=ilabrow+1
              if (ilabrow.gt.rlabsize(3)) then
                ilabrow=1
                inewpage=1
              endif
            endif
            kfirst_scan=.true.
          endif ! laser/Epson/ps
        endif
        newlab = 1
      endif
      if(kdone) goto 900

      vsn_old=vsn_now
      goto 100

!---------------Done label-------------------------

!  Cleanup
900   continue
      close(lu_infile)
      if(kfound) then
        if(klabel_ps) then
          ierr=cclose(fileptr,clabtyp)  !close file, add showpage if necessary.
          klab=.true.
        else
         if(clabtyp.eq.'LASER+BARCODE_CARTRIDGE'.or.
     >         cprttyp.eq.'FILE') then
          write(luprt,'(a)') char(12) ! FORM FEED
          close(luprt)
          endif
        endif
!        call prtmp(0)
        inew=1 ! reset flag for new file
        klab = .false.
      else
         write(luscn,'("Lablog: Did not find VSN: ", a)') cvsn_in
         ierr=-1
      endif

      return

910   continue
      writE(luscn,'("Lablog: Error reading row or column")')
      ierr=1
      return


950   continue
      write(luscn,'("Lablog: Did not find DRUDG stamp")')
      ierr=1
      close(lu_infile)
      return

960   continue
      write(luscn,'("Lablog: Error reading file.")')
      ierr=2
      close(lu_infile)
      return

      end
