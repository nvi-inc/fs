      SUBROUTINE rdctl(source_cat,antenna_cat,position_cat,equip_cat,
     .                 mask_cat,freq_cat,rx_cat,loif_cat,modes_cat,
     .                 rec_cat,hdpos_cat,
     .                 tracks_cat,flux_cat,flux_comments,
     .                 csked,csnap,cproc,
     .                 ctmpnam,cprtlan,cprtpor,cprttyp,cprport,
     .                 cprtlab,clabtyp,rlabsize,cepoch,coption,luscn)
C
C  This routine will open the default control file for 
C  directories and devices to use with SKED. Then it will
C  open a user's local control file. Any information in 
C  this file will overwrite same-named information found
C  in system control file.
C
C   HISTORY:
C     gag   900212 created
C     NRV   901018 Added "printer" line in $PRINT section
C     nrv   950329 Added flux_comments
C     nrv   950925 Add full code for printer line in $PRINT
c 951124 nrv Change calling sequence for new catalog names
C 960226 nrv Add "cprtlab" for script to print labels
C 960403 nrv Add "rec_cat" to call
C 970207 nrv Add cepoch to call. Add to $MISC section.
C            Allow null script names.
C 970228 nrv Add "label_printer" key word and "clabtyp" to call. 
C 970228 nrv Add "label_size" key word and "rlabsize" to call.
C 970304 nrv Add "cproc" to call, change "cdrudg" to "csnap".
C 970304 nrv Add "option1", "option4", "option5" key words and options,
C                and add "coption" to call.
C
C   parameter file
      include '../skdrincl/skparm.ftni'
C
      character*128  source_cat,antenna_cat,position_cat,equip_cat,
     .               mask_cat,freq_cat,rx_cat,loif_cat,modes_cat,
     .               hdpos_cat,tracks_cat,flux_cat,flux_comments,
     .               rec_cat,csked,csnap,cproc,ctmpnam,cprtlab,
     .               cprtlan,cprtpor,cprttyp,cprport,clabtyp
      character*4 cepoch
      real rlabsize(6)
      character*2 coption(3)
      integer luscn
C
C  LOCAL VARIABLES
      integer itmplen     !variable for filename length
      integer ias2b,trimlen,ichcm_ch,jchar     !function call 
      logical*4 kex         !control file existence
      character*128 ctemp   !temporary control file variable
      character*128 ctmp2   !temporary control file variable
      integer*2 isecname(5) !$section name
      integer*2 ltmpnam(10)  !variable identifier
      integer lu          !open lu
      integer ic,ifield,j,ilen,ierr,ich,ic1,ic2,nch,idum,ichmv
      real ras2b,val
      integer*2 ibuf(ibuf_len)
C
C
C  1. Open the default control file if it exists.

      kex = .false.
      ilen = 0
      ierr = 0
      lu = 11
      ctmp2 = cctfil
      itmplen = trimlen(ctmp2)

      inquire(file=cctfil,exist=kex)
      if (kex) then
        open(lu,file=cctfil,iostat=ierr,status='old')
        if (ierr.ne.0) then
          write(luscn,9100) ctmp2(1:itmplen)
9100      format("RDCTL01 ERROR: Error opening control file ",A)
          close(lu)
          return
        end if
        write(luscn,9105) ctmp2(1:itmplen)
9105    format("RDCTL02 - Reading system control file ",A)
      else
        write(luscn,9110) ctmp2(1:itmplen)
9110    format("RDCTL03 ERROR: Can't find system control file ",A)
      end if

C  2. Process the control file if it exists. This loops through twice, 
C     once for each control file.

      j = 1
      do while (j.le.2)
        if (kex) then
          call ifill(ibuf,1,ibuf_len*2,oblank)
          call reads(lu,ierr,ibuf,ibuf_len,ilen,1) !read first $
          do while (ilen.ne.-1)
            ich = 1
            call gtfld(ibuf,ich,ilen,ic1,ic2)
            nch = ic2-ic1+1
            call ifill(isecname,1,10,oblank)
            idum= ichmv(isecname,1,ibuf,ic1,nch)
            call hol2upper(isecname,nch)
            call ifill(ibuf,1,ibuf_len*2,oblank)
            call reads(lu,ierr,ibuf,ibuf_len,ilen,2)
      
C  $CATALOGS
            if (ichcm_ch(isecname,1,'$CATALOGS').eq.0) then 
              do while((ilen.ne.-1).and.(jchar(ibuf,1).ne.o'44')) 
                ich = 1
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                nch = ic2-ic1+1
                call ifill(ltmpnam,1,20,oblank)
                idum= ichmv(ltmpnam,1,ibuf,ic1,nch)
                call hol2upper(ltmpnam,nch)
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                if (ichcm_ch(ltmpnam,1,'SOURCE').eq.0) then
                  call hol2char(ibuf,ic1,ic2,source_cat) 
                else if (ichcm_ch(ltmpnam,1,'ANTENNA').eq.0) then
                  call hol2char(ibuf,ic1,ic2,antenna_cat) 
                else if (ichcm_ch(ltmpnam,1,'POSITION').eq.0) then
                  call hol2char(ibuf,ic1,ic2,position_cat) 
                else if (ichcm_ch(ltmpnam,1,'EQUIP').eq.0) then
                  call hol2char(ibuf,ic1,ic2,equip_cat) 
                else if (ichcm_ch(ltmpnam,1,'MASK').eq.0) then
                  call hol2char(ibuf,ic1,ic2,mask_cat) 
                else if (ichcm_ch(ltmpnam,1,'FREQ').eq.0) then
                  call hol2char(ibuf,ic1,ic2,freq_cat) 
                else if (ichcm_ch(ltmpnam,1,'RX').eq.0) then
                  call hol2char(ibuf,ic1,ic2,rx_cat) 
                else if (ichcm_ch(ltmpnam,1,'LOIF').eq.0) then
                  call hol2char(ibuf,ic1,ic2,loif_cat) 
                else if (ichcm_ch(ltmpnam,1,'MODES').eq.0) then
                  call hol2char(ibuf,ic1,ic2,modes_cat) 
                else if (ichcm_ch(ltmpnam,1,'REC').eq.0) then
                  call hol2char(ibuf,ic1,ic2,rec_cat) 
                else if (ichcm_ch(ltmpnam,1,'HDPOS').eq.0) then
                  call hol2char(ibuf,ic1,ic2,hdpos_cat) 
                else if (ichcm_ch(ltmpnam,1,'TRACKS').eq.0) then
                  call hol2char(ibuf,ic1,ic2,tracks_cat) 
                else if (ichcm_ch(ltmpnam,1,'FLUX').eq.0) then
                  call hol2char(ibuf,ic1,ic2,flux_cat) 
                else if (ichcm_ch(ltmpnam,1,'COMMENTS').eq.0) 
     .            then
                  call hol2char(ibuf,ic1,ic2,flux_comments) 
                else
                  write(luscn,9200) ltmpnam
9200              format("RDCTL04 ERROR: Unrecognizable catalog name ",
     .            5A2)
                end if

                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,2)
              end do

C  $SCHEDULES
            else if (ichcm_ch(isecname,1,'$SCHEDULES').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                ctemp = ' '
                call hol2char(ibuf,ic1,ic2,ctemp)
                csked = ctemp
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              end if

C  $SNAP 
            else if (ichcm_ch(isecname,1,'$SNAP').eq.0.or.
     .               ichcm_ch(isecname,1,'$DRUDG').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                ctemp = ' '
                call hol2char(ibuf,ic1,ic2,ctemp)
                csnap = ctemp
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              end if

C  $PROC 
            else if (ichcm_ch(isecname,1,'$PROC').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                ctemp = ' '
                call hol2char(ibuf,ic1,ic2,ctemp)
                cproc = ctemp
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              end if

C  $SCRATCH
            else if (ichcm_ch(isecname,1,'$SCRATCH').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                ctmpnam = ' '
                call hol2char(ibuf,ic1,ic2,ctmpnam)
              end if
              call ifill(ibuf,1,ibuf_len*2,oblank)
              call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
        
C  $PRINT
            else if (ichcm_ch(isecname,1,'$PRINT').eq.0) then
              do while((ilen.ne.-1).and.(jchar(ibuf,1).ne.o'44'))
                ich = 1
C               Get the keyword field
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                nch = ic2-ic1+1
                call ifill(ltmpnam,1,10,oblank)
                idum= ichmv(ltmpnam,1,ibuf,ic1,nch)
                call hol2upper(ltmpnam,nch)
C               Get the value field
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                if (ichcm_ch(ltmpnam,1,'LABELS').eq.0) then
                  if (ic1.gt.0) then
                    call hol2char(ibuf,ic1,ilen,cprtlab)
                    call null_term(cprtlab)
                  else ! null
                    cprtlab=' '
                  endif
                else if (ichcm_ch(ltmpnam,1,'PORTRAIT').eq.0) then
                  if (ic1.gt.0) then
                    call hol2char(ibuf,ic1,ilen,cprtpor)
                    call null_term(cprtpor)
                  else
                    cprtpor=' '
                  endif
                else if (ichcm_ch(ltmpnam,1,'LANDSCAPE').eq.0) then
                  if (ic1.gt.0) then
                    call hol2char(ibuf,ic1,ilen,cprtlan)
                    call null_term(cprtlan)
                  else
                    cprtlan=' '
                  endif
                else if (ichcm_ch(ltmpnam,1,'PRINTER').eq.0) then ! printer line
                  nch=ic2-ic1+1
                  if (nch.gt.0) then
                    idum = ichmv(ltmpnam,1,ibuf,ic1,nch) ! type
                    call hol2upper(ltmpnam,nch)
                    call hol2char(ltmpnam,1,nch,ctemp)
                    if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER'.or.
     .               ctemp.eq.'EPSON24') then
                      cprttyp=ctemp
                    else
                      write(luscn,9211) ctemp
9211                  format('RDCTL05 ERROR: Unrecognized printer type ',
     .                A)
                    endif
                  endif
                else if (ichcm_ch(ltmpnam,1,'LABEL_PRINTER').eq.0) then 
                  nch=ic2-ic1+1
                  if (nch.gt.0) then
                    idum = ichmv(ltmpnam,1,ibuf,ic1,nch) ! type
                    call hol2upper(ltmpnam,nch)
                    call hol2char(ltmpnam,1,nch,ctemp)
                    if (ctemp.eq.'EPSON'.or.ctemp.eq.'POSTSCRIPT'.or.
     .               ctemp.eq.'LASER+BARCODE_CARTRIDGE'.or. 
     .               ctemp.eq.'EPSON24') then
                      clabtyp=ctemp
                    else
                      write(luscn,9212) ctemp
9212                  format('RDCTL10 ERROR: Unrecognized label ',
     .                'printer type ',A)
                    endif
                  endif
                else if (ichcm_ch(ltmpnam,1,'OPTION').eq.0) then 
                  ic = ias2b(ltmpnam,7,1)
                  if (ic.ne.1.and.ic.ne.4.and.ic.ne.5) then
                    write(luscn,9216) ic
9216                format('RDCTL14 ERROR: Invalid option number, ',
     .              i3,' must be 1, 4, or 5.')
                  else
                    nch=ic2-ic1+1
                    if (nch.gt.0) then
                      idum = ichmv(ltmpnam,1,ibuf,ic1,nch) ! option
                      call hol2upper(ltmpnam,nch)
                      call hol2char(ltmpnam,1,nch,ctemp)
                      if (ctemp.eq.'PS'.or.ctemp.eq.'PL'.or.
     .                    ctemp.eq.'LS'.or.ctemp.eq.'LL') then
                        if (ic.eq.1) coption(1)=ctemp
                        if (ic.eq.4) coption(2)=ctemp
                        if (ic.eq.5) coption(3)=ctemp
                      else
                        write(luscn,9215) ctemp
9215                    format('RDCTL13 ERROR: Unrecognized option ',
     .                  'type ',A,', only PS, PL, LS, or LL are valid.')
                      endif
                    endif
                  endif
                else if (ichcm_ch(ltmpnam,1,'LABEL_SIZE').eq.0) then 
C                 label_size ht wid nrows ncols topoff leftoff
                  do ifield=1,6
                    nch=ic2-ic1+1 ! first field already gotten
                    if (nch.gt.0) then
                      val=ras2b(ibuf,ic1,nch,ierr)
                      if (ierr.eq.0) then
                        rlabsize(ifield)=val
                      else
                        write(luscn,9213) ifield+1,(ibuf(j),j=1,ilen/2)
9213                    format('RDCTL11 ERROR: Invalid number in field',
     .                  i5,' of this line:'/40a2) 
                      endif
                      call gtfld(ibuf,ich,ilen,ic1,ic2)
                    else
                      write(luscn,9214) ifield
9214                  format('RDCTL12 ERROR: Field ',i3,' missing on ',
     .                ' the label size line. ')
                    endif
                  enddo
                end if !printer line

                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,2)
              end do

C  $MISC
            else if (ichcm_ch(isecname,1,'$MISC').eq.0) then
              do while((ilen.ne.-1).and.(jchar(ibuf,1).ne.o'44'))
                ich = 1
C               Get keyword field
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                nch = ic2-ic1+1
                call ifill(ltmpnam,1,10,oblank)
C               Move keyword from ibuf to ltmpnam, make it upper case
                idum= ichmv(ltmpnam,1,ibuf,ic1,nch)
                call hol2upper(ltmpnam,nch)
C               Get value field
                call gtfld(ibuf,ich,ilen,ic1,ic2)
                if (ichcm_ch(ltmpnam,1,'EPOCH').eq.0) then
                  nch=ic2-ic1+1
                  call hol2char(ibuf,ic1,ilen,ctemp)
                  if (ctemp(1:4).eq.'1950') then
                    cepoch='1950'
                  else if (ctemp(1:4).eq.'2000') then
                    cepoch='2000'
                  else
                    write(luscn,'("RDCTL06 ERROR: Invalid epoch ",a)')
     .              ctemp(1:trimlen(ctemp))
                  endif
                endif
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              enddo

            else ! unrecognized
              write(luscn,9220) isecname
9220          format("RDCTL07 ERROR: Unrecognized section name ",5A2)
              call ifill(ibuf,1,ibuf_len*2,oblank)
              call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
            end if
          end do

          close (lu)
        end if  !"control file exists"

        if (j.lt.2) then
          inquire(file=cownctl,exist=kex)
          if (kex) then
            ctmp2 = cownctl
            open(lu,file=cownctl,iostat=ierr,status='old')
            if (ierr.ne.0) then
              write(luscn,9230) ctmp2(1:trimlen(ctmp2))
9230          format("RDCTL08 ERROR: Error opening local control file ",
     .        a)
              close(lu)
              return
            end if
            itmplen = trimlen(ctmp2)
            write(luscn,9240) ctmp2(1:itmplen)
9240        format("RDCTL09 - Reading personal control file ",A)
          else
            j = 2
          end if

        end if  !"j<2"
        j = j + 1

      end do  !"do 1,2"

C
      close(lu)

      RETURN
      END
