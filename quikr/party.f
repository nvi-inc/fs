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

      logical kbit,kone,kother,kbreak,kdoaux
      integer*4 ip(1)
      integer*2 ibuf(128), lwhat
      real perr(36)
      integer ireg(2),iparm(2),get_buf,ichcm_ch,idecpa,iserr(36)
      integer itrk(36),iaux(36),iptr(2),ig1(4),igv1(4)
      integer igv2(4),igv3(4)
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/256/
      data ig1/0,1,14,15/
      data igv1/0,1,18,19/
      data igv2/2,3,18,19/
      data igv3/4,5,18,19/
      data pth/600./,sth/12./
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      call fs_get_rack(rack)
      if(MK3.eq.drive.or.MK4.eq.drive) then
        call fs_get_icheck(icheck(18),18)
        ichold=icheck(18)
      else                      !!! VLBA or VLBA4
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
      if (cjchar(iparm,1).eq.',') then
        peth=pth
      else if (cjchar(iparm,1).eq.'*') then
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
      if (cjchar(iparm,1).eq.',') then
        iseth=sth
      else if (cjchar(iparm,1).eq.'*') then
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
      if (cjchar(iparm,1).eq.',') then
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
      if (rack.eq.VLBA) then
         kdoaux=.false.
      else if (cjchar(parm,1).eq.',') then
        kdoaux=.true.
      else if (ichcm_ch(iparm,1,'on').eq.0) then
        kdoaux=.true.
      else if (ichcm_ch(iparm,1,'off').eq.0) then
        kdoaux=.false.
      else
        ierr = -204
        goto 990
      end if
C
C  2.5  List of tracks
C
C
      do i=1,36
        itrk(i)=0
      end do
C
      itype=rpro_fs
      call fs_get_wrhd_fs(wrhd_fs)
      if(MK3.eq.drive) then
         if(MK3B.eq.drive_type) itype=wrhd_fs
      else if(VLBA.eq.drive) then
         itype=wrhd_fs
      endif
      if (itype.lt.0.or.itype.gt.2) then !out of range reproduce value
         ierr = -308
         goto 990
      end if
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(iparm,1).eq.',') then
         if(MK3.eq.drive) then
            do i=1,28
               itrk(3+i)=itrkenus_fs(i)
            end do
         else if(MK4.eq.drive) then
            if(MK3.ne.rack) then
               do i=2,33
                  itrk(1+i)=1
               enddo
            else
               call fs_set_kenastk(kenastk)
               if(kenastk(1)) then
                  do i=2,32,2
                     itrk(1+i)=1
                  enddo
               endif
               if(kenastk(2)) then
                  do i=3,33,2
                     itrk(1+i)=1
                  enddo
               endif
            endif
         else if(VLBA.eq.drive.or.VLBA4.eq.drive) then
            call fs_get_vgroup(vgroup)
            do i=2,33
               if(vgroup(1+2*(i/18)+mod(i,2)).eq.1) itrk(i+1)=1
            enddo
         endif
         if(MK4.eq.rack.or.VLBA4.eq.rack) then
C mk4 rack
            call fs_get_fm4enable(fm4enable)
            do i=2,33
               if(.not.kbit(fm4enable,i-1)) then
                  itrk(1+i)=0
               endif
            enddo
         else if(VLBA.eq.rack) then
            call fs_get_vfmenablehi(vfmenablehi)
            call fs_get_vfmenablelo(vfmenablelo)
            do i=0,15
               if(.not.kbit(vfmenablehi,i+1)) then
                  itrk(1+(i+1)*2)=0
               endif
               if(.not.kbit(vfmenablelo,i+1))then
                  itrk(1+(i+1)*2+1)=0
               endif
            enddo
         endif
         if(MK3.eq.drive) then
            do i=1,28
               itrk(i)=itrk(3+i)
            enddo
            do i=29,36
               itrk(i)=0
            enddo
         endif
      else                      ! decode track number
         do i=1,36
            if(index('0123456789',cjchar(iparm,1)).ne.0) then
               goto 255
            else if (cjchar(iparm,1).eq.'*') then
               ierr = -310
               goto 990
            else if (drive.eq.MK3.and.cjchar(iparm,1).ne.'g') then
               ierr = -205
               goto 990
            else if (drive.ne.MK3.and.
     &              index('gvm', cjchar(iparm,1)).eq.0)then
               ierr = -215
               goto 990
            end if
            ig=ias2b(iparm,2,1)
            if(drive.eq.MK3.and.(ig.lt.1.or.ig.gt.4)) then
               ierr = -206
               goto 990
            else if((drive.ne.MK3).and.
     &              (ig.lt.0.or.ig.gt.3)) then
               ierr = -216
               goto 990
            end if
            if(drive.eq.MK3) then
               do j=1,14,2
                  itrk(j+ig1(ig))=1
               end do
            else if(cjchar(iparm,1).eq.'g') then
               do j=0,17,2
                  itrk(1+j+igv1(ig+1))=1
               enddo
            else if(cjchar(iparm,1).eq.'v') then
               do j=0,15,2
                  itrk(1+j+igv2(ig+1))=1
               enddo
            else                !mX
               do j=0,13,2
                  itrk(1+j+igv3(ig+1))=1
               enddo
            endif
            goto 270
 255        nc=1
            if(cjchar(iparm,2).ne.' ') nc=2
            it=ias2b(iparm,1,nc)
            if(drive.eq.MK3.and.(it.lt.1.or.it.gt.28)) then
               ierr = -207
               goto 990
            else if(drive.ne.MK3.and.(it.lt.0.or.it.gt.35)) then
               ierr = -217
               goto 990
            end if
            if(drive.eq.MK3) then
               itrk(it)=1
            else
               itrk(it+1)=1
            endif
 270        call gtprm(ibuf,ich,nchar,0,parm,ierr)
            if(cjchar(iparm,1).eq.',') goto 295
         end do
 295     continue
         ierr=0
c     
c check odd/even-ness
c
         kone=.false.
         kother=.false.
         do i=1,36
            if (itrk(i).eq.1) then
               if (mod(i,2).eq.0) kone=.true.
               if (mod(i,2).eq.1) kother=.true.
            end if
         end do
C     
C if only one side repro than we can have odd or even but not both
C
         if ((itype.eq.1.or.itype.eq.2).and.kone.and.kother) then
            ierr = -309
            goto 990
         end if
      endif
C
C what kind of head do we have
C
      if(itype.ne.0) then
         if(drive.eq.MK3) then
            do i=1,28,2
               if(itrk(i).ne.0.or.itrk(i+1).ne.0) then
                  if(itype.eq.1) then
                     itrk(i)=1
                     itrk(i+1)=0
                  else
                     itrk(i)=0
                     itrk(i+1)=1
                  endif
               endif
            end do
         else
            do i=2,33,2
               if(itrk(1+i).ne.0.or.itrk(1+i+1).ne.0) then
                  if(itype.eq.2) then
                     itrk(1+i)=1
                     itrk(1+i+1)=0
                  else if(itype.eq.1) then
                     itrk(1+i)=0
                     itrk(1+i+1)=1
                  endif
               endif
            end do
         endif
      endif
C     
C  3. Plant values in COMMON
C
      pethr=peth
      isethr=iseth
      idecpa_fs=idecpa
      kdoaux_fs=kdoaux
      do i=1,36
         if(itrk(i).eq.1) call sbit(itrkpa,i,1)
         if(itrk(i).eq.0) call sbit(itrkpa,i,0)
      end do
      goto 990
C
C  5.  Measure errors
C
500   continue
C
      call fs_get_vacsw(vacsw)
      call fs_get_vac4(vac4)
      if(vacsw.eq.1.and.(vac4.lt.0.or.vac4.gt.2)) then
         ierr=-311
         goto 990
      endif
C     
      if(MK3.eq.drive.or.Mk4.eq.drive) then
         icheck(18) = 0
         call fs_set_icheck(icheck(18),18)
      else                      !!! VLBA and VLBA4
         ichvlba(18)=0
         call fs_set_ichvlba(ichvlba(18),18)
      endif
c     
      call fs_get_vrepromode(vrepromode)
c
      do i=1,36
         if(kbit(itrkpa,i))goto 501
      end do
      ierr=-306                 ! no tracks selected: error
      goto 990
c
 501  do i=1,36
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
      ilast=-1
      do while (i.lt.36)   !loop over tracks
         j=0
         itrk(1)=0              ! set decode tracks for channels a and b
         itrk(2)=0
         do while (j.lt.nptr.and.i.lt.36)
            i=i+1
            if(kbit(itrkpa,i)) then
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
         ilast=max(itrk(1),itrk(2),ilast) !remember last sampled track
         if(kbreak('quikr')) goto 600
C     If BREAK is requested, go ahead and report what's already done
      end do
C
C  6.  Set up response
C
 600  continue
C
C  Parity errors first
C
      iclass=0
      nrec=0
      nch=nchar+1
      nch=ichmv_ch(ibuf,nch,'/')
      do i=1,36
         if (kbit(itrkpa,i)) then
            if(i.le.ilast) then !only report as far as we got
               iv=i
               if(drive.ne.MK3) iv=iv-1
               nc=ib2as(iv,lwhat,1,2) !report actual, not requested track
               if (perr(i).gt.pethr) then
                  call logit7ci(0,0,0,0,-303,'qg',lwhat)
               end if
               if (iaux(i).ne.0) then
                  call logit7ci(0,0,0,0,-305,'qg',lwhat)
               end if
               nch=nch+ir2as(perr(i),ibuf,nch,5,0)
               nch=mcoma(ibuf,nch)
               if (nch.ge.95) then
                  nch=nch-2
                  call put_buf(iclass,ibuf,-nch,'fs','  ')
                  nrec=nrec+1
                  nch=nchar+2
               end if
            end if
         end if
      end do
C
      if (nch.ne.1) then
        nch=nch-2
        call put_buf(iclass,ibuf,-nch,'fs','  ')
        nrec=nrec+1
      end if
C
C  Now sync errors
C
      nch=ichmv_ch(ibuf,1,'parity/')
      do i=1,36
         if (kbit(itrkpa,i)) then
            iv=i
            if(drive.ne.MK3) iv=iv-1
            if(i.le.ilast) then !report only as far as we got
               if (iserr(iv).gt.isethr) then
                  nc=ib2as(iv,lwhat,1,2) !report actual, not requested
                  call logit7ci(0,0,0,0,-304,'qg',lwhat)
               end if
               nch=nch+ib2as(iserr(i),ibuf,nch,o'100003')
               nch=mcoma(ibuf,nch)
               if (nch.ge.95) then
                  nch=nch-2
                  call put_buf(iclass,ibuf,-nch,'fs','  ')
                  nrec=nrec+1
                  nch=nchar+2
               end if
            endif
         end if
      end do
  
      if (nch.ne.1) then
        nch=nch-2
        call put_buf(iclass,ibuf,-nch,'fs','  ')
        nrec=nrec+1
      end if
      goto 990
C
C  7.  Display settable parameters
C
700   iclass=0
      nch=nchar-1
      nch=ichmv_ch(ibuf,nch,'/')
      nch=nch+ib2as(int(pethr),ibuf,nch,o'100005')
      nch=mcoma(ibuf,nch)
      nch=nch+ib2as(isethr,ibuf,nch,o'100003')
      nch=mcoma(ibuf,nch)
      if (idecpa_fs.eq.0) then
        nch= ichmv_ch(ibuf,nch,'ab')
      else if (idecpa_fs.eq.1) then
        nch= ichmv_ch(ibuf,nch,'a')
      else if (idecpa_fs.eq.2) then
        nch= ichmv_ch(ibuf,nch,'b')
      end if
      nch=mcoma(ibuf,nch)
      if (kdoaux_fs) then
        nch= ichmv_ch(ibuf,nch,'on')
      else
        nch= ichmv_ch(ibuf,nch,'off')
      endif
      nch=mcoma(ibuf,nch)
      ntrk=0
      do i=1,36
         if (kbit(itrkpa,i)) then
            iv=i
            if(drive.ne.MK3) iv=iv-1
            nch=nch+ib2as(iv,ibuf,nch,o'100002')
            nch=mcoma(ibuf,nch)
            ntrk=ntrk+1
         end if
      end do
      if(ntrk.eq.0) nch=ichmv_ch(ibuf,nch,'none ')
      nch=nch-2
      call put_buf(iclass,ibuf,-nch,'fs','  ')
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
C
998   continue
      if(MK3.eq.drive.or.MK4.eq.drive) then
        icheck(18)=ichold
        call fs_set_icheck(icheck(18),18)
      else  !!! VLBA or VLBA4
        ichvlba(18)=ichold
        call fs_set_ichvlba(ichvlba(18),18)
      endif
C
      return
      end
