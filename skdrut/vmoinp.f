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
C          vunpfrq
C          vunpbbc
C          vunpif
C          vunptrk
C          vunphead
C
C  LOCAL:
      integer ix,idum,ib,ic,i,icode,istn
      integer il,im,iret,ierr1,iul,ism,ip
      integer ifanfac,itrk(max_pass),ivc(max_bbc)
      double precision pos1(max_index),pos2(max_index)
      integer ihd(max_pass),indexp(max_index),indexl(max_pass)
      character*1 csubpassl(max_pass),csubpass(max_subpass)
      character*3 cpassl(max_pass)
      double precision bitden_das
      integer nsubpass
      integer nchdefs,nbbcdefs,nifdefs,nfandefs,nhdpos,npl
      integer*2 lsb(max_chan),lsg(max_chan),lm(4),lin(max_ifd),
     .ls(max_ifd),ls2m(8)
      double precision bitden
      character*3 cs(max_chan)
      character*6 cfrbbref(max_chan),cbbcref(max_bbc),
     .cbbifdref(max_chan),cifdref(max_ifd)
      character*6 cchanidref(max_chan),ctrchanref(max_pass)
      character*1 cp(max_pass),csm(max_pass)
      double precision frf(max_chan),flo(max_chan),vbw(max_chan),srate
      character*128 cout
      integer ib2as,numc2,ichmv,ichmv_ch,ichcm_ch ! functions
      integer ptr_ch,fvex_len,fget_mode_def
      logical km3rack,km4rack,kvrack,km4rec,km3rec,kvrec,ks2rec 
 
 
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
        END IF 
        iret = fget_mode_def(ptr_ch(cout),len(cout),0) ! get next one
      enddo

C 1.5 Now initialize arrays using nstatn and ncodes.

      call frinit(nstatn,ncodes)

C 2. Call routines to retrieve and store all the mode/station 
C    information, one mode/station at a time.

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
          kvrack=ichcm_ch(lstrack(1,istn),1,'VLBA').eq.0
     .    .or.ichcm_ch(lstrack(1,istn),1,'VLBAG').eq.0
          km3rack=ichcm_ch(lstrack(1,istn),1,'Mark3').eq.0
          km4rack=ichcm_ch(lstrack(1,istn),1,'Mark4').eq.0
C         Initialize roll to unknown
          idum = ichmv_ch(lbarrel(1,istn,icode),1,'<un>')

C         Get $FREQ statements.
          CALL vunpfrq(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,bitden_das,
     .    srate,LSG,Frf,lsb,cchanidref,VBw,cs,cfrbbref,nchdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP02 - Error getting $FREQ information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            ierr1=1
          endif

C         Get $BBC statements.
          call vunpbbc(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,
     .    cbbcref,ivc,cbbifdref,nbbcdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP03 - Error getting $BBC information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            ierr1=2
          endif

C         Get $IF statements.
          call vunpif(modedefnames(icode),stndefnames(istn),
     .    ivexnum,iret,ierr,lu,
     .    cifdref,flo,ls,LIN,nifdefs)
          if (ierr.ne.0) then 
            write(lu,'("VMOINP04 - Error getting $IF information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            ierr1=3
          endif
  
C         Get $TRACKS statements (i.e. fanout).
          if (ks2rec) then
            call vunps2m(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,ls2m,lm)
            ifanfac=0
          else
            call vunptrk(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,
     .      lm,cp,ctrchanref,csm,itrk,nfandefs,ihd,ifanfac)
          endif
          if (ierr.ne.0) then 
            write(lu,'("VMOINP05 - Error getting $TRACKS information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            ierr1=4
          endif

C         Get $HEAD_POS and $PASS_ORDER statements.
          if (ks2rec) then
            call vunps2g(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,cpassl,npl)
          else
            call vunphp(modedefnames(icode),stndefnames(istn),
     .      ivexnum,iret,ierr,lu,
     .      indexp,pos1,pos2,nhdpos,cpassl,indexl,csubpassl,npl)
          endif
          if (ierr.ne.0) then 
            write(lu,'("VMOINP06 - Error getting $HEAD_POS and",
     .      "$PASS_ORDER information",
     .      " for mode ",a," station ",a/" iret=",i5," ierr=",i5)') 
     .      modedefnames(icode)(1:il),stndefnames(istn)(1:im),
     .      iret,ierr
            ierr1=5
          endif
C
C 3. Now decide what to do with this information. If we got to this
C    point there were no reading or content errors for this station/mode
C    combination. Some consistency checks are done here.
C
C    Count subpasses and store subpass names found in the fanout defs.
C    Not necessary for S2 recorders.
          if (ks2rec) then
          else
            do i=1,max_subpass
              csubpass(i)=' '
            enddo
            nsubpass=0
            do i=1,nfandefs ! go through them all
              ix=1 
              do while (ix.le.nsubpass.and.cp(i)(1:1).ne.
     .                   csubpass(ix))
                ix=ix+1
              enddo
              if (ix.gt.nsubpass) then ! a new one
                nsubpass=nsubpass+1
                csubpass(nsubpass)=cp(i)(1:1)
              endif
            enddo
          endif

C    Save the chan_def info and its links.
          if (km3rack.or.km4rack.or.kvrack) then
          nchan(istn,icode) = nchdefs
          do i=1,nchdefs ! each chan_def line
            invcx(i,istn,icode)=i ! save channel index number 
            LSUBVC(i,istn,ICODE) = LSG(i) ! sub-group, i.e. S or X
            FREQRF(i,istn,ICODE) = Frf(i) ! RF frequency
            lnetsb(i,istn,icode) = lsb(i) ! net sideband
            VCBAND(i,istn,ICODE) = VBw(i) ! video bandwidth
            ifan(istn,icode)=ifanfac ! fanout factor
            cset(i,istn,icode) = cs(i) ! switching 
            ib=1
            do while (ib.le.nbbcdefs.and.cbbcref(ib).ne.cfrbbref(i))
              ib=ib+1
            enddo
            if (ib.le.nbbcdefs) then
              ibbcx(i,istn,icode) = ivc(ib) ! BBC number
            else
              write(lu,'("VMOINPxx - BBC link missing for channel ",i3,
     .        " for mode ",a," station ",a)') i,
     .        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            endif
            ic=1
            do while (ic.le.nifdefs.and.cbbifdref(i).ne.cifdref(ic))
              ic=ic+1
            enddo
            if (ic.le.nifdefs) then 
              lifinp(i,istn,icode) = lin(ic) ! IF input channel
              freqlo(i,istn,icode) = flo(ic) ! LO frequency
              losb(i,istn,icode) = ls(ic)
            else
              write(lu,'("VMOINPxx - IFD link missing for channel ",i3,
     .        " for mode ",a," station ",a)') i,
     .        modedefnames(icode)(1:il),stndefnames(istn)(1:im)
            endif
C          Track assignments
            if (km3rec.or.km4rec.or.kvrec) then
            do ix=1,nfandefs ! check each fandef
              if (ctrchanref(ix).eq.cchanidref(i)) then ! matched link
                ip=1 ! find subpass index
                do while (ip.le.nsubpass.and.cp(ix).ne.csubpass(ip))
                  ip=ip+1
                enddo
                if (ip.gt.nsubpass) then
                  write(lu,'("VMOINPxx - Subpass not found for "
     .            "channel ",i3,
     .            " for mode ",a," station ",a)') i,
     .            modedefnames(icode)(1:il),stndefnames(istn)(1:im)
                else
                  ism=1 ! sign
                  if (csm(ix).eq.'m') ism=2 ! magnitude
                  iul=1 ! usb
                  if (ichcm_ch(lsubvc(i,istn,icode),1,'L').eq.0) iul=2 ! lsb
                  if (ihd(ix).eq.1) 
     .            itras(iul,ism,i,ip,istn,icode)=itrk(ix)-3 ! store as Mk3 numbers
                  if (ihd(ix).eq.2) 
     .            itra2(iul,ism,i,ip,istn,icode)=itrk(ix)-3 ! store as Mk3 numbers
                endif
              endif ! matched link
            enddo ! check each fandef
            endif ! m3/4 or v rec
          enddo ! each chan_def line
          endif ! m3/4 or v rack
C
C    3.2 Save the non-channel specific info.
C         Recording format, "Mark3", "Mark4", "VLBA"
          idum = ichmv(LMODE(1,istn,ICODE),1,lm,1,8) ! recording format
          samprate(icode)=srate ! sample rate
          if (ks2rec) then
            idum = ichmv(ls2mode(1,istn,icode),1,ls2m,1,16)
          else
C           Set bit density depending on the mode
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
              write(lu,'("VMOINPxx - Bit density ",f6.0," for ",a," ",a,
     .        " changed to ",f6.0)') bitden_das,
     .        modedefnames(icode)(1:il),
     .        stndefnames(istn)(1:im),bitden
            endif
            bitdens(istn,icode)=bitden
C       Check number of passes and pass order indices
            if (npl.ne.nhdpos*nsubpass) then
              write(lu,'("VMOINPxx - Inconsistent pass order list")')
            endif
            do ip=1,npl
              ix=1
              do while (ix.le.nhdpos.and.indexl(ip).ne.indexp(ix))
                ix=ix+1
              enddo
              if (ix.gt.nhdpos) then
                write(lu,'("VMOINPxx - Index ",i3," in $PASS_ORDER not ",
     .          "found in $HEAD_POS for ",a," ",a)') i,
     .          modedefnames(icode)(1:il),stndefnames(istn)(1:im)
              endif
            enddo  
          endif ! m3/4 or v rec
C    Store head positions and subpases
          do ip=1,npl
            cpassorderl(ip,istn) = cpassl(ip)
          enddo
          if (km4rec.or.km3rec.or.kvrec) then
            do ip=1,npl
              ix=1 ! find subpass number
              do while (ix.le.nsubpass.and.
     .                  csubpass(ix).ne.csubpassl(ip))
                ix=ix+1
              enddo
              ihdpos(ip,istn,icode)=pos1(indexl(ip))
              ihddir(ip,istn,icode)=ix
              ihdpo2(ip,istn,icode)=pos2(indexl(ip))
              ihddi2(ip,istn,icode)=ix
            enddo 
          endif ! m3/4 or v rec
          npassl = npl

        enddo ! for one station at a time
      enddo ! get all mode information

      ierr=ierr1

      RETURN
      END
