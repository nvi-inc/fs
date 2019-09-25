      SUBROUTine VOBINP(ivexnum,LU,iret,IERR)
      implicit none 

C  This routine gets all the observations from the vex file.
C
C History
C 000606 nrv Re-new. Copied from VOB1INP.
C 001109 nrv New again. Use new vex parser routines to get
C            observations scan by scan.
! 2004Feb14 JMG.  When checking cable wrap, check for both "&c" and "c", etc.
! 2005May05 JMG.  Removed refrences to irec, which is never used.
! 2006Jul17 JMG. Got rid of using ivtgso, replaced by iwhere_in_string_list
! 2006Nov06 JMG. Initialize iret
! 2014Jul08 JMG. Some modifications to handle the case where scans contain stations which were not in VEX $STATION section.
!                In this case Drudg will issue a warning and if the user likes, proceed. 
! 2014Sep16 JMG. Fixed a bug introduced in 2014Jul08.  Previously would generate a new scan for each 
!                station in a scan because kfirst_staiton was always getting reinitialized. 
!                Moved initialization out of station loop. 
! 2019Aug27 JMG. Fixed bug in converting date. Need to initialize istart because conversion routine is only setting lower bytes

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
C
C  INPUT:

      integer ivexnum,lu
C
C  OUTPUT:
      integer ierr ! error from this routine
      integer iret

C  CALLED BY: VREAD
C  CALLS:  fget_scan                 (get scan block info)
C          fget_station_scan         (get all stations in this scan)
C          fvex_scan_source          (get source in this scan)
c          newscan                   (form new scan)
C          addscan                   (add each station to the scan)
C

! functions
      integer fvex_scan_source,fvex_date
      integer fvex_field,fvex_int,fvex_double,fvex_units,ptr_ch,fvex_len
      integer fget_station_scan,fget_scan
      integer fget_data_transfer_scan
      integer ivgtmo,ivgtst
      integer iwhere_in_string_list
C  LOCAL:
      integer isor,icod,il,ip,ifeet,i,idrive,istn_scan,istn
!      integer irec

      character*128 cmo,cstart,cout,cunit,cscan_id
      character*(max_sorlen) csor
      integer istart(5)
      double precision d,start_sec
      integer idstart,idend
      logical ks2

      character*128 ldata_transfer_method
      integer ixfer_cnt
      integer istat
      character*1 cbl
      character*1 lchar
      logical kfirst_station

      integer itemp
      integer nch
      logical kignore_error
! 0. Initialize data transfer info.
      ixfer_cnt=0

      Kin2Net_2_Disk2File=.false.
      kDisk2File_2_in2net=.false.
      kno_data_xfer=.false.
      ldestin_in2net=" "
      lglobal_in2net =" "

      do i=1,max_stn
        lstat_first_in2net(i)=" "
        kstat_in2net(i)=.false.
        kstat_disk2file(i)=.false.
      end do
      kignore_error=.false.

C 1. Get scans one by one.

      write(lu,"('VOBINP - Generating observations ',$)")
      nobs=0
      ierr = 1 ! station
      iret=0
      do while (iret.eq.0) ! get all scans     
        if(nobs .eq. 0) then
           itemp=ivexnum
        else
           itemp=0
        endif     
        iret = fget_scan(ptr_ch(cstart),len(cstart),
     .         ptr_ch(cmo),len(cmo),
     .         ptr_ch(cscan_id),len(cscan_id),
     .         itemp)
       
        if(iret .ne. 0) then
          if(ierr .gt. 0) ierr=0
          if(ierr .eq. 0) iret=0
          write(lu, '(i6," scans in this schedule.")') nobs
          return
        endif
      
        if (mod(nobs,100).eq.0) write(lu,'(i5,$)') nobs

        istart=0
        iret = fvex_date(ptr_ch(cstart),istart,start_sec)
        ierr=8 ! date/time
        if (iret.ne.0) return
        istart(5) = start_sec ! convert to integer
        ierr = 9 ! first source name
        iret = fvex_scan_source(1,ptr_ch(csor),len(csor))
        if (iret.ne.0) return
        ierr = 10 ! source index
        il=fvex_len(csor)
        isor=iwhere_in_string_list(csorna,nsourc,csor(1:il))
        if(isor .eq. 0) then
!        if (ivgtso(csor,isor).le.0) then
          write(lu,'("VOBINP01 - Source ",a," not found")') csor(1:il)
          return
        endif
        ierr = 11 ! code index
        il=fvex_len(cmo)
        if (ivgtmo(cmo,icod).le.0) then
          write(lu,'("VOBINP02 - Mode ",a," not found")') cmo(1:il)
        endif
        il=fvex_len(cscan_id)
C-------------------------------------------------------------
C       Now get each station line that is part of this scan.
        cout=" "
!        write(*,*) "***New scan****, NSTATN: ",nstatn 
        kfirst_station=.true.  
        do istn_scan=1,nstatn  
!          write(*,*) "nobs, istn_scan ", nobs, istn_Scan,              fget_station_scan(istn_scan)            
          if(fget_station_scan(istn_scan) .ne. 0) goto 100                  
          cout=" " 
          iret = fvex_field(1,ptr_ch(cout),len(cout))     
          ierr=1
          if (iret.ne.0) then
            return
          endif
        
          il = fvex_len(cout)
          if (ivgtst(cout,istn).le.0) then
            if(kignore_error) goto 100            
            write(lu,*) "VOBINP04 - Station ",cout(1:il)," not found!"
            lchar="-"
            do while(lchar .ne. "Y" .and. lchar .ne. "N") 
              write(*,*)  "Ignore this error? (Y/N)"
              read(*,*) lchar
              call capitalize(lchar)
              if(lchar .eq. "N") return
            end do 
            kignore_error=.true. 
            goto 100 
          endif
         
!          write(*,*) "station #: ", " >"//cout(1:4)//"< ",istn 
!          pause 
          if (nchan(istn,icod).eq.0) then ! code not defined          
            write(lu,*) "VOBINP03 - Mode ",
     >      cmo(1:fvex_len(cmo))," not defined for station: ", 
     >      cout(1:fvex_len(cout))
            return
          endif ! code not defined

          ks2=cstrec(istn,1)(1:2).eq."S2"
          ierr = 2 ! data start
          iret = fvex_field(2,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0) return
          idstart = d

          ierr = 3 ! data end
          iret = fvex_field(3,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0) return
          idend = d

C       Keep good data offset and duration separate
          ierr = 4 ! footage
          iret = fvex_field(4,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (ks2) then 
            ifeet = d ! leave as seconds
          else 
            ifeet = d*100.d0/(2.54*12.d0) ! convert mks to feet
          endif
          ierr = 5 ! pass
          iret = fvex_field(5,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          il = fvex_len(cout)
! fixup for Mark5.     
          if((cstrec(istn,1)(1:5) .eq. "Mark5" .or.   
     >        cstrec(istn,1)(1:4) .eq. "none"  .or.  
     >        cstrec(istn,1)(1:5) .eq. "Mark6") .and. il .eq. 0) then
             ip=1
             if(npassl(istn,icod) .eq. 0) then
                npassl(istn,icod)=1
              endif
          else
            ip =iwhere_in_string_list(cpassorderl(1,istn,icod),
     >         npassl(istn,icod),cout(1:il))
          endif            

          if(ip .eq. 0) return     ! pass not found

          ierr = 6 ! pointing sector
          iret = fvex_field(6,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          il = fvex_len(cout)
          if (il.eq.0) then ! null wrap
            cbl="N"            !None
          else ! check it
            if (cout(1:il).eq.'&n' .or. cout(1:il) .eq. 'n')   cbl='-'
            if (cout(1:il).eq.'&cw'.or. cout(1:il) .eq. 'cw')  cbl='C'
            if (cout(1:il).eq.'&ccw'.or.cout(1:il) .eq. 'ccw') cbl='W'
          endif
          ierr = 7 ! drive number
          iret = fvex_field(7,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          iret = fvex_int(ptr_ch(cout),i) ! convert to binary
          if (i.lt.0.or.iret.ne.0) return
          idrive=i

C  Make the new scan if this is the first source.
!         write(*,*) "Here!! ",kfirst_station

         if (kfirst_station) then  ! first station in this scan--new scan.
           call newscan(istn,isor,icod,istart,idstart,
     .        idend,ifeet,ip,idrive,cbl,ierr)
           il = fvex_len(cscan_id)
           scan_name(iskrec(nobs)) = cscan_id(1:il)
           if (ierr.ne.0) write (lu,9108) ierr
9108       format('VOBINP05 - Error ',i5,' from newscan')
           kfirst_station=.false. 
         else ! add
           call addscan(nobs,istn,icod,idstart,idend,
     .        ifeet,ip,idrive,cbl,ierr)
           if (ierr.ne.0) then
             write(lu,9103) ierr,istn,istart
9103         format('VOBINP06 - addscan error ',i3,' istn=',i3,
     >         ' istart=',i4,1x,i3,1x,3i2)
           endif
         endif ! new or add
100       continue      !come here on quick exit. 
        enddo  ! get all stations in this scan

! Now process the data_transfer lines
        ixfer_beg(nobs)=ixfer_cnt+1
        do istn_scan=1,Max_Stn
          if(fget_data_transfer_scan(istn_scan) .ne. 0) goto 200
          ixfer_cnt=ixfer_cnt+1            !
! Now parse the line
! First get station.
          iret = fvex_field(1,ptr_ch(cout),len(cout))
          if (iret.ne.0) then
            return
          endif
! Check to see if a valid station.
! Should check to see if this station is in this scan?
          il = fvex_len(cout)
          istat= ivgtst(cout,istn)

          if(istat .le. 0) then
            write(lu,*) "VOBINP14 - Station ",cout(1:il)," not found!"
            return
          endif
          ixfer_stat(ixfer_cnt)=istat
!
          iret = fvex_field(2,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          ldata_transfer_method=cout(1:fvex_len(cout))
          call capitalize(ldata_transfer_method)
          if(ldata_transfer_method.eq."IN2NET") then
            ixfer_method(ixfer_cnt)=ixfer_in2net
            kstat_in2net(istat)=.true.
          else if(ldata_transfer_method.eq."DISK2FILE") then
            ixfer_method(ixfer_cnt)=ixfer_disk2file
            kstat_disk2file(istat)=.true.
          else
            write(lu,*) "VOBINP: Unknown data transfer type!"
            return
          endif

          iret = fvex_field(3,ptr_ch(cout),len(cout))
          if(iret .ne. 0) return
          nch=fvex_len(cout)
          if(nch .eq. 0) then
            lxfer_destination(ixfer_cnt)=" "
          else
            lxfer_destination(ixfer_cnt)=cout(1:nch)
            if(ixfer_method(ixfer_cnt) .eq. ixfer_in2net .and.
     >         lstat_first_in2net(istn) .eq. " ") then
               lstat_first_in2net(istn)= lxfer_destination(ixfer_cnt)
            endif
          endif

          iret = fvex_field(4,ptr_ch(cout),len(cout))
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
! may not have anything here. If so, use beginning of scan.
          if(iret .eq. 0) then
             xfer_beg_time(ixfer_cnt)=d
          else
             xfer_beg_time(ixfer_cnt)=idend
          endif

          iret = fvex_field(5,ptr_ch(cout),len(cout))
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if(iret .eq. 0) then
             xfer_end_time(ixfer_cnt)=d
          else
             xfer_end_time(ixfer_cnt)=0.0
          endif

          iret = fvex_field(6,ptr_ch(cout),len(cout))
          if(iret .eq. 0) then
             lxfer_options(ixfer_cnt)=" "
          else
             lxfer_options(ixfer_cnt)=cout(1:fvex_len(cout))
          endif

        end do
200     continue
        if(ixfer_cnt .lt. ixfer_beg(nobs)) then
            ixfer_beg(nobs)=0
        else
          ixfer_end(nobs)=ixfer_cnt
        endif

C 5. Get the next scan.
        iret=0
      enddo ! get all scans

      return
      end
