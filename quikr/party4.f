      subroutine party4(ip)
C  CHECK PARITY & SYNC ERRORS FOR MARK IV RECORDER
C
C  HISTORY:
C  WHO  WHEN    DESCRIPTION
C  gag  920805  Created, copied from party
C
C   IDECPA_FS IS IN COMMON AND HOLDS THE CHANNELS FOR DECODER AS SUPPLIED
C             BY THE USER
C       0 = AB    default
C       1 = A
C       2 = B
C
      include '../include/fscom.i'

c     logical kbit,keven,kodd,kready
      logical kbreak,kdoaux
      integer*4 ip(1)
      integer*2 ibuf(50)
      real perr(36)
      integer ireg(2),iparm(2),get_buf,ichcm_ch,idecpa,iserr(36)
      integer iaux(36),iptr(2),itrkmez(2),itrkpalo(2)
      integer itrk4(36), itrk(2)
      character cjchar
      equivalence (parm,iparm(1))
      data ilen/100/
      data pth/600./,sth/12./
C
C  Set flag for PCALR to stop
      ipcflg=1
      call fs_get_drive(drive)
      call fs_get_icheck(icheck(18),18)
      ichold=icheck(18)
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
C  2. GET PARAMETERS.
C
C  2.1  PARITY ERROR THRESHHOLD
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
      do i=1,36
         itrk4(i)=0
      end do
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.'*') then
         do i=1,36
            itrk4(i)=itrkpar4(i)
         end do
      else
         do j=1,36
            if (ichcm_ch(parm,1,'all').eq.0) then
               do i=2,33
                  itrk4(i+1)=1
               end do
            else if(ichcm_ch(parm,1,'g').eq.0
     &              .or.ichcm_ch(parm,1,'m').eq.0
     &              .or.ichcm_ch(parm,1,'v').eq.0) then
               if(ichcm_ch(parm,1,'g').eq.0) then
                  istart=0
               else if(ichcm_ch(parm,1,'m').eq.0) then
                  istart=4
               else if(ichcm_ch(parm,1,'v').eq.0) then
                  istart=2
               else
                  ierr=-208
                  goto 990
               endif
               if(ichcm_ch(parm,2,'0').eq.0) then
                  iend=16
               else if(ichcm_ch(parm,2,'1').eq.0) then
                  istart=istart+1
                  iend=17
               else if(ichcm_ch(parm,2,'2').eq.0) then
                  if(istart.eq.0) then
                     iend=34
                  else if(istart.eq.4) then
                     iend=30
                  else if (istart.eq.2) then
                     iend=32 
                  endif
                  istart=18
               else if(ichcm_ch(parm,2,'3').eq.0) then
                  if(istart.eq.0) then
                     iend=35
                  else if(istart.eq.4) then
                     iend=31
                  else if (istart.eq.2) then
                     iend=33 
                  endif
                  istart=19
               else
                  ierr=-208
                  goto 990
               endif
               do i=istart,iend,2
                  itrk4(i+1)=1
               enddo
            else
               nc=1
               if(cjchar(iparm,2).ne.' ') nc=2
               it=ias2b(iparm,1,nc)
               if (it.ge.0.and.it.le.35) then
                  itrk4(it+1)=1
               else
                  ierr = -208
                  goto 990
               endif
            endif
            call gtprm(ibuf,ich,nchar,0,parm,ierr)
            if(cjchar(parm,1).eq.',') goto 295
         enddo
      endif
  
295   continue
      ierr=0
C
C
C  3. Plant values in COMMON
C
      pethr=peth
      isethr=iseth
      idecpa_fs=idecpa
      kdoaux_fs=kdoaux
      do i=1,36
        itrkpar4(i)=itrk4(i)
      end do
      goto 990
C
C  5.  Measure errors
C
500   continue
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      itrkpalo(1)=0
      itrkpalo(2)=0
      ntrk = 0
      do i=1,36
        perr(i)=0
        iserr(i)=0
        itrk4(i)=itrkpar4(i)
        if (itrk4(i).eq.1) ntrk = ntrk+1
      end do
      if (ntrk.eq.0) then
        ierr = -306
        goto 990
      endif
c
c this uses an indirect indexing scheme. iptr array contains nptr valid
c indexes for the itrk array, if channel A, iptr(1)=1 and nptr=1
c                             if channel B, iptr(1)=2 and nptr=1
c             if channel A and B, iptr(1)=1, iptr(2)=2  and nptr=2
c the array itrk is filled nptr tracks at a time, and then we measure (mezhr)
c
      if(idecpa_fs.eq.0) then     !both decoder channels
        iptr(1)=1
        iptr(2)=2
        nptr=2
      else
        iptr(1)=idecpa_fs         !one decode channel
        nptr=1
      endif
      i=0
      ilast=0
      do while (i.lt.36)   !loop over tracks
        j=0
        itrk(1)=0          ! set decode tracks for channels a and b
        itrk(2)=0
        do while (j.lt.nptr.and.i.lt.36)
          i=i+1
          if (itrk4(i).eq.1) then
            j=j+1
            itrk(iptr(j))=i
          endif
        enddo
        if (j.eq.0) goto 600
        itrkmez(1)=itrk(1)
        itrkmez(2)=itrk(2)
        call mezhr(avpea,avpeb,iserra,iserrb,ip,iauxa,iauxb,itrkmez)
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
C IF BREAK IS REQUESTED, GO AHEAD AND REPORT WHAT'S ALREADY DONE
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
      nch=ichmv_ch(ibuf,nch,'/')
      do i=1,36
        if (itrk4(i).eq.1) then
          if(i.le.ilast) then        !only report as far as we got
            nc=ib2as(i-1,lwhat,1,2)     !report actual
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
        if (itrk4(i).eq.1) then
          if(i.le.ilast) then            !report only as far as we got
            if (iserr(i).gt.isethr) then
              nc=ib2as(i-1,lwhat,1,2)       !report actual track
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
700   continue
      iclass=0
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
        if (itrkpar4(i).eq.1) then
          nch=nch+ib2as(i-1,ibuf,nch,o'100002')
          nch=mcoma(ibuf,nch)
          ntrk=ntrk+1
        endif
        if (nch.gt.68) then
          call put_buf(iclass,ibuf,2-nch,'fs','  ')
          nch = 1
          nch = ichmv_ch(ibuf,nchar,'parity/')
          nchsave=nch
          nrec = nrec + 1
        endif
      enddo
      if(ntrk.eq.0) nch=ichmv_ch(ibuf,nch,'none ')
      nch=nch-2
      if(nch.ne.nchsave-2) then
         call put_buf(iclass,ibuf,-nch,'fs','  ')
         nrec=nrec+1
      endif
C
C
C  That's all
C
990   call char2hol('qg',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      ip(3)=ierr
      ip(5)=0
998   ipcflg=0
      icheck(18)=ichold
      call fs_set_icheck(icheck(18),18)
      return
      end
