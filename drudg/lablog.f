      SUBROUTINE LABLOG(clogfile,cvsn_use,clab_row,clab_col,cfile,ierr)
C  Write tape labels from reading the log file.
!  Arguments are:
!
!  Based on labsnp
!  2005Jul28 JMGipson
!  2005Aug04 JMGipson.  Modifed make_pslabel to accept 8 character VSN.
!                       Can select on vsn.
! 2006Oct17 JMGipson. Added argument to cclose(fp, clabtyp). Clabyp indicates kind of printer.
! 2006Nov13 JMGipson. Made immune to ^M
! 2007Jan20 JMG. Also accept Mk5APigW as a valid recorder type.
! 2007Feb01 JMG. Just issue a message on recorder type, don't stop if not Mark5A or Mk5APigW
!                Modified to get info from sched_info line
! 2007Feb02 JMG. Take an optional file name to save the PS file in.
! 2008Dec03 JMG. Was getting rid of too much space at start of line


      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
! passed
      character*(*) clogfile
      integer ierr                      !<>0 means an error.
      character*(*) cvsn_use            !which vsn to use.
      character*(*) clab_row,clab_col   !ASCII row and column to print.
      character*(*) cfile               !file to save the results in. If this is set, we don't print.
      integer nch1
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
      integer nlabpr            !number printed.
      character*256 ctmp
      character*80 cline(0:4)
      integer iline
      integer icount
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

      nch1=trimlen(cvsn_use)

      ilabrow=1
      ilabcol=1



      if(nch1 .eq. 0) then
        cvsn_in="ALL"
      else
        call capitalize(cvsn_use)
        if(cvsn_use .eq. "?" .or. cvsn_use .eq. "HELP") goto 950

        cvsn_in=cvsn_use(1:min(8,nch1))

        if(trimlen(clab_row) .ne. 0) then
           read(clab_row,*,err=910) ilabrow
        endif
        if(trimlen(clab_col) .ne. 0) then
           read(clab_col,*,err=910) ilabcol
        endif
      endif

! Get a handle to the printer.
      if(trimlen(cfile) .ne. 0) then
         cfilnam=cfile                  !specified as an argument.
         write(luscn,'(a)')
     >     "Will save output to file:   "//cfilnam(1:trimlen(cfilnam))
      else if (cprport.eq.'PRINT') then ! temp file name
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

      vsn_old="VSN_????"
      vsn_now="VSN_NEW"

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
      icount=0
      cexper="SESSION?"
      cstnna(1)="STATION?"
      cstcod(1)="X"       !would like to use "?" but bar-code doesn't know how to handle.
10    continue
      iline=mod(iline+1,5)
      icount=icount+1
      read(lu_infile,'(a80)',end=29,err=29) cline(iline)

! Two possibilities for getting the necessary information.
! First.
      ind=index(cline(iline),"sched_info")
      if(ind .ne. 0) then
! second one has the information.
         read(lu_infile,'(a80)',end=29,err=29) cline(iline)
         call splitNtokens(cline(iline)(ind+10:),ltoken,Maxtoken,
     > NumToken)
         cexper=ltoken(1)
         cstnna(1)=ltoken(2)
         cstcod(1)=ltoken(3)(1:1)
         goto 30
! Second
      else if(cline(iline)(24:36) .eq. "drudg version") then 
! Parse the line that looks like:
!2005.055.18:04:38.83:" R4162     2005 SVETLOE  S  Sv. This is 4 before "drudg", or 1 after.
        ind=trimlen(cline(iline))
        if(cline(iline)(ind:ind) .eq. char(13)) then
          write(*,*) "Getting rid of ^M"
          cline(iline)(ind:ind)=" "
        endif

        iline=mod(iline+1,5)
        istart=23
        cline(iline)(1:istart)=" "        !get rid of stuff at front that doesn't matter
        call splitNtokens(cline(iline),ltoken,Maxtoken,NumToken)
        cexper=ltoken(1)
        cstnna(1)=ltoken(3)
        cstcod(1)=ltoken(4)

! Read in next line and check to see if Mark5
        read(lu_infile,'(a)') cline(iline)
        ind=trimlen(cline(iline))
        if(cline(iline)(ind:ind) .eq. char(13)) then
          cline(iline)(ind:ind)=" "
        endif
        write(*,'(a)') cline(iline)
        if(index(cline(iline), "Mark5") .eq. 0 .and.
     >     index(cline(iline), "Mk5APigW") .eq. 0) then
           write(*,*) "Can only process log files for Mark5 recorders"
           write(*,*) "Mushing on ahead, may produce strange results!"
        endif
        goto 30
      else
        goto 10
      endif
    
! Come here if we don't get the station information.
29    continue
      rewind(lu_infile)
      write(*,*) "Did not find station and session information."      
      write(*,*) "Using default values."

30    continue
      rewind(lu_infile)
      ind=trimlen(cexper)
      WRITE(LUSCN,'("Generating disk labels for ",a,1x,a)')
     >  cexper(1:ind)  ,cstnna(1)
!done with this information.
      call capitalize(cvsn_in)

      num_disk=0
! 1. Loop over log records.
100   continue
      read(lu_infile,'(a)',err=930,end=105,iostat=IERR) ctmp
      ind=trimlen(ctmp)
      if(ind .ne. 0) then
        if(ctmp(ind:ind) .eq. char(13)) ctmp(ind:ind)=" "
      endif
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
            call blabl(luprt,nout,cexper,cstnna,cstcod,
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
        if(trimlen(cfile) .eq. 0) then
           call prtmp(0)                      !no filename specified as input. Print it out.
        endif
        inew=1 ! reset flag for new file
        klab = .false.
      else
         write(luscn,'("Lablog: Did not find VSN: ", a)') cvsn_in
         ierr=-1
         goto 950
      endif

      return

910   continue
      writE(luscn,'("Lablog: Error reading row or column")')
      ierr=1
      goto 950


920   continue
      write(luscn,'("Lablog: Did not find DRUDG stamp")')
      ierr=1
      close(lu_infile)
      goto 950

930   continue
      write(luscn,'("Lablog: Error reading file.")')
      ierr=2
      close(lu_infile)
      goto 950


950   continue
      write(luscn,'(a)') " "
      write(luscn,'(a)')
     > "Possible argument error.  Correct way to print labels is: "
      write(luscn,'(a)')
     > "  drudg file.log [VSN [irow_beg [icol_beg [fileout]]]] "
      write(luscn,'(a)') "Some examples: "
      write(luscn,'(a)') "  drudg r128ho.log"
      write(luscn,'(a)') "  drudg r128ho.log ALL"
      write(luscn,'(a)') "  drudg r128ho.log ALL 1 1"
      write(luscn,'(a)') "  drudg r128ho.log ALL 1 1 temp.ps"
      return
      end
