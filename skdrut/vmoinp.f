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
      SUBROUTINE VMOINP(ivexnum,LU,IERR)
      implicit none

C     This routine gets all the mode information from the vex file.
C     Call once to get all values in freqs.ftni filled in, then call
C     SETBA to figure out which frequency bands are there.
C
!Updates
! 2021-01-31 JMG Removed call to vunproll since don't use barrel roll anymore
! 2021-01-05 JMG Replaced max_frq by max_code. (Max_frq was confusing and led to coding errors.)
! 2020-12-30 JMG Removed unused variables
! 2020-10-03 JMG Removed references to headstacks, passes, tapes
! 2019-09-03 JMG Implicit none
C History
C 960518 nrv New.
C 960522 nrv Revised.
C 960610 nrv Move initialization of freqs.ftni arrays here
C 960817 nrv Add S2 record mode
C 961003 nrv Keep getting modes even if there are too many.
C 961018 nrv Change the index on the BBC link to be the index found when
C            the BBC list was searched, instead of the channel index.
C            Check "lnetsb" and not "lsubvc" (subgroup!) for sideband.
C 961020 nrv Add call to VUNPROLL and store the roll def in LBARREL
C 961022 nrv Change MARK to Mark for checking rack/rec types.
C 961101 nrv Don't complain if things are missing from the modes for
C            some stations. Just set nchan to 0 as a flag.
C 970110 nrv Save the pass order list by code number.
C 970114 nrv Call VUNPPRC to read $PROCEDURES. Store prefix.
C 970114 nrv Add polarization to VUNPIF call. Save LPOL per channel.
C 970121 nrv Save npassl by code and station!
C 970123 nrv Add calls to ERRORMSG
C 970124 nrv Remove "lm" from call to vunpS2M
C 970206 nrv Remove itra2, ihdpo2,ihddi2 and add headstack index
C            Change call to VUNPHP to add number of headstacks found.
C 970206 nrv Change size of arrays to VUNPTRK for fandefs to max_track.
C 970213 nrv Remove the test for a rack before setting NCHAN. It should be
C            set even for rack=none
C 971208 nrv Add fpcal, fpcal_base to vunpif call. Add cpcalref to vunpfrq.
C 971208 nrv Add call to VUNPPCAL.
C 991110 nrv Save modedefname as catalog name.
C 011119 nrv Clean up logic so that information isn't saved if there
C            aren't any chan_defs.
C 020112 nrv Add roll parameters to VUNPROLL call. Add call to CKROLL.!
C 020327 nrv Add data modulation paramter to VUNPTRK.
C 021111 jfq Extend S2 mode to support LBA rack
! 2006Oct06. Made arguments to vunpif all ASCII.
! 2006Nov18. Converted remaining holleriths to ASCII.
! 2006Nov29  Capitalize before checking on recorder.
! 2007Jul13  Fixed bug if nchdefs=0.  Was trying to check roll, but this wouldn't work
! 2010.06.15 Fixed bug if recorder was K5. Wasn't initializing tracks.
! 2012Sep14  Fixed bug with not initializing bbc_present for VEX schedules
! 2015Jun05  JMG Modified to use new version of itras.
! 2016Jan19  JMG. Changed dim of variables: max_track-->2*max_track since sign& magnitude can be on same  track
! 2016Jan19 Also re-arranged definition of parameters to group like to together
! 2017Feb27  Skip some stuff dealing with headstack for Disk recording.
! 2018Oct09  Preserve mode and band if VEX created from sked previously.  Previously was setting to numerical value, first mode=
!            Also keep better track of number of  freq-channels. If everything except for side-band is the same, assume same fre
!            which means use same BBC.


      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
C
C  INPUT:
      integer ivexnum,lu
C
C  OUTPUT:
      integer ierr

C  CALLED BY:
C  CALLS:  fget_mode_def
C          frinit
C          vunpfrq, vunpbbc,vunpif,vunpprc,vunptrk,vunphead,
C          vunroll,ckroll
! function
      integer iwhere_in_string_list
      integer ptr_ch,fvex_len,fget_mode_def,fget_all_lowl
C
C  LOCAL:
      logical kadd_track_map

      integer ix,ib,ic,i,ia,icode,istn
      integer il,im,in, iret,ierr1,iul,ism,ip,ipc,itone
      integer ifanfac
    
      double precision bitden_das
      integer npcaldefs
      integer nchdefs,nbbcdefs,nifdefs,nfandefs,nhdpos

      character*8 cpre
      character*16 cm

      character*4 cmodu ! ON or OFF

! IF related parameters.
      character*6 cifdref(max_ifd)
      character*2 cin2(max_ifd),cs2(max_ifd),cp2(max_ifd)      !LO, sideband

! BBC parameters
      character*6 cbbcref(max_bbc)
!Things that depend on number of channels.

      character*3 cs(max_chan)
      character*6 cfrbbref(max_chan)

      character*6 cbbifdref(max_chan)
      character*6 cfrpcalref(max_chan)
      character*6 cpcalref(max_chan)
      character*6 cchanidref(max_chan)
      character*2 csb(max_chan),csg(max_chan)
      integer ipct(max_chan,max_tone),ntones(max_chan)

      double precision frf(max_chan),flo(max_chan),vbw(max_chan)
      double precision fpcal(max_chan),fpcal_base(max_chan)

! Things that depend on number of fandefs
      character*1 cp(max_fandef)           ! subpass
      character*6 ctrchanref(max_fandef)   ! channel ID ref
      character*1 csm(max_fandef)          ! sign/mag
      integer ihdn(max_fandef)             ! headstack number
      integer itrk(max_fandef)             ! first track of the fanout assignment


      integer ivc(2*max_bbc)

!things that depend pass.   
      double precision srate
      character*128 cout

      logical kDiskRec

      character*8 crecorder  !temporary holding
      integer ibbc   !index

      logical kvunppcal_first    !first call to vunppcall
      character*1 lq

      integer ifc            !number of frequency channels.
      integer ib_old

      integer ind
      integer itmp
      logical kvex_from_sked    !sees if originally came from a sked file

!*********************************************************************************************
! Start of code
      lq="'"
      kvunppcal_first=.true.

! See if has $SCHEDULING_PARAMS
       iret=fget_all_lowl(ptr_ch(char(0)),ptr_ch(char(0)),
     .  ptr_ch('literals'//char(0)),
     .  ptr_ch('SCHEDULING_PARAMS'//char(0)),ivexnum)      
      kvex_from_sked=iret .eq. 0
      if(kvex_from_sked) then 
        write(*,*) "File originally came from sked"
      endif 


! 1. First get all the mode def names.
!    Station names have already been gotten and saved.
!
      ncodes=0
      iret = fget_mode_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        il=fvex_len(cout)
        IF  (ncodes.eq.max_code) THEN  !
          write(lu,'("VMOINP01 - Too many modes.  Max is ",
     .    i3,".  Ignored: ",a)') max_code,cout(1:il)
        else
          ncodes=ncodes+1
          modedefnames(ncodes)=cout
          if (il.gt.16) then
            write(lu,'(a)')  "VMOINP02 - Mode name   "//cout(1:il)//
     >      " too long for matching in sked catalogs."
            write(lu,'(a)') "Only keeping 16 chars: "//cout(1:16)
            il=16
          endif
          cmode_cat(ncodes)=cout(1:il)
          write(*,*) "Found mode: ", cout(1:il)
! This is the default
          write(ccode(ncodes)(1:2),'(i2.2)') ncodes
          cnafrq(ncodes)=ccode(ncodes)
          ind=index(cout(1:il),".") 
          if(kvex_from_sked.and. ind .ne. 0) then 
            itmp=min(8,ind-1)
            if(itmp .gt. 0) then
              itmp=min(8,ind-1) 
              cnafrq(ncodes)=cout(1:itmp)
              ccode(ncodes)=cout(ind+1:ind+2)
              write(*,*) cnafrq(ncodes), " ", ccode(ncodes) 
            endif 
          endif 
        END IF
        iret = fget_mode_def(ptr_ch(cout),len(cout),0) ! get next one
      enddo

C 1.5 Now initialize arrays using nstatn and ncodes.
      call frinit(nstatn,ncodes)

C 2. Call routines to retrieve and store all the mode/station
C    information, one mode/station at a time. Not all modes are
C    defined for all stations.


      ierr1=0
      do icode=1,ncodes ! get all mode information

!        il=fvex_len(modedefnames(icode))
!        write(*,*) "modeefnames: ", modedefnames(icode)(1:il)

! START pre-2018OCT09 way of assigning codes.
C    Assign a code to the mode and the same to the name
!        write(ccode(icode)(1:2),'(i2.2)') icode
!        cnafrq(icode)=ccode(icode)
! End old way of assigning codes.
        do istn=1,nstatn ! for one station at a time  

! Initialize this array.
          call new_track_map()
          kadd_track_map=.false.

          im=fvex_len(stndefnames(istn))
          crecorder=cstrec(istn,1)
          call capitalize(crecorder)

! Find what kind of recorder.
          kDiskRec=.true.

C         Get $FREQ statements. If there are no chan_defs for this
C         station, then skip the other sections.
          CALL vunpfrq(modedefnames(icode),stndefnames(istn),
     >      ivexnum,iret,ierr,lu,bitden_das,srate,cSG,Frf,csb,
     >      cchanidref,VBw,cs,cfrbbref,cfrpcalref,nchdefs)
          if (ierr.ne.0) then
            write(lu,'("VMOINP02 - Error getting $FREQ information",
     >        " for mode ",a," station ",a,/" iret=",i5," ierr=",i5)')
     >        modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     >        iret,ierr
            call errormsg(iret,ierr,'FREQ',lu)
            ierr1=1
          endif

C         Get $PROCEDURES statements.
C         (Get other procedure timing info later.)
          call vunpprc(modedefnames(icode),stndefnames(istn),
     &      ivexnum,iret,ierr,lu,cpre)
          if (ierr.ne.0) then
            write(lu,'("VMOINP03 - Error getting $PROCEDURES for mode "
     &      ,a," station ",a,/" iret=",i5," ierr=",i5)')
     &      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     &      iret,ierr
            call errormsg(iret,ierr,'PROCEDURES',lu)
            ierr1=1
          endif

        nchan(istn,icode) = nchdefs
        if (nchdefs.gt.0) then ! chandefs > 0
C         Get $BBC statements.
          call vunpbbc(modedefnames(icode),stndefnames(istn),
     >     ivexnum,iret,ierr,lu,cbbcref,ivc,cbbifdref,nbbcdefs)
          do ibbc=1,max_bbc
            if(ivc(ibbc) .ne. 0) then
               ibbc_present(ivc(ibbc),istn,icode)=1
            endif
          end do
          if (ierr.ne.0) then
            write(lu,'("VMOINP04 - Error getting $BBC information",
     .      " for mode ",a," station ",a,/" iret=",i5," ierr=",i5)')
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),iret,ierr
            call errormsg(iret,ierr,'BBC',lu)
            ierr1=2
          endif

C         Get $IF statements.
          call vunpif(modedefnames(icode),stndefnames(istn),
     .       ivexnum,iret,ierr,lu,
     .       cifdref,flo,cs2,cIN2,cp2,fpcal,fpcal_base,nifdefs)
          if (ierr.ne.0) then
            write(lu,'("VMOINP05 - Error getting $IF information",
     .      " for mode ",a," station ",a,/" iret=",i5," ierr=",i5)')
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),iret,ierr
            call errormsg(iret,ierr,'IF',lu)
            ierr1=3
          endif

C         Get $TRACKS statements (i.e. fanout).
          call vunptrk(modedefnames(icode),stndefnames(istn),kDiskRec,
     .      ivexnum,iret,ierr,lu,
     .      cm,cp,ctrchanref,csm,itrk,nfandefs,ihdn,ifanfac,cmodu)
          if (ierr.ne.0) then
            write(lu,'("VMOINP06 - Error getting $TRACKS information",
     .      " for mode ",a," station ",a,/" iret=",i5," ierr=",i5)')
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'TRACKS',lu)
            ierr1=4
          endif

C         Get $HEAD_POS and $PASS_ORDER statements.
! Now set to default since no disk recording...
          nhdpos=1

C         Get $PHASE_CAL_DETECT statements.
          call vunppcal(modedefnames(icode),stndefnames(istn),ivexnum,
     >        iret,ierr,lu,cpcalref,ipct,ntones,npcaldefs,
     >         kvunppcal_first)
C
C 3. Now decide what to do with this information. If we got to this
C    point there were no reading or content errors for this station/mode
C    combination. Some consistency checks are done here.
C

! prior to 2018Oct03, did not use ifc.
! 'ifc' keeps track of number of independnent channels.
!  if have same channel configuration except for sidebands,  corresponds to same ifc.
!  Because of this  final ifc can less than nchdefs.

          ifc=1   !initialize
C    Save the chan_def info and its links.
          do i=1,nchdefs ! each chan_def line
            ib=iwhere_in_string_list(cbbcref,nbbcdefs,cfrbbref(i))
! Check if previous was the same as this. If so, same frequency channel.
            if(i .gt.1) then
              if(frf(i) .ne. frf(i-1) .or.
     >           csg(i) .ne. csg(i-1) .or.
     >           vbw(i) .ne. vbw(i-1) .or.
     >           cs(i)  .ne. cs(i-1)  .or.
     >           ib     .ne. ib_old ) then
                 ifc=ifc+1
              endif
            endif
            ib_old=ib

            invcx(ifc,istn,icode)=ifc ! save channel index number
            cSUBVC(ifc,istn,ICODE) = cSG(i) ! sub-group, i.e. S or X
            FREQRF(ifc,istn,ICODE) = Frf(i) ! RF frequency
!            cnetsb(i,istn,icode) = csb(i) ! net sideband
! Actual value of sideband determined by tracklayout (ITRAS below)
            cnetsb(ifc,istn,icode) = "U"
!            write(*,*) "CSB: ", csb(i)
            VCBAND(ifc,istn,ICODE) = VBw(i) ! video bandwidth
            ifan(istn,icode)=ifanfac ! fanout factor
            cset(ifc,istn,icode) = cs(i) ! switching
C           BBC refs

            if(ib .eq. 0) then
              write(lu,'("VMOINP09 - BBC link missing for channel ",i3,
     &        " for mode ",a," station ",a)') i,
     &        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            else
              ibbcx(ifc,istn,icode) = ivc(ib) ! BBC number
            endif
            ic=iwhere_in_string_list(cifdref,nifdefs,cbbifdref(ib))

            if (ic.eq.0) then
              write(lu,'("VMOINP10 - IFD link missing for channel ",i3,
     &        " for mode ",a," station ",a)') i,
     &        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            else
              cifinp(ifc,istn,icode) = cin2(ic) ! IF input channel
              cosb(ifc,istn,icode)   = cs2(ic)  ! LO sideband
              cpol(ifc,istn,icode)   = cp2(ic)  ! polarization
              freqlo(ifc,istn,icode) = flo(ic)  ! LO frequency
              freqpcal(ifc,istn,icode) = fpcal(ic) ! pcal frequency
              freqpcal_base(ifc,istn,icode) = fpcal_base(ic) ! pcal_base frequency
            endif
C           Phase cal refs
            ipc=iwhere_in_string_list(cpcalref,npcaldefs,cfrpcalref(i))

            if (ipc.eq. 0) then
              in=fvex_len(cfrpcalref(i))
              write(lu,
     >       '("VMOINP15 - PCAL link ",a,a,a" missing for channel ",i3,
     >            " for mode ",a," station ",a)')
     >         lq, cfrpcalref(i)(1:in),lq, i,
     >         modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            else
              do itone=1,ntones(ipc)
                ipctone(itone,i,istn,icode)=ipct(ipc,itone)
                npctone(i,istn,icode)=ntones(ipc)
              enddo
            endif
C           Track assignments

            ip=1 !pass is always 1            
            do ix=1,nfandefs ! check each fandef
!               write(*,*) ctrchanref(ix), cchanidref(i) 
              if (ctrchanref(ix).eq.cchanidref(i)) then ! matched link           
                ism=1 ! sign
                if (csm(ix).eq.'m') ism=2 ! magnitude
                iul=1 ! usb
                if(csb(i) .eq. "L") iul=2
                if (cstrack(istn) .eq. "LBA" ) then
                  ia=1
                  do while (ia.le.nchdefs.and.
     &                         (cfrbbref(ia).ne.cfrbbref(i).or.ia.eq.i))
                    ia=ia+1
                  enddo
                  if (ia.le.nchdefs) then
                     if (Frf(i).lt.Frf(ia)) iul=2 ! IFP LSB channel
                     if (Frf(i).gt.Frf(ia)) iul=1 ! IFP USB channel
                  endif
                endif
                call add_track(itrk(ix),iul,ism,ihdn(ix),ifc,ip)
                kadd_track_map=.true.     
              endif ! matched link
            enddo ! check each fandef 
!            stop
          enddo ! each chan_def line
          nchan(istn,icode)=ifc
!          stop 
C
C    3.2 Save the non-channel specific info for this mode.
C         Recording format, "Mark3", "Mark4", "VLBA".
C         Make these identical for now in VEX files. When there is a
C         mode name available, put that in LMODE. SPEED checks LMFMT
C         to determine DR/NDR. drudg modifies LMFMT from user input
C         for non-VEX.
          cmode(istn,icode)=cm
          cmfmt(istn,icode)=cm

C         Sample rate.
          samprate(istn,icode)=srate ! sample rate

        endif ! chandefs > 0

C       Store data modulation
        cmodulation(istn,icode) = cmodu

C       Store the procedure prefix by station and code.
        if(cpre.eq. " ") then
           cpre="01_"
        endif ! missing
        cprefix(istn,icode)=cpre
        if(kadd_track_map) then
           call add_track_map(istn,icode)
        endif
        enddo ! for one station at a time
      enddo ! get all mode information

      ierr=ierr1

      RETURN
      END
