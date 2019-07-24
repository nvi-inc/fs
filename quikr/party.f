      subroutine party(ip)
C  check parity & sync errors c#870115:04:38#
C
C  HISTORY:
C  WHO  WHEN    DESCRIPTION
C  GAG  910124  Added reproduce electronics logic to setting ITRAKA and
C               ITRAKB
C
C   IDECPA_FS IS IN COMMON AND HOLDS THE CHANNELS FOR DECODER AS SUPPLIED
C             BY THE USER
C       0 = AB    default
C       1 = A
C       2 = B
C
      include '../include/fscom.i'

      logical kbit,keven,kodd,kready,kbreak,kdoaux
      integer*4 ip(1)
      integer*2 ibuf(50)
      real perr(28)
      integer ireg(2),iparm(2),get_buf,ichcm_ch,idecpa,iserr(28)
      integer itrk(28),iaux(28),iptr(2),ig1(4),itrkpalo(2)
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/100/
      data ig1/0,1,14,15/
      data pth/600./,sth/12./
C
C  Set flag for PCALR to stop
      ipcflg=1
      call fs_get_rack(rack)
      call fs_get_drive(drive)
      if(MK3.eq.iand(drive,MK3)) then
        call fs_get_icheck(icheck(18),18)
        ichold=icheck(18)
      else !!! VLBA
        call fs_get_ichvlba(ichvlba(18),18)
        ichold=ichvlba(18)
      endif
C
C  1.  Get the command
C
      iclass=0
      nrec=0
      iclcm=ip(1)
      if (iclcm.eq.0) then
        ierr=-302
        goto 990
      end if
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar=min0(ilen,ireg(2))
      ieq=iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(4)=o'77'
        goto 700
      end if
C
C  2. Get parameters.
C
C  2.1  Parity error threshhold
C
      ich=ieq+1
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        peth=pth
      else if (cjchar(parm,1).eq.'*') then
        peth=pethr
      else if(ierr.ne.0) then
        ierr=-201
        goto 990
      else
        peth=iparm(1)
      end if
C
C  2.2  Sync error threshhold
C
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        iseth=sth
      else if (cjchar(parm,1).eq.'*') then
        iseth=isethr
      else if(ierr.ne.0) then
        ierr=-202
        goto 990
      else
        iseth=iparm(1)
      end if
C
C  2.3  Channel(s)
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        idecpa = 0
      else if((cjchar(iparm,1).eq.'a').and.(cjchar(iparm,2).eq.'b'))
     .    then
        idecpa = 0
      else if (cjchar(iparm,1).eq.'a') then
        idecpa = 1
      else if (cjchar(iparm,1).eq.'b') then
        idecpa = 2
      else if (cjchar(parm,1).eq.'*') then
        idecpa=idecpa_fs
      else
        ierr = -203
        goto 990
      end if
C
C  2.4 AUX check ON or OFF
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kdoaux=.true.
      else if (ichcm_ch(parm,1,'on').eq.0) then
        kdoaux=.true.
      else if (ichcm_ch(parm,1,'off').eq.0) then
        kdoaux=.false.
      else
        ierr = -204
        goto 990
      end if
C
C  2.5  List of tracks
C
C
      do i=1,28
        itrk(i)=0
      end do
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        if(MK3.eq.iand(drive,MK3)) then
          do i=1,28
            itrk(i)=itrkenus_fs(i)
          end do
        else
          call fs_get_vgroup(vgroup)
          do i=1,28
            if(vgroup(2*((i+13)/14)-mod(i,2)).eq.1) itrk(i)=1
          enddo
        endif
      else
        do i=1,28
          if(cjchar(iparm,1).ge.'0'.and.cjchar(iparm,1).le.'9') 
     .      goto 255
          if (cjchar(iparm,1).eq.'*') then
            ierr = -310
            goto 990
          end if
          if (cjchar(iparm,1).ne.'g') then
            ierr = -205
            goto 990
          end if
          ig=ias2b(iparm,2,1)
          if(ig.lt.1.or.ig.gt.4) then
            ierr = -206
            goto 990
          end if
          do j=1,14,2
            itrk(j+ig1(ig))=1
          end do
          goto 270
255       nc=1
          if(cjchar(iparm,2).ne.' ') nc=2
          it=ias2b(iparm,1,nc)
          if(it.le.0.or.it.gt.28) then
            ierr = -207
            goto 990
          end if
          itrk(it)=1
270       call gtprm(ibuf,ich,nchar,0,parm,ierr)
          if(cjchar(parm,1).eq.',') goto 295
        end do
      end if
  
295   ierr=0
C
C
C  3. Plant values in COMMON
C
      pethr=peth
      isethr=iseth
      idecpa_fs=idecpa
      kdoaux_fs=kdoaux
      do i=1,28
        if(itrk(i).eq.1) call sbit(itrkpa,i,1)
        if(itrk(i).eq.0) call sbit(itrkpa,i,0)
      end do
      goto 990
C
C  5.  Measure errors
C
500   continue
      if(MK3.eq.iand(drive,MK3)) then
        icheck(18) = 0
        call fs_set_icheck(icheck(18),18)
      else !!! VLBA
        ichvlba(18)=0
        call fs_set_ichvlba(ichvlba(18),18)
      endif
      itrkpalo(1)=0
      itrkpalo(2)=0
      if (rpro_fs.lt.0.or.rpro_fs.gt.2) then  !out of range reproduce value
         ierr = -308
         goto 990
      end if
      if(ibypas.eq.0) then      !if not in bypas check which tracks we need
        keven=.false.
        kodd=.false.
        do i=1,28
          if (itrk(i).eq.1) then
            if (mod(i,2).eq.0) keven=.true.
            if (mod(i,2).eq.1) kodd=.true.
          end if
        end do
C
C if only one side repro than we can have odd or even but bu not both
C
        if ((rpro_fs.eq.1.or.rpro_fs.eq.2).and.keven.and.kodd) then
          ierr = -309
          goto 990
        end if
      endif
      do i=1,28
        if (kbit(itrkpa,i)) then
c pick which tracks to actually reproduce according to rep. electronics type
          iv=i                         ! okay as is
          if (rpro_fs.eq.2.and.ibypas.eq.0) then      !map to even
            if (mod(iv,2).eq.1) iv = iv + 1
          else if (rpro_fs.eq.1.and.ibypas.eq.0) then !map to odd
            if (mod(iv,2).eq.0) iv = iv - 1
          end if
          call sbit(itrkpalo,iv,1)
        end if
      end do
      do i=1,28
        if(kbit(itrkpalo,i))goto 501
      end do
        ierr=-306              ! no tracks selected: error
        goto 990
501   do i=1,28
        perr(i)=0
        iserr(i)=0
      end do
c
c this uses an indirect indexing scheme. iptr array contains nptr valid
c indexes for the itrk array, if channel A, iptr(1)=1 and nptr=1
c                             if channel B, iptr(1)=2 and nptr=1
c             if channel A and B, iptr(1)=1, iptr(2)=2  and nptr=2
c the array itrk is filled nptr tracks at a time, and then we measure (mezhr)
c
      if(idecpa_fs.eq.0) then   !both decoder channels
        iptr(1)=1
        iptr(2)=2
        nptr=2
      else
        iptr(1)=idecpa_fs       !one decode channel
        nptr=1
      endif
      i=0
      ilast=0
      do while (i.lt.28)   !loop over tracks
        j=0
        itrk(1)=0          ! set decode tracks for channels a and b
        itrk(2)=0
        do while (j.lt.nptr.and.i.lt.28)
          i=i+1
          if(kbit(itrkpalo,i)) then
            j=j+1
            itrk(iptr(j))=i
          endif
        enddo
        if(j.eq.0) goto 600
        call mezhr(avpea,avpeb,iserra,iserrb,ip,iauxa,iauxb,itrk)
        if(ip(3).lt.0) goto 998
        if(itrk(1).ne.0) then
          perr(itrk(1))=avpea
          iserr(itrk(1))=iserra
          iaux(itrk(1))=iauxa
        endif
        if(itrk(2).ne.0) then
          perr(itrk(2))=avpeb
          iserr(itrk(2))=iserrb
          iaux(itrk(2))=iauxb
        endif
        ilast=max(itrk(1),itrk(2),ilast)  !remember last sampled track
        if(kbreak('quikr')) goto 600
C            If BREAK is requested, go ahead and report what's already done
      end do
C
C  6.  Set up response
C
600   continue
C
C  Parity errors first
C
      iclass=0
      nrec=0
      nch=nchar+1
      nch=ichmv(ibuf,nch,2h/ ,1,1)
      do i=1,28
        if (kbit(itrkpa,i)) then
          iv=i                   !again map to reproduce track
          if (rpro_fs.eq.2.and.ibypas.eq.0) then         !even
            if (mod(iv,2).eq.1) iv = iv + 1
          else if (rpro_fs.eq.1.and.ibypas.eq.0) then    !odd
            if (mod(iv,2).eq.0) iv = iv - 1
          end if
          if(iv.le.ilast) then        !only report as far as we got
            nc=ib2as(i,lwhat,1,2)     !report requested, not actual track
            if (perr(iv).gt.pethr) then
              call logit7(0,0,0,0,-303,2hqg,lwhat)
            end if
            if (iaux(iv).ne.0) then
              call logit7(0,0,0,0,-305,2hqg,lwhat)
            end if
            nch=nch+ir2as(perr(iv),ibuf,nch,5,0)
            nch=mcoma(ibuf,nch)
            if (nch.ge.95) then
              nch=nch-2
              call put_buf(iclass,ibuf,-nch,2hfs,0)
              nrec=nrec+1
              nch=nchar+2
            end if
          end if
        end if
      end do
C
      if (nch.ne.1) then
        nch=nch-2
        call put_buf(iclass,ibuf,-nch,2hfs,0)
        nrec=nrec+1
      end if
C
C  Now sync errors
C
      nch=ichmv(ibuf,1,7hparity/,1,7)
      do i=1,28
        if (kbit(itrkpa,i)) then
          iv=i
          if (rpro_fs.eq.2.and.ibypas.eq.0) then         !even
            if (mod(iv,2).eq.1) iv = iv + 1
          else if (rpro_fs.eq.1.and.ibypas.eq.0) then    !odd
            if (mod(iv,2).eq.0) iv = iv - 1
          end if
          if(iv.le.ilast) then            !report only as far as we got
            if (iserr(iv).gt.isethr) then
              nc=ib2as(i,lwhat,1,2)        !report requested, not actual track
              call logit7(0,0,0,0,-304,2hqg,lwhat)
            end if
            nch=nch+ib2as(iserr(iv),ibuf,nch,o'100003')
            nch=mcoma(ibuf,nch)
            if (nch.ge.95) then
              nch=nch-2
              call put_buf(iclass,ibuf,-nch,2hfs,0)
              nrec=nrec+1
              nch=nchar+2
            end if
          endif
        end if
      end do
  
      if (nch.ne.1) then
        nch=nch-2
        call put_buf(iclass,ibuf,-nch,2hfs,0)
        nrec=nrec+1
      end if
      goto 990
C
C  7.  Display settable parameters
C
700   iclass=0
      nch=nchar-1
      nch=ichmv(ibuf,nch,2h/ ,1,1)
      nch=nch+ib2as(int(pethr),ibuf,nch,o'100005')
      nch=mcoma(ibuf,nch)
      nch=nch+ib2as(isethr,ibuf,nch,o'100003')
      nch=mcoma(ibuf,nch)
      if (idecpa_fs.eq.0) then
        nch= ichmv(ibuf,nch,2hab,1,2)
      else if (idecpa_fs.eq.1) then
        nch= ichmv(ibuf,nch,2ha ,1,1)
      else if (idecpa_fs.eq.2) then
        nch= ichmv(ibuf,nch,2hb ,1,1)
      end if
      nch=mcoma(ibuf,nch)
      if (kdoaux_fs) then
        nch= ichmv(ibuf,nch,2hon,1,2)
      else
        nch= ichmv(ibuf,nch,3hoff,1,3)
      endif
      nch=mcoma(ibuf,nch)
      ntrk=0
      do i=1,28
        if (kbit(itrkpa,i)) then
          nch=nch+ib2as(i,ibuf,nch,o'100002')
          nch=mcoma(ibuf,nch)
          ntrk=ntrk+1
        end if
      end do
      if(ntrk.eq.0) nch=ichmv(ibuf,nch,5hnone ,1,5)
      nch=nch-2
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      nrec=1
C
C
C  That's all
C
990   continue
      call char2hol('qg',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      ip(3)=ierr
      ip(5)=0
998   ipcflg=0
      if(MK3.eq.iand(drive,MK3)) then
        icheck(18)=ichold
        call fs_set_icheck(icheck(18),18)
      else  !!! VLBA
        ichvlba(18)=ichold
        call fs_set_ichvlba(ichvlba(18),18)
      endif
C
      return
      end
