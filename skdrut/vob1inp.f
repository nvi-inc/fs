      SUBROUTINE VOB1INP(ivexnum,istn,LU,IERR,iret,nobs_stn)

C  This routine gets all the observations for one station
C  from the vex file.
C  Call after VREAD which reads exper, sources, stations, modes.
C  Call in a loop to get all stations.
C
C History
C 960531 nrv New.
C 960817 nrv Changes for S2. Note that VOBINP has NOT been changed!
C            These two routines should be combined so that VOBINP
C            calls this one!
C 970110 nrv Add code index to cpassorderl
C 970121 nrv Add station and code index to npassl
C 970129 nrv Add nobs_stn to call
C 970307 nrv Find the time field by skipping fields, not using absolute
C            character counts. 
C 970523 nrv TEMPORARY fix -- remove time ordering!
C 970717 nrv Read the "drive" field as the record/norecord flag
C 991020 nrv Fix time ordering.
C 000611 nrv Remove time ordering to OSORT. Remove print statement.
C 001108 nrv Initialize irec=0 before first call to findscan.


      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ivexnum,lu,istn
C
C  OUTPUT:
      integer iret ! error from vex routines
      integer ierr ! error from this routine
      integer nobs_stn ! number of scans found for this station

C  CALLED BY: 
C  CALLS:  fget_scan_station         (get station lines)
C          fvex_scan_source          (get sources in a scan)
c          newscan                   (form new scan)
C          addscan                   (add a station to a scan)
C          findscan                  (find a matching scan)
C
C  LOCAL:
      integer isor,icod,il,ip,ifeet,i,idrive
      integer idum,irec,ipnt
      integer*2 itim1(6),itim2(6)
      integer*2 lcb
      character*128 cmo,cstart,csor,cout,cunit,cscan_id
      integer ic1,ic2,ic11,ic12,ich,istart(5)
      double precision d,start_sec
      integer idstart,idend
      logical knew,kearl,ks2
      integer ichmv,ichmv_ch,ivgtso,ivgtmo
      integer ichcm_ch,fget_scan_station,fvex_scan_source,fvex_date,
     .fvex_field,fvex_int,fvex_double,fvex_units,ptr_ch,fvex_len

C 1. Get scans for one station. 

        write(lu,9100) lpocod(istn)
9100    format('VOB1INP - Generating observations for ',a2)
        iret = fget_scan_station(ptr_ch(cstart),len(cstart),
     .         ptr_ch(cmo),len(cmo),
     .         ptr_ch(cscan_id),len(cscan_id),
     .         ptr_ch(stndefnames(istn)),ivexnum)
        nobs_stn=0
        ierr = 1 ! station
        ks2=ichcm_ch(lstrec(1,istn),1,'S2').eq.0
        irec = 0 ! initialize the starting record for findscan
        do while (iret.eq.0) ! get all scans for this station
          nobs_stn=nobs_stn+1
          iret = fvex_date(ptr_ch(cstart),istart,start_sec)
          ierr=2 ! date/time
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
            return
          endif
          if (nchan(istn,icod).eq.0) then ! code not defined
            write(lu,'("VOBINP03 - Mode ",a," not defined for ",
     .      "station ",a2)') cmo(1:il),lpocod(istn)
            return
          endif
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
C         Keep good data offset and duration separate
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

C 3. Try to find a matching time, source
C    and mode. If there is one, add this station to the observation.
C    If there is not one, make a new observation.

C    Getting scans for only one station doesn't require the findscan call.
     
C           call findscan(isor,icod,istart,irec)
C           if (irec.ne.0) then ! add this station
C             call addscan(irec,istn,icod,idstart,idend,
C    .        ifeet,ip,idrive,lcb,ierr)
C             knew=.false.
C             if (ierr.ne.0) then
C               write(lu,9103) ierr,irec,istn,istart
C9103            format('addscan error ',i3,' irec=',i3,' istn=',i3,
C    .          ' istart=',5i5)
C             endif
C           else ! new scan
              call newscan(istn,isor,icod,istart,idstart,
     .        idend,ifeet,ip,idrive,lcb,ierr)
              il = fvex_len(cscan_id)
              scan_name(iskrec(nobs)) = cscan_id(1:il)
              knew=.true.
              if (ierr.ne.0) write (lu,9108) ierr
9108          format('vob1inpxx - Error ',i5,' from newscan')
C           endif

C  4. This next section orders the index array, iskrec, in time order.
C     If we just got a new observation, and it's not in time order,
C     bubble it up until it is.
C SORTing is done in vread after getting all of the scans
C for all of the stations.
C
C     if (nobs.ge.2.and.knew) then ! check time order
C       irec=nobs
C       Find the time field by skipping over 4 fields
C       ich=1
C       do i=1,5 ! want the 5th field 
C         CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC11,IC2)
C       enddo
C       ich=1
C       do i=1,5 ! want the 5th field 
C         CALL GTFLD(lskobs(1,iskrec(irec-1)),ICH,IBUF_LEN*2,IC12,IC2)
C       enddo
C       idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic11,11)
C       idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
C       do while (kearl(itim1,itim2).and.irec.gt.1)  !out of order
C         Swap pointers
C         ipnt = iskrec(irec-1)
C         iskrec(irec-1) = iskrec(irec)
C         iskrec(irec) = ipnt
C         Get new time fields 
C         Get time field of the now-correct last record.
C         irec = irec-1
C         idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic12,11)
C         ich=1
C         do i=1,5 ! want the 5th field 
C           CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC12,IC2)
C         enddo
C         idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
C       end do  !out of order
C     endif

C 5. Get the next station record.

          iret = fget_scan_station(ptr_ch(cstart),len(cstart),
     .           ptr_ch(cmo),len(cmo),
     .         ptr_ch(cscan_id),len(cscan_id),
     .           ptr_ch(stndefnames(istn)),0)
        enddo ! get all obs for this station
      if (ierr.gt.0) ierr=0
      if (ierr.eq.0) iret=0

      return
      end
