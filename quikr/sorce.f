      subroutine sorce(ip)
C
C     Set and display the source name
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      integer*4 ip(5)
      integer it(6),iparm(2),get_buf,ichcm_ch,itb(6)
      integer*2 ibuf(40),ibufi(18),ibufo( 8),ls(5),lds,lhs,cwp(4)
      double precision rad,decd,alati,elong,gheig,ra,dec
C      - double precision versions of ra and dec for MOVE
      logical kd,kprec,ksun,kmoon      
C      - true if we have azel or xy degrees specified 
C      - true if we precess these coordinates
C      - true if Sun
C      - true if Moon
      character*1 cjchar
C
      equivalence (iparm(1),parm)
C
C  TO MOON BUFFER 24 WORDS
C
      equivalence (ibufi(1),alati),
     +            (ibufi(5),elong),
     +            (ibufi(9),gheig),
     +            (ibufi(13),itb)
C
C  FROM MOON BUFFER 8 WORDS
C
      equivalence (ibufo(1),ra),
     +            (ibufo(5),dec)
C
      data ilen/80/
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      nchar = get_buf(iclcm,ibuf,-ilen,idum,idum)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C 
C     2. Parse the command: SOURCE=<name>,<ra>,<dec>,<epoch>
C 
C     2.1 First get the source name 
C 
      ich = ieq+1 
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_lsorna(lsorna)
        idumm1 = ichmv(ls,1,lsorna,1,10)     !  pick up the name from common
      else if (cjchar(parm,1).eq.',') then
        ierr = -101               !  there is no default for the source name
        goto 990
      else
        idumm1 = ichmv_ch(ls,1,'          ')
        idumm1 = ichmv(ls,1,ibuf,ic1,min0(10,ich-ic1-1))
      endif
C                   First clear the temporary name buffer then move 
C                   in the name from the command
      iaz = ichcm_ch(ls,1,'azel      ')
      ixy = ichcm_ch(ls,1,'xy        ')
      iazunc = ichcm_ch(ls,1,'azeluncr  ')
      kd = iaz*ixy*iazunc.eq.0
      ksun = ichcm_ch(ls,1,'sun       ').eq.0
      kmoon = ichcm_ch(ls,1,'moon      ').eq.0 
      if (ksun) goto 320
      if (kmoon) goto 340 
      if(ichcm_ch(ls,1,'stow      ').eq.0 .or.
     &   ichcm_ch(ls,1,'service   ').eq.0 .or.
     &   ichcm_ch(ls,1,'disable   ').eq.0 .or.
     &   ichcm_ch(ls,1,'idle      ').eq.0 .or.
     &   ichcm_ch(ls,1,'hold      ').eq.0 ) then
        ra = ra50
        dec = dec50
        ep = ep1950
        kd = .true.
        call gtfld(ibuf,ich,nchar,ic1,ic2)
        if (ic1.ne.0) then
          ierr = -305
          go to 990
        endif
        goto 300
      endif
       
C 
C     2.2 Next get the RA and convert to radians
C 
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_ra50(ra50)
        ra = ra50                  !  pick up the ra from common
      else if (cjchar(parm,1).eq.',') then
        ierr = -102                 !  there is no default for the ra
        goto 990
      else
        if (.not.kd) call gtradd(ibuf,ic1,ich-2,1,ra,ierr)
C                      First convert assuming we have RA
        if (kd) call gtradd(ibuf,ic1,ich-2,4,ra,ierr)
C                      If we've got AZEL or XY, convert degrees 
        if (ierr.lt.0) then
          ierr = -202
          goto 990
        endif
      endif
C 
C     2.3 Next the DEC. 
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_dec50(dec50)
        dec = dec50                 !  pick up the dec from common
      else if (cjchar(parm,1).eq.',') then
        ierr = -103                 !  there is no default for the dec
        goto 990
      else
        if (.not.kd) call gtradd(ibuf,ic1,ich-2,2,dec,ierr)
        if (kd) call gtradd(ibuf,ic1,ich-2,4,dec,ierr)
        if (ierr.lt.0) then
          ierr = -203
          goto 990
        endif
      endif
C 
C     2.4 Finally the epoch.
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_ep1950(ep1950)
        ep = ep1950
      else if (cjchar(parm,1).eq.','.and.kd) then
        ep = -1
      else if (cjchar(parm,1).eq.',') then
        ep = 1950.0              !  the default is 1950 for positions
      else
        ep = das2b(ibuf,ic1,ich-ic1-1,ierr)
        if (ierr.ne.0) then
          ierr = -204
          goto 990
        endif
      endif
C
C     2.5 The cable wrap
C
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_cwrap(cwrap)
        idumm1 = ichmv(cwp,1,cwrap,1,8)     !  pick up the name from common
      else if (cjchar(parm,1).eq.',') then
        idumm1 = ichmv_ch(cwp,1,'        ')
      else
        idumm1 = ichmv_ch(cwp,1,'        ')
        idumm1 = ichmv(cwp,1,ibuf,ic1,min0(8,ich-ic1-1))
      endif
C 
C     3. Precess the positions to today's date from the epoch 
C     given as input.  Store the variables away in COMMON.
C 
 300  continue
      idumm1 = ichmv(lsorna,1,ls,1,10)
      call fs_set_lsorna(lsorna)
      idumm1 = ichmv(cwrap,1,cwp,1,8)
      call fs_set_cwrap(cwrap)
C                   Make sure the proper dates are in common
      rad = ra
      decd = dec
C                   Pick out today's day-of-year for precession 
      call fc_rte_time(it,it(6))
      kprec = (ep.gt.0.0) .and. .not.(kd.or.ksun.or.kmoon)         
      if(kprec) then
         call fs_get_wlong(wlong)
         call fs_get_alat(alat)
         call fs_get_height(height)
         call move2t(it,wlong,alat,dble(height),
     &        rad,decd,ep,radat,decdat)
      endif
C 
      ra50 = ra 
      call fs_set_ra50(ra50)
      dec50 = dec 
      call fs_set_dec50(dec50)
      call fs_set_radat(radat)
      call fs_set_decdat(decdat)
      idinyr = 365
      if(mod(it(6),400).eq.0 .or. 
     +   (mod(it(6),4).eq.0.and.mod(it(6),100).ne.0)) idinyr=366
      epoch = it(6) + it(5)/float(idinyr) 
      call fs_set_epoch(epoch)
      ep1950 = ep 
      if (ep.le.0.0 .or. ksun .or. kmoon) ep1950=epoch
      call fs_set_ep1950(ep1950)
c  
      flx1fx_fs = -2.0
      flx2fx_fs = -2.0
      flx3fx_fs = -2.0
      flx4fx_fs = -2.0
C                   Call again to fix up az and el
      ierr = 0
      goto 400
C 
C  Handle SUN position here.
C 
320   continue
      call gtfld(ibuf,ich,nchar,ic1,ic2)
      if (ic1.ne.0) then
        ierr = -303
        go to 990
      endif
      call fc_rte_time(it,it(6))
      call sunpo(ra,dec,it) 
      idumm1 = ichmv_ch(cwp,1,'        ')
      radat = ra
      decdat = dec
      go to 300 
C
C  Handle MOON position here.
C
340   continue
      call gtfld(ibuf,ich,nchar,ic1,ic2)
      if (ic1.ne.0) then
        ierr = -304
        go to 990
      endif
      call fs_get_alat(alat)
      call fs_get_wlong(wlong)
      alati = alat
      elong = -wlong
      call fs_get_height(height)
      gheig = height
      call fc_rte_time(it,it(6))
      do i=1,6
        itb(i)=it(i)
      enddo
      ip(1)=0
      call put_buf(ip,ibufi,-48,'  ','  ')
      call run_prog('moon ','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
      call rmpar(ip)
      nwords=get_buf(ip(1),ibufo,-16,irtn1,irtn2)
      radat = ra
      decdat = dec
      idumm1 = ichmv_ch(cwp,1,'        ')
C
390   continue
      go to 300 
C 
C     4. Now schedule ANTCN.  Tell it to do source pointing.
C 
400   continue
      call write_quikr
      call fs_get_idevant(idevant)
      if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
        call run_prog('antcn','wait',1,idum,idum,idum,idum)
        call rmpar(ip)
      else
        ierr= -306
      endif
C 
      ionsor = 0
      call fs_set_ionsor(ionsor)
C 
      if(ierr.eq.0) return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qs',ip(4),1,2)
      return
C 
C     5. Return the source name for display 
C 
500   nch = ichmv_ch(ibuf,nchar+1,'/')
      call fs_get_lsorna(lsorna)
      if (ichcm_ch(lsorna,1,'          ').eq.0) goto 530 
      nch = ichmv(ibuf,nch,lsorna,1,10) 
      iaz = ichcm_ch(lsorna,1,'azel      ')
      iazun = ichcm_ch(lsorna,1,'azeluncr  ')
      ixy = ichcm_ch(lsorna,1,'xy        ')
      kd = (iaz.eq.0 .or. ixy.eq.0 .or. iazun.eq.0)
      n = iscn_ch(ibuf,1,nch-1,' ') 
      if (n.ne.0) nch=n 
      if(ichcm_ch(ls,1,'stow      ').eq.0 .or.
     &   ichcm_ch(ls,1,'service   ').eq.0 .or.
     &   ichcm_ch(ls,1,'disable   ').eq.0 .or.
     &   ichcm_ch(ls,1,'idle      ').eq.0 .or.
     &   ichcm_ch(ls,1,'hold      ').eq.0 ) then
        goto 530
      endif
C                   Adjust next char to be first blank in source name.
      nch = mcoma(ibuf,nch) 
      call fs_get_ra50(ra50)
      call fs_get_dec50(dec50)
      call fs_get_radat(radat)
      call fs_get_decdat(decdat)
      call fs_get_epoch(epoch)
      if (kd) then
        nch = nch + ir2as(sngl(ra50*180.0/RPI),ibuf,nch,7,2)
        nch = mcoma(ibuf,nch)
        nch = nch + ir2as(sngl(dec50*180.0/RPI),ibuf,nch,7,2)
        nch = mcoma(ibuf,nch)
        nch = mcoma(ibuf,nch)
      else
        call radec(ra50,dec50,0.0,irah,iram,ras,
     .     lds,idcd,idcm,dcs,lhs,i,i,d) 
        nch=nch+ib2as(irah,ibuf,nch,o'40000'+o'400'*2+2)
        nch=nch+ib2as(iram,ibuf,nch,o'40000'+o'400'*2+2)
        nch = nch + ir2as(ras,ibuf,nch,-6,-3)
        nch = mcoma(ibuf,nch)
        if (dec50.lt.0.0) nch=ichmv_ch(ibuf,nch,'-')
        nch=nch+ib2as(idcd,ibuf,nch,o'40000'+o'400'*2+2)
        nch=nch+ib2as(idcm,ibuf,nch,o'40000'+o'400'*2+2)
        nch = nch + ir2as(dcs,ibuf,nch,-5,-2)
        nch = mcoma(ibuf,nch)
        call fs_get_ep1950(ep1950)
        nch = nch + ir2as(ep1950,ibuf,nch,9,4)
        nch = mcoma(ibuf,nch)
      endif
      call fs_get_cwrap(cwrap)
      if(ichcm_ch(cwrap,1,'        ').ne.0) then
         ilc=iflch(cwrap,8)
         nch=ichmv(ibuf,nch,cwrap,1,ilc)
      endif
      nch = mcoma(ibuf,nch)
      write(6,*) 'kd ',kd, ' nch ', nch
      if(.not.kd) then
         call radec(radat,decdat,0.0,irah,iram,ras,
     .        lds,idcd,idcm,dcs,lhs,i,i,d) 
         nch=nch+ib2as(irah,ibuf,nch,o'40000'+o'400'*2+2)
         nch=nch+ib2as(iram,ibuf,nch,o'40000'+o'400'*2+2)
         nch = nch + ir2as(ras,ibuf,nch,-6,-3)
         nch = mcoma(ibuf,nch)
         if (decdat.lt.0.0) nch=ichmv_ch(ibuf,nch,'-')
         nch=nch+ib2as(idcd,ibuf,nch,o'40000'+o'400'*2+2)
         nch=nch+ib2as(idcm,ibuf,nch,o'40000'+o'400'*2+2)
         nch = nch + ir2as(dcs,ibuf,nch,-5,-2)
         nch = mcoma(ibuf,nch)
         nch = nch + ir2as(epoch,ibuf,nch,8,3)
      write(6,*) 'kd ',kd, ' nch ', nch
      endif
530   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qs',ip(4),1,2)
      return
      end 
