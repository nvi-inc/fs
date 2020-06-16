*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE VOB1INP(ivexnum,istn,LU,IERR,iret,nobs_stn)
      implicit none  !2020Jun15 JMGipson automatically inserted.

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
C 011114 nrv Check wrap for 'n' etc not '&n'!


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
! functions
      integer fget_scan_station,fvex_scan_source,fvex_date
      integer fvex_field,fvex_int,fvex_double,fvex_units,ptr_ch,fvex_len
      integer fget_data_transfer_scan
      integer ivgtso,ivgtmo
! variables
      integer isor,icod,il,ip,ifeet,i,idrive,irec
      integer*2 lcb
      character*2 ccb
      equivalence (lcb,ccb)
      character*128 cmo,cstart,csor,cout,cunit,cscan_id
      integer istart(5)
      double precision d,start_sec
      integer idstart,idend
      logical knew,ks2
      integer istat
      logical kfirst
C 1. Get scans for one station.

      write(lu,9100) lpocod(istn)
9100  format('VOB1INP - Generating observations for ',a2)
      nobs_stn=0
      ierr = 1 ! station
      ks2=cstrec(istn)(1:2) .eq. "S2"
      irec = 0 ! initialize the starting record for findscan

      iret=0
      kfirst=.true.
      do while (iret.eq.0) ! get all scans for this station
        if(kfirst) then
           istat=ivexnum
           kfirst=.false.
        else
          istat=0
        endif
        iret = fget_scan_station(ptr_ch(cstart),len(cstart),
     >          ptr_ch(cmo),len(cmo),
     >          ptr_ch(cscan_id),len(cscan_id),
     >          ptr_ch(stndefnames(istn)),istat)
        if(iret .ne. 0) goto 100
        if(.false.) then
! ******************NEW CODE For Data transfer option
        do while(iret .eq. 0)
          do istat=1,nstatn
            iret=fget_data_transfer_scan(istat)
            if(iret .ne. 0) goto 20
            do i=1,9
              iret = fvex_field(i,ptr_ch(cout),len(cout))
              if(iret .ne.0) goto 15
            end do
15          continue
          end do
        end do

20      continue
        endif
        istat=0            !this has to be 0 for next call to fget_scan_station


! *** End of Data transfer
        iret = fvex_date(ptr_ch(cstart),istart,start_sec)
        ierr=2 ! date/time
        if (iret.ne.0) return
        nobs_stn=nobs_stn+1
        istart(5) = start_sec ! convert to integer

        ierr = 9 ! first source name
        iret = fvex_scan_source(1,ptr_ch(csor),len(csor))
        if (iret.ne.0) return

        if (ivgtso(csor,isor).le.0) then
          il=fvex_len(csor)
          ierr = 10 ! source index
          write(lu,'("VOBINP01 - Source ",a," not found")') csor(1:il)
          return
        endif

        il=fvex_len(cmo)
        if (ivgtmo(cmo,icod).le.0) then
          ierr = 11 ! code index
          write(lu,'("VOBINP02 - Mode ",a," not found")') cmo(1:il)
          return
        endif
        if (nchan(istn,icod).eq.0) then ! code not defined
          write(lu,
     >     '("VOBINP03 - Mode ",a," not defined for station ",a2)')
     >      cmo(1:il),lpocod(istn)
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
     .            cpassorderl(ip,istn,icod)(1:il))
          ip=ip+1
        enddo
        if (ip.gt.npassl(istn,icod)) return ! pass not found

        ierr = 6 ! pointing sector
        iret = fvex_field(6,ptr_ch(cout),len(cout))
        if (iret.ne.0) return
        il = fvex_len(cout)
        if (il.eq.0) then ! null wrap
           ccb="-  "
        else ! check it
          if (cout(1:il).eq.'n')   ccb="- "
          if (cout(1:il).eq.'cw')  ccb="C "
          if (cout(1:il).eq.'ccw') ccb="W "
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
9108    format('vob1inpxx - Error ',i5,' from newscan')

C  4. This next section orders the index array, iskrec, in time order.
! Sorting is not done in vread.

C 5. Get the next station record.
      enddo ! get all obs for this station

100   continue
      if (ierr.gt.0) ierr=0
      if (ierr.eq.0) iret=0

      return
      end
