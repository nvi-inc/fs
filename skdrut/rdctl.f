      SUBROUTINE rdctl(source_cat,antenna_cat,position_cat,equip_cat,
     .                 mask_cat,freq_cat,rx_cat,loif_cat,modes_cat,
     .                 hdpos_cat,
     .                 tracks_cat,flux_cat,flux_comments,
     .                 csked,cdrudg,
     .                 ctmpnam,cprtlan,cprtpor,cprttyp,cprport,luscn)
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
C
C   parameter file
      INCLUDE 'skparm.ftni'
C
C  INPUT:
      character*128  source_cat,antenna_cat,position_cat,equip_cat,
     .               mask_cat,freq_cat,rx_cat,loif_cat,modes_cat,
     .               hdpos_cat,tracks_cat,flux_cat,flux_comments,
     .               csked,cdrudg,ctmpnam,
     .               cprtlan,cprtpor,cprttyp,cprport
      integer luscn
C
C  LOCAL VARIABLES
      integer itmplen     !variable for filename length
      integer trimlen,ichcm_ch,jchar     !function call 
      logical*4 kex         !control file existence
      character*128 ctemp   !temporary control file variable
      character*128 ctmp2   !temporary control file variable
      integer*2 isecname(5) !$section name
      integer*2 itmpnam(10)  !variable identifier
      integer lu          !open lu
      integer j,ilen,ierr,ich,ic1,ic2,nch,idum,ichmv
      integer*2 ibuf(ibuf_len)
      integer ii
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
9100      format("Error opening control file ",A)
          close(lu)
          return
        end if
        write(luscn,9105) ctmp2(1:itmplen)
9105    format("Reading system control file ",A)
      else
        write(luscn,9110) ctmp2(1:itmplen)
9110    format("Can't find system control file ",A)
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
            call gtfld(ibuf,ich,ilen*2,ic1,ic2)
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
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                nch = ic2-ic1+1
                call ifill(itmpnam,1,20,oblank)
                idum= ichmv(itmpnam,1,ibuf,ic1,nch)
                call hol2upper(itmpnam,nch)
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                if (ichcm_ch(itmpnam,1,'SOURCE').eq.0) then
                  call hol2char(ibuf,ic1,ic2,source_cat) 
                else if (ichcm_ch(itmpnam,1,'ANTENNA').eq.0) then
                  call hol2char(ibuf,ic1,ic2,antenna_cat) 
                else if (ichcm_ch(itmpnam,1,'POSITION').eq.0) then
                  call hol2char(ibuf,ic1,ic2,position_cat) 
                else if (ichcm_ch(itmpnam,1,'EQUIP').eq.0) then
                  call hol2char(ibuf,ic1,ic2,equip_cat) 
                else if (ichcm_ch(itmpnam,1,'MASK').eq.0) then
                  call hol2char(ibuf,ic1,ic2,mask_cat) 
                else if (ichcm_ch(itmpnam,1,'FREQ').eq.0) then
                  call hol2char(ibuf,ic1,ic2,freq_cat) 
                else if (ichcm_ch(itmpnam,1,'RX').eq.0) then
                  call hol2char(ibuf,ic1,ic2,rx_cat) 
                else if (ichcm_ch(itmpnam,1,'LOIF').eq.0) then
                  call hol2char(ibuf,ic1,ic2,loif_cat) 
                else if (ichcm_ch(itmpnam,1,'MODES').eq.0) then
                  call hol2char(ibuf,ic1,ic2,modes_cat) 
                else if (ichcm_ch(itmpnam,1,'HDPOS').eq.0) then
                  call hol2char(ibuf,ic1,ic2,hdpos_cat) 
                else if (ichcm_ch(itmpnam,1,'TRACKS').eq.0) then
                  call hol2char(ibuf,ic1,ic2,tracks_cat) 
                else if (ichcm_ch(itmpnam,1,'FLUX').eq.0) then
                  call hol2char(ibuf,ic1,ic2,flux_cat) 
                else if (ichcm_ch(itmpnam,1,'COMMENTS').eq.0) 
     .            then
                  call hol2char(ibuf,ic1,ic2,flux_comments) 
                else
                  write(luscn,9200) itmpnam
9200              format("Unrecognizable catalog name ",5A2)
                end if

                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,2)
              end do

C  $SCHEDULES
            else if (ichcm_ch(isecname,1,'$SCHEDULES').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                ctemp = ' '
                call hol2char(ibuf,ic1,ic2,ctemp)
                csked = ctemp
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              end if

C  $DRUDG
            else if (ichcm_ch(isecname,1,'$DRUDG').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                ctemp = ' '
                call hol2char(ibuf,ic1,ic2,ctemp)
                cdrudg = ctemp
                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
              end if

C  $SCRATCH
            else if (ichcm_ch(isecname,1,'$SCRATCH').eq.0) then
              if ((jchar(ibuf,1).ne.o'44').and.(ilen.ne.-1)) then
                ich = 1
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                ctmpnam = ' '
                call hol2char(ibuf,ic1,ic2,ctmpnam)
              end if
              call ifill(ibuf,1,ibuf_len*2,oblank)
              call reads(lu,ierr,ibuf,ibuf_len,ilen,1)
        
C  $PRINT
            else if (ichcm_ch(isecname,1,'$PRINT').eq.0) then
              do while((ilen.ne.-1).and.(jchar(ibuf,1).ne.o'44'))
                ich = 1
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                nch = ic2-ic1+1
                call ifill(itmpnam,1,10,oblank)
                idum= ichmv(itmpnam,1,ibuf,ic1,nch)
                call hol2upper(itmpnam,nch)
                call gtfld(ibuf,ich,ilen*2,ic1,ic2)
                if (ichcm_ch(itmpnam,1,'PORTRAIT').eq.0) then
                  call hol2char(ibuf,ic1,ilen*2-1,cprtpor)
                  call null_term(cprtpor)
                else if (ichcm_ch(itmpnam,1,'LANDSCAPE').eq.0) then
                  call hol2char(ibuf,ic1,ilen*2-1,cprtlan)
                  call null_term(cprtlan)
                else if (ichcm_ch(itmpnam,1,'PRINTER').eq.0) then ! printer line
                   nch=ic2-ic1+1
                   idum = ichmv(itmpnam,1,ibuf,ic1,nch) ! type
                   call hol2upper(itmpnam,nch)
                   call hol2char(itmpnam,1,nch,ctemp)
                   if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER'.or.
     .              ctemp.eq.'FILE'.or.ctemp.eq.'EPSON24') then
                     cprttyp=ctemp
                   else
                     write(luscn,9211) ctemp
9211                 format(' Unrecognized printer type ',A)
                   endif
C		call gtfld(ibuf,ich,ilen*2,ic1,ic2)
C		nch = ic2-ic1+1
C		if (nch.eq.0) then
C		  write(luscn,9212) ctemp
C212                      format(' Unrecognized port ',A)
C		else 
C		  call hol2char(ibuf,ic1,ic2,cprport) ! port
C                       endif
C		call gtfld(ibuf,ich,ilen*2,ic1,ic2)
C		nch = ic2-ic1+1
C		idummy = ichmv(itmpnam,1,ibuf,ic1,nch) ! width
C		call hol2uppe(itmpnam,nch)
C		call hol2char(itmpnam,1,nch,ctemp)
C		if (ctemp.ne.'NORMAL'.and.ctemp.ne.'COMPRESS') then
C		  write(luscn,9212) ctemp
C212                format(' Unrecognized width ',A)
C		else if (ctemp.eq.'NORMAL') then
C		  iwidth = 80
C		else if (ctemp.eq.'COMPRESS') then
C		  iwidth = 137
C		endif
C	    else
C                 write(luscn,9210) itmpnam
C210              format(" Unrecognizable print name ",5A2)
		    end if !printer line
C Original code, from Unix version. Above is full PC version.
C                 call hol2char(ibuf,ic1,ic2-ic1+1,cprttyp)
C                 call gtfld(ibuf,ich,ilen*2,ic1,ic2)
C                 call hol2char(ibuf,ic1,ic2-ic1+1,cprport)
C               else
C                 write(luscn,9210) itmpnam
C9210              format("Unrecognized print name ",5A2) 
C               end if 

                call ifill(ibuf,1,ibuf_len*2,oblank)
                call reads(lu,ierr,ibuf,ibuf_len,ilen,2)
              end do

            else
              write(luscn,9220) isecname
9220          format("Unrecognized section name ",5A2)
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
              write(luscn,9230)
9230          format("Error opening local control file skedf.ctl")
              close(lu)
              return
            end if
            itmplen = trimlen(ctmp2)
            write(luscn,9240) ctmp2(1:itmplen)
9240        format("Reading personal control file ",A)
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
