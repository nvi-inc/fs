      SUBROUTINE LABLOG(cfilnam,ierr)
C  Write tape labels from reading the log file.
!  Based on labsnp
!  2005Jul28 JMGipson

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
! passed
      character*128 cfilnam
      integer ierr              !<>0 means an error.
! functions
      integer trimlen
      integer copen
      integer cclose
C Local
      integer iy1(5),id1(5),ih1(5),im1(5),iy2(5),id2(5),ih2(5),im2(5)
      integer ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,ntape
      integer nout,newlab
      integer iyear,idayr,ihr,imn
      integer nlabpr            !number printed.
      character*128 ctmp
      character*80 cline(0:4)
      integer iline
      integer ind
      integer inew

      integer nlab_per_row
      logical kexist
      logical kbeg_label
      logical kdone
      character*80 vsn_now,vsn_old

      integer istart
      integer MaxToken
      integer NumToken
      parameter(MaxToken=5)
      character*8 ltoken(MaxToken)

! Get the log file.
!      cfilnam=cexper(1:trimlen(cexper))//cpocod(istn)//".log"
!      call lowercase(cfilnam)
!      write(*,*) "Default log file: ",cfilnam(1:trimlen(cfilnam))

!      write(*,*) "Enter in new log file, or return to accept default."
!      write(*,*) "Enter in log file: "
!      read(*,*) cfilnam
!      ctmp=" "
!      if(ctmp .ne. " ") then
!         cfilnam=ctmp
!        ind=index(cfilnam,".log")
!        if(ind .eq. 0) then
!           cfilnam=cfilnam(1:trimlen(cfilnam))//".log"
!        endif
!      endif

      inquire(file=cfilnam,exist=kexist)
      if(.not. kexist) then
         write(*,*) "File not found. ",cfilnam(1:trimlen(cfilnam))
         ierr=-1
         return
      endif

      write(*,*) "Opeing file for proccessing: ",cfilnam(1:20)
      open(lu_infile,file=cfilnam)
      kbeg_label=.true.

      vsn_old=""
      vsn_now=""


! Get a handle to the printer.
      if (cprport.eq.'PRINT') then ! temp file name
          cfilnam = labname
      else ! specified file name
          cfilnam = cprport
      endif
      call null_term(cfilnam)
      ierr = copen(fileptr,cfilnam,len(cfilnam))
      if (ierr.eq.0) then
        write(luscn,'("LABLOG - Can''t open output file ",a)') cfilnam
        return
      endif

! Now start parsing log file.
C 1.  Initialize variables
      ierr=0
      nout = 0
      ntape = 0
      nlabpr = 0
      newlab = 1
      ilabcol=1
      ilabrow=1
      inew=1
      kdone=.false.

      if (clabtyp.eq.'POSTSCRIPT' .or. clabtyp .eq. 'DYMO') then ! laser or Epso
        nlab_per_row=1
      else
        nlab_per_row=3
      endif

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

      ind=trimlen(cexper)
      WRITE(LUSCN,'("Generating disk labels for ",a,1x,a)')
     >  cexper(1:ind)  ,cstnna(1)
!done with this information.

! 1. Loop over log records.
100   continue
      read(lu_infile,'(a)',err=960,end=105,iostat=IERR) ctmp
      if(ierr .ne. 0) then
        write(*,*) "Lablog: io_error ", ierr
        return
      endif

      call capitalize(ctmp)
      if(index(ctmp,"/BANK_CHECK/") .ne. 0) then
        ind=index(ctmp,",")
        vsn_now=ctmp(33:ind-1)
        if(vsn_old .eq. " ") vsn_old=vsn_now
      endif
      goto 110

105   continue            !come here on EOF
      vsn_now="DONE"      !this makes sure that we print one last label
      kdone=.true.

110   continue
      if(vsn_now .ne. vsn_old) then          !if a change in vsn_numbers, then print label.
        kbeg_label=.true.                    !begin a new label after this.
        if (nout.ge.nlab_per_row .or. kdone) then !print a row
          if (clabtyp.ne.'POSTSCRIPT' .and. clabtyp .ne. 'DYMO') then ! laser or Epson
            call blabl(luprt,nout,lexper,lstnna(1,1),lstcod(1),
     .      iy1,id1,ih1,im1,iy2,id2,ih2,im2,ilabrow,
     .      cprttyp,clabtyp,cprport)
            nout = 0
            ilabrow = ilabrow + 1
            if (ilabrow.gt.8) ilabrow=ilabrow-8
          else ! postscript
            ntape=ntape+1
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

            write(luscn,
     >           '(i2,3x,2(2x,i3,":",i2.2,":",i2.2))')
     >           nlabpr, ipsd1,ipsh1,ipsm1, ipsd2,ipsh2,ipsm2

            call make_pslabel(fileptr,cstnna(1),cstcod(1),
     >         cexper,clabtyp,
     .      ipsy1,ipsd1,ipsh1,ipsm1,ipsy2,ipsd2,ipsh2,ipsm2,ntape,
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
            NOUT = 0
          endif ! laser/Epson/ps
        endif
        newlab = 1
        if(kdone) goto 900
        goto 100
      endif

      if(index(ctmp,"SCAN_NAME=") .ne. 0) then
        read(ctmp,'(i4,1x,i3,1x,i2,1x,i2)') iyear,idayr,ihr,imn

        if(kbeg_label) then
          nout=nout+1
          iy1(nout) = iyear
          id1(nout) = idayr
          ih1(nout) = ihr
          im1(nout) = imn
          kbeg_label=.false.
          nlabpr=nlabpr+1
        else
          iy2(nout) = iyear
          id2(nout) = idayr
          ih2(nout) = ihr
          im2(nout) = imn
        endif
      endif
      goto 100

!  Cleanup
900   continue
      if (clabtyp.eq.'POSTSCRIPT' .or. clabtyp .eq. 'DYMO') then
        ierr=cclose(fileptr)
        klab=.true.
        call prtmp(0)
        inew=1 ! reset flag for new file
        klab = .false.
      endif

      close(lu_infile)
      return

950   continue
      write(luscn,'("Lablog: Did not find DRUDG stamp")')
      ierr=1
      return

960   continue
      write(luscn,'("Lablog: Error reading file.")')
      ierr=2
      return

      end
