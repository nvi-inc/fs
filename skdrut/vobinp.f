      SUBROUTINE VOBINP(ivexnum,LU,iret,IERR,cscan_id)

C  This routine gets all the observations from the vex file.
C
C History
C 000606 nrv Re-new. Copied from VOB1INP.
C 001109 nrv New again. Use new vex parser routines to get
C            observations scan by scan.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ivexnum,lu,iret
C
C  OUTPUT:
      integer ierr ! error from this routine

C  CALLED BY: VREAD
C  CALLS:  fget_scan                 (get scan block info)
C          fget_station_scan         (get all stations in this scan)
C          fvex_scan_source          (get source in this scan)
c          newscan                   (form new scan)
C          addscan                   (add each station to the scan)
C
C  LOCAL:
      integer isor,icod,il,ip,ifeet,i,idrive,nstn_scan,istn
      integer idum,irec,ipnt
      integer*2 itim1(6),itim2(6)
      integer*2 lcb
      character*128 cmo,cstart,csor,cout,cunit,cscan_id
      integer ic1,ic2,ic11,ic12,ich,istart(5)
      double precision d,start_sec
      integer idstart,idend
      logical knew,kearl,ks2
      integer ichmv,ichmv_ch,ivgtso,ivgtmo,ivgtst
      integer ichcm_ch,fget_scan_station,fvex_scan_source,fvex_date,
     .fvex_field,fvex_int,fvex_double,fvex_units,ptr_ch,fvex_len,
     .fget_station_scan,fget_scan

C 1. Get scans one by one.

      write(lu,9100) 
9100  format('VOBINP - Generating observations')
      iret = fget_scan(ptr_ch(cstart),len(cstart),
     .       ptr_ch(cmo),len(cmo),
     .       ptr_ch(cscan_id),len(cscan_id),
     .       ivexnum)
      nobs=0
      ierr = 1 ! station
      do while (iret.eq.0) ! get all scans 
        if (nobs.gt.0.and.mod(nobs,100).eq.0) write(lu,9101) nobs
9101    format(i6," scans ... ")
        iret = fvex_date(ptr_ch(cstart),istart,start_sec)
        ierr=8 ! date/time
        if (iret.ne.0) return
        istart(5) = start_sec ! convert to integer
        ierr = 9 ! first source name
        iret = fvex_scan_source(1,ptr_ch(csor),len(csor))
        if (iret.ne.0) return
        ierr = 10 ! source index
        if (ivgtso(csor,isor).le.0) then
          il=fvex_len(csor)
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
        nstn_scan = 0
        iret = fget_station_scan(nstn_scan+1)
        do while (iret.eq.0) ! get all stations in the scan
          nstn_scan = nstn_scan + 1
          ierr = 1 ! station
          iret = fvex_field(1,ptr_ch(cout),len(cout))
          il = fvex_len(cout)
          if (iret.ne.0) return
          if (ivgtst(cout,istn).le.0) then
            write(lu,'("VOBINP04 - Station ",a," not found!")') 
     .      cout(1:il)
            return
          endif
          if (nchan(istn,icod).eq.0) then ! code not defined
            write(lu,'("VOBINP03 - Mode ",a," not defined for this ",
     .      "station!!")') cmo(1:il)
            return
          endif ! code not defined
          ks2=ichcm_ch(lstrec(1,istn),1,'S2').eq.0
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
C         idur = det-dst
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
          ip=1
          do while (ip.le.npassl(istn,icod).and.cout(1:il).ne.
     .              cpassorderl(ip,istn,icod)(1:il))
            ip=ip+1
          enddo
          if (ip.gt.npassl(istn,icod)) return ! pass not found
          ierr = 6 ! pointing sector
          iret = fvex_field(6,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          il = fvex_len(cout)
          if (il.eq.0) then ! null wrap
            idum=ichmv_ch(lcb,1,'- ')
          else ! check it
            if (cout(1:il).eq.'&n') idum=ichmv_ch(lcb,1,'- ')
            if (cout(1:il).eq.'&cw') idum=ichmv_ch(lcb,1,'C ')
            if (cout(1:il).eq.'&ccw') idum=ichmv_ch(lcb,1,'W ')
          endif
          ierr = 7 ! drive number
          iret = fvex_field(7,ptr_ch(cout),len(cout))
          if (iret.ne.0) return
          iret = fvex_int(ptr_ch(cout),i) ! convert to binary
          if (i.lt.0.or.iret.ne.0) return
          idrive=i

C  Make the new scan if this is the first source.

         if (nstn_scan.eq.1) then  ! new
           call newscan(istn,isor,icod,istart,idstart,
     .        idend,ifeet,ip,idrive,lcb,ierr)
           il = fvex_len(cscan_id)
           scan_name(iskrec(nobs)) = cscan_id(1:il)
           if (ierr.ne.0) write (lu,9108) ierr
9108       format('VOBINP05 - Error ',i5,' from newscan')
         else ! add
           irec = nobs
           call addscan(irec,istn,icod,idstart,idend,
     .        ifeet,ip,idrive,lcb,ierr)
           if (ierr.ne.0) then
             write(lu,9103) ierr,irec,istn,istart
9103         format('VOBINP06 - addscan error ',i3,' irec=',i3,' istn=',
     .          i3,'istart=',5i5)
           endif
         endif ! new or add

          iret = fget_station_scan(nstn_scan+1) ! get next station
        enddo  ! get all stations in this scan

C 5. Get the next scan.

        iret = fget_scan(ptr_ch(cstart),len(cstart),
     .         ptr_ch(cmo),len(cmo),
     .         ptr_ch(cscan_id),len(cscan_id),
     .         0)
      enddo ! get all scans

      if (ierr.gt.0) ierr=0
      if (ierr.eq.0) iret=0

      write(lu,9102) nobs
9102  format(1x,i6," scans in this schedule.")
      return
      end
