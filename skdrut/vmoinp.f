      SUBROUTINE VMOINP(ivexnum,LU,IERR)

C     This routine gets all the mode information from the vex file.
C     Call once to get all values in freqs.ftni filled in, then call 
C     SETBA to figure out which frequency bands are there.
C
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
C 020112 nrv Add roll parameters to VUNPROLL call. Add call to CKROLL.
C 020327 nrv Add data modulation paramter to VUNPTRK.
C 021111 jfq Extend S2 mode to support LBA rack

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
C
C  LOCAL:
      integer ix,idum,ib,ic,i,ia,icode,istn
      integer il,im,iret,ierr1,iul,ism,ip,ipc,itone
      integer ipct(max_chan,max_tone),ntones(max_chan)
      integer ifanfac,itrk(max_track),ivc(max_bbc)
      integer irtrk(2+max_track,max_roll_def),iinc,ireinit
      double precision posh(max_index,max_headstack)
      integer ih,ihdn(max_track),indexp(max_index),indexl(max_pass)
      character*1 csubpassl(max_pass),csubpass(max_subpass)
      character*3 cpassl(max_pass)
      double precision bitden_das
      integer nsubpass,npcaldefs,nrdefs,nrsteps
      integer nchdefs,nbbcdefs,nifdefs,nfandefs,nhd,nhdpos,npl
      integer*2 lsb(max_chan),lsg(max_chan),lm(4),lin(max_ifd),
     .ls(max_ifd),ls2m(8),ls2d(4),lpre(4),lp(max_ifd)
      double precision bitden
      character*4 cmodu, croll ! ON or OFF
      character*3 cs(max_chan)
      character*6 cfrbbref(max_chan),cbbcref(max_bbc),
     .cbbifdref(max_chan),cifdref(max_ifd),cfrpcalref(max_chan),
     .cpcalref(max_chan)
      character*6 cchanidref(max_chan),ctrchanref(max_track)
      character*1 cp(max_track),csm(max_track)
      double precision frf(max_chan),flo(max_chan),vbw(max_chan),srate
      double precision fpcal(max_chan),fpcal_base(max_chan)
      character*128 cout
      integer ib2as,numc2,ichmv,ichmv_ch,ichcm_ch ! functions
      integer ptr_ch,fvex_len,fget_mode_def
      logical km3rack,km4rack,kvrack,klrack,km4rec,km3rec,kvrec,ks2rec 
      integer z4000,z100
      DATA Z4000/Z'4000'/,Z100/Z'100'/
 
 
C 1. First get all the mode def names. Station names have already
C    been gotten and saved.
C
      numc2=2+o'40000'+o'400'*2
      ncodes=0
      iret = fget_mode_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        il=fvex_len(cout)
        IF  (ncodes.eq.MAX_FRQ) THEN  !
          write(lu,'("VMOINP01 - Too many modes.  Max is ",
     .    i3,".  Ignored: ",a)') MAX_FRQ,cout(1:il)
        else
          ncodes=ncodes+1
          modedefnames(ncodes)=cout
          if (il.gt.16) then
            write(lu,'("VMOINP02 - Mode name ",a," too long for ",
     .      " matching in sked catalogs. Only the ",
     .      "first 16 characters were kept.")') cout(1:il)
            il=16
          endif
          call char2hol(cout,lmode_cat(1,ncodes),1,il)
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

C    Assign a code to the mode and the same to the name
        idum = ib2as(icode,lcode(icode),1,numc2)
        idum = ichmv_ch(lnafrq(1,icode),1,'        ')
        lnafrq(1,icode) = lcode(icode)

        do istn=1,nstatn ! for one station at a time

          il=fvex_len(modedefnames(icode))
          im=fvex_len(stndefnames(istn))
C         Recognized recorder types
          kvrec=ichcm_ch(lstrec(1,istn),1,'VLBA').eq.0
          km3rec=ichcm_ch(lstrec(1,istn),1,'Mark3').eq.0
          km4rec=ichcm_ch(lstrec(1,istn),1,'Mark4').eq.0
          ks2rec=ichcm_ch(lstrec(1,istn),1,'S2').eq.0
C         Recognized rack types
          klrack=ichcm_ch(lstrack(1,istn),1,'LBA').eq.0
          kvrack=ichcm_ch(lstrack(1,istn),1,'VLBA').eq.0
     .    .or.ichcm_ch(lstrack(1,istn),1,'VLBAG').eq.0
          km3rack=ichcm_ch(lstrack(1,istn),1,'Mark3').eq.0
          km4rack=ichcm_ch(lstrack(1,istn),1,'Mark4').eq.0
C         Initialize roll to blank
          idum = ichmv_ch(lbarrel(1,istn,icode),1,'    ')

C         Get $FREQ statements. If there are no chan_defs for this
C         station, then skip the other sections.
          CALL vunpfrq(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,bitden_das,srate,LSG,Frf,lsb,
     .    cchanidref,VBw,cs,cfrbbref,cfrpcalref,nchdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP02 - Error getting $FREQ information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'FREQ',lu)
            ierr1=1
          endif

C         Get $PROCEDURES statements.
C         (Get other procedure timing info later.)
          call vunpprc(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,lpre)
          if (ierr.ne.0) then
            write(lu,'("VMOINP03 - Error getting $PROCEDURES",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'PROCEDURES',lu)
            ierr1=1
          endif

        nchan(istn,icode) = nchdefs
        if (nchdefs.gt.0) then ! chandefs > 0
C         Get $BBC statements.
          call vunpbbc(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,
     .    cbbcref,ivc,cbbifdref,nbbcdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP04 - Error getting $BBC information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'BBC',lu)
            ierr1=2
          endif

C         Get $IF statements.
          call vunpif(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,
     .    cifdref,flo,ls,LIN,lp,fpcal,fpcal_base,nifdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP05 - Error getting $IF information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'IF',lu)
            ierr1=3
          endif
  
C         Get $TRACKS statements (i.e. fanout).
          if (ks2rec) then
            call vunps2m(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,ls2m,
     .      ls2d,cp,ctrchanref,csm,itrk,nfandefs,ihdn,ifanfac)
          else
            call vunptrk(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,
     .      lm,cp,ctrchanref,csm,itrk,nfandefs,ihdn,ifanfac,cmodu)
          endif
          if (ierr.ne.0) then 
            write(lu,'("VMOINP06 - Error getting $TRACKS information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            if (ks2rec) then
              call errormsg(iret,ierr,'S2_TRACKS',lu)
            else
              call errormsg(iret,ierr,'TRACKS',lu)
            endif
            ierr1=4
          endif

C         Get $HEAD_POS and $PASS_ORDER statements.
          if (ks2rec) then
            call vunps2g(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,cpassl,npl)
          else
            call vunphp(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,
     .      indexp,posh,nhdpos,nhd,cpassl,indexl,csubpassl,npl)
          endif
          if (ierr.ne.0) then 
            write(lu,'("VMOINP07 - Error getting $HEAD_POS and",
     .      "$PASS_ORDER information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            if (ks2rec) then
              call errormsg(iret,ierr,'S2_HEAD_POS',lu)
            else
              call errormsg(iret,ierr,'HEAD_POS',lu)
            endif
            ierr1=5
          endif

C         Get $ROLL statements.
          call vunproll(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,croll,irtrk,iinc,ireinit,nrdefs,nrsteps)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP08 - Error getting $ROLL information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            call errormsg(iret,ierr,'ROLL',lu)
            ierr1=6
          endif

C         Get $PHASE_CAL_DETECT statements.
          call vunppcal(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,cpcalref,ipct,ntones,npcaldefs)
C
C 3. Now decide what to do with this information. If we got to this
C    point there were no reading or content errors for this station/mode
C    combination. Some consistency checks are done here.
C
C    Count subpasses and store subpass names found in the fanout defs.
C    Now IS necessary for S2 recorders.
C         if (ks2rec) then
C         else ! non-S2
            do i=1,max_subpass
              csubpass(i)=' '
            enddo
            nsubpass=0
            do i=1,nfandefs ! each fandef
              ix=1 
              do while (ix.le.nsubpass.and.cp(i)(1:1).ne.
     .                   csubpass(ix))
                ix=ix+1
              enddo
              if (ix.gt.nsubpass) then ! a new one
                if (nsubpass.gt.max_subpass) then
                  write(lu,'("VMOINP15 - Too many subpasses for mode",
     .            a," station ",a,". Max is ",i5,".")') 
     .            modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .            max_subpass
                else
                  nsubpass=nsubpass+1
                  csubpass(nsubpass)=cp(i)(1:1)
                endif
              endif
            enddo ! each fandef
C         endif ! S2/not

C    Save the chan_def info and its links.
          do i=1,nchdefs ! each chan_def line
            invcx(i,istn,icode)=i ! save channel index number 
            LSUBVC(i,istn,ICODE) = LSG(i) ! sub-group, i.e. S or X
            FREQRF(i,istn,ICODE) = Frf(i) ! RF frequency
            lnetsb(i,istn,icode) = lsb(i) ! net sideband
            VCBAND(i,istn,ICODE) = VBw(i) ! video bandwidth
            ifan(istn,icode)=ifanfac ! fanout factor
            cset(i,istn,icode) = cs(i) ! switching 
C           BBC refs
            ib=1
            do while (ib.le.nbbcdefs.and.cbbcref(ib).ne.cfrbbref(i))
              ib=ib+1
            enddo
            if (ib.le.nbbcdefs) then
              ibbcx(i,istn,icode) = ivc(ib) ! BBC number
            else
              write(lu,'("VMOINP09 - BBC link missing for channel ",i3,
     .        " for mode ",a," station ",a)') i,
     .        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            endif
C           IFD refs
            ic=1
            do while (ic.le.nifdefs.and.cbbifdref(ib).ne.cifdref(ic))
              ic=ic+1
            enddo
            if (ic.le.nifdefs) then 
              lifinp(i,istn,icode) = lin(ic) ! IF input channel
              freqlo(i,istn,icode) = flo(ic) ! LO frequency
              freqpcal(i,istn,icode) = fpcal(ic) ! pcal frequency
              freqpcal_base(i,istn,icode) = fpcal_base(ic) ! pcal_base frequency
              losb(i,istn,icode) = ls(ic) ! LO sideband
              lpol(i,istn,icode) = lp(ic) ! polarization
            else
              write(lu,'("VMOINP10 - IFD link missing for channel ",i3,
     .        " for mode ",a," station ",a)') i,
     .        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            endif
C           Phase cal refs
            ipc=1
            do while (ipc.le.npcaldefs.and.cpcalref(ipc).ne.
     .            cfrpcalref(i))
              ipc=ipc+1
            enddo
            if (ipc.le.npcaldefs) then
              do itone=1,ntones(ipc)
                ipctone(itone,i,istn,icode)=ipct(ipc,itone)
                npctone(i,istn,icode)=ntones(ipc)
              enddo
            else
              write(lu,'("VMOINP15 - PCAL link missing for channel ",i3,
     .        " for mode ",a," station ",a)') i,
     .        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            endif
C           Track assignments
            if (km3rec.or.km4rec.or.kvrec.or.ks2rec) then
            do ix=1,nfandefs ! check each fandef
              if (ctrchanref(ix).eq.cchanidref(i)) then ! matched link
                ip=1 ! find subpass index
                do while (ip.le.nsubpass.and.cp(ix).ne.csubpass(ip))
                  ip=ip+1
                enddo
                if (ip.gt.nsubpass) then
                  write(lu,'("VMOINP11 - Subpass not found for "
     .            "chandef ",i3,", fanden ",i3,
     .            " for mode ",a," station ",a)') i,ix,
     .            modedefnames(icode)(1:il),stndefnames(istn)(1:im)
                else
                  ism=1 ! sign
                  if (csm(ix).eq.'m') ism=2 ! magnitude
                  iul=1 ! usb
                  if (ichcm_ch(lnetsb(i,istn,icode),1,'L').eq.0) iul=2 ! lsb
                  if (klrack) then	! allow for U being flipped L etc.
                    ia=1
                    do while (ia.le.nchdefs.and.
     .                        (cfrbbref(ia).ne.cfrbbref(i).or.ia.eq.i))
                      ia=ia+1
                    enddo
                    if (ia.le.nchdefs) then
                       if (Frf(i).lt.Frf(ia)) iul=2 ! IFP LSB channel
                       if (Frf(i).gt.Frf(ia)) iul=1 ! IFP USB channel
                    endif
                  endif
                  itras(iul,ism,ihdn(ix),i,ip,istn,icode)=itrk(ix)-3 
C                                               ! store as Mk3 numbers
                endif
              endif ! matched link
            enddo ! check each fandef
            endif ! m3/4 or v rec
          enddo ! each chan_def line
C
C    3.2 Save the non-channel specific info for this mode.
C         Recording format, "Mark3", "Mark4", "VLBA".
C         Make these identical for now in VEX files. When there is a
C         mode name available, put that in LMODE. SPEED checks LMFMT
C         to determine DR/NDR. drudg modifies LMFMT from user input
C         for non-VEX.
          if (.not.ks2rec) then
            idum = ichmv(LMODE(1,istn,ICODE),1,lm,1,8) ! recording format
            idum = ichmv(LMFMT(1,istn,ICODE),1,lm,1,8) ! recording format
          endif
C         Sample rate.
          samprate(icode)=srate ! sample rate
          if (ks2rec) then
            idum = ichmv(ls2mode(1,istn,icode),1,ls2m,1,16)
            idum = ichmv(ls2data(1,istn,icode),1,ls2d,1,8)
          else ! m3/m4/vrec
C         Set bit density depending on the mode and rack type
            if (ichcm_ch(lmode(1,istn,icode),1,'V').eq.0) then 
              bitden=34020 ! VLBA non-data replacement
            else 
              bitden=33333 ! Mark3/4 data replacement
            endif
C           If "56000" was specified, for this station, use higher bit density
            if (bitden_das.gt.55000.d0) then 
              if (ichcm_ch(lmode(1,istn,icode),1,'V').eq.0) then 
                bitden=56700 ! VLBA non-data replacement
              else 
                bitden=56250 ! Mark3/4 data replacement
              endif
            endif
            if (bitden_das.ne.bitden) then 
              write(lu,'("VMOINP12 - Bit density ",f6.0," for ",a," ",a,
     .        " changed to ",f6.0)') bitden_das,
     .        modedefnames(icode)(1:il),
     .        stndefnames(istn)(1:im),bitden
            endif
            bitdens(istn,icode)=bitden
C       Check number of passes and pass order indices
            if (npl.ne.nhdpos*nsubpass) then
              write(lu,'("VMOINP13 - Inconsistent pass order list")')
            endif
            do ip=1,npl ! number of passes in list
              ix=1
              do while (ix.le.nhdpos.and.indexl(ip).ne.indexp(ix))
                ix=ix+1
              enddo
              if (ix.gt.nhdpos) then
                write(lu,'("VMOINP14 - Index ",i3," in $PASS_ORDER not ",
     .          "found in $HEAD_POS for ",a," ",a)') i,
     .          modedefnames(icode)(1:il),stndefnames(istn)(1:im)
              endif
            enddo  
          endif ! m3/4 or v rec
C    Store head positions and subpases
          do ip=1,npl ! number of passes in list
            cpassorderl(ip,istn,icode) = cpassl(ip)
          enddo
          if (km4rec.or.km3rec.or.kvrec) then
            do ip=1,npl ! number of passes in list
              ix=1 ! find subpass number
              do while (ix.le.nsubpass.and.
     .                  csubpass(ix).ne.csubpassl(ip))
                ix=ix+1
              enddo
              do ih=1,nhd ! store the head offsets
                ihdpos(ih,ip,istn,icode)=posh(indexl(ip),ih)
                ihddir(ih,ip,istn,icode)=ix
              enddo
            enddo  ! number of passes in list
          endif ! m3/4 or v rec
          npassl(istn,icode) = npl
        endif ! chandefs > 0

        if (km4rec.or.km3rec.or.kvrec) then
C         Check barrel roll. croll is either the standard name for
C         the canned mode or "M" to indicate non-standard, or off.
C         The name in the schedule file is not used unless it is "off".
            call ckroll(nrdefs,nrsteps,irtrk,iinc,ireinit,
     .                    istn,icode,croll)
            idum = ichmv_ch(lbarrel(1,istn,icode),1,croll)
        endif

C       Store data modulation
        cmodulation(istn,icode) = cmodu

C       Store the procedure prefix by station and code.
        if (ichcm_ch(lpre,1,'      ').eq.0) then ! missing 
C         Make up the mode name as "01_"
          call ifill(lpre,1,8,oblank)
          idum = ib2as(icode,lpre,1,z4000+2*z100+2)
          idum = ichmv_ch(lpre,3,'_')
        endif ! missing
        idum = ichmv(lprefix(1,istn,icode),1,lpre,1,8)

        enddo ! for one station at a time
      enddo ! get all mode information

      ierr=ierr1

      RETURN
      END
