      subroutine sorce(ip)
C
C     Set and display the source name
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      integer*4 ip(5)
      integer it(6),iparm(2),get_buf,ichcm_ch,itb(6)
      integer*2 ibuf(40),ibufi(18),ibufo( 8),ls(5),lds,lhs
      double precision rad,decd,alati,elong,gheig
C      - double precision versions of ra and dec for MOVE
      double precision dra,ddec,dc
C      - returned by MOVE: changes in ra and dec to be added
C        to the old values
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
      equivalence (ibufo(1),rad),
     +            (ibufo(5),decd)
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
        idumm1 = ichmv(ls,1,10h          ,1,10)
        idumm1 = ichmv(ls,1,ibuf,ic1,min0(10,ich-ic1-1))
      endif
C                   First clear the temporary name buffer then move 
C                   in the name from the command
      iaz = ichcm_ch(ls,1,'azel      ')
      ixy = ichcm_ch(ls,1,'xy        ')
      istow = ichcm_ch(ls,1,'stow      ')
      iserv = ichcm_ch(ls,1,'service   ')
      iazunc = ichcm_ch(ls,1,'azeluncr  ')
      kd = iaz*ixy*istow*iserv*iazunc.eq.0
      ksun = ichcm_ch(ls,1,'sun       ').eq.0
      kmoon = ichcm_ch(ls,1,'moon      ').eq.0 
      if (ksun) goto 320
      if (kmoon) goto 340 
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
        if (.not.kd) call gtrad(ibuf,ic1,ich-2,1,ra,ierr)
C                      First convert assuming we have RA
        if (kd) call gtrad(ibuf,ic1,ich-2,4,ra,ierr)
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
        if (.not.kd) call gtrad(ibuf,ic1,ich-2,2,dec,ierr)
        if (kd) call gtrad(ibuf,ic1,ich-2,4,dec,ierr)
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
C     3. Precess the positions to today's date from the epoch 
C     given as input.  Store the variables away in COMMON.
C 
300   idumm1 = ichmv(lsorna,1,ls,1,10)
      call fs_set_lsorna(lsorna)
C                   Make sure the proper dates are in common
      rad = ra
      decd = dec
C                   Stuff into double precision variables 
      dra = 0 
      ddec = 0
C                   Pick out today's day-of-year for precession 
      call fc_rte_time(it,it(6))
      kprec = (ep.gt.0.0) .and. .not.(kd.or.ksun.or.kmoon)         
      if(kprec) call move(ifix(ep),it(6),1,it(5),rad,decd,dra,ddec,dc)
C 
      ra50 = ra 
      call fs_set_ra50(ra50)
      dec50 = dec 
      call fs_set_dec50(dec50)
      radat = ra + dra
      call fs_set_radat(radat)
      decdat = dec + ddec 
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
      call sun(rad,decd,it) 
      ra = rad
      dec = decd
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
      call put_buf(ip,ibufi,-48,0,0)
      call run_prog('moon ','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
      call rmpar(ip)
      nwords=get_buf(ip(1),ibufo,-16,rtn1,rtn2)
      ra = rad
      dec = decd
C
390   continue
      go to 300 
C 
C     4. Now schedule ANTCN.  Tell it to do source pointing.
C 
400   continue
      call write_quikr
      call run_prog('antcn','wait',1,idum,idum,idum,idum)
      call rmpar(ip)
C 
      ionsor = 0
      call fs_set_ionsor(ionsor)
C 
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qs',ip(4),1,2)
      return
C 
C     5. Return the source name for display 
C 
500   nch = ichmv(ibuf,nchar+1,2h/ ,1,1)
      call fs_get_lsorna(lsorna)
      if (ichcm(lsorna,1,10h          ,1,10).eq.0) goto 530 
      nch = ichmv(ibuf,nch,lsorna,1,10) 
      iaz = ichcm_ch(lsorna,1,'azel      ')
      ixy = ichcm_ch(lsorna,1,'xy        ')
      kd = (iaz.eq.0 .or. ixy.eq.0)
      n = iscn_ch(ibuf,1,nch-1,' ') 
      if (n.ne.0) nch=n 
C                   Adjust next char to be first blank in source name.
      nch = mcoma(ibuf,nch) 
      call fs_get_ra50(ra50)
      call fs_get_dec50(dec50)
      call fs_get_radat(radat)
      call fs_get_decdat(decdat)
      call fs_get_epoch(epoch)
      if (kd) then
        nch = nch + ir2as(ra50*180.0/RPI,ibuf,nch,7,2)
        nch = mcoma(ibuf,nch)
        nch = nch + ir2as(dec50*180.0/RPI,ibuf,nch,7,2)
      else
        call radec(ra50,dec50,0.0,irah,iram,ras,
     .     lds,idcd,idcm,dcs,lhs,i,i,d) 
        is=ras*10
        ras=is/10.0
        nch = nch + ir2as(irah*10000.0+iram*100.0+ras,ibuf,nch,8,1)
        nch = mcoma(ibuf,nch)
C       if (ichcm_ch(lds,1,'-').eq.0) nch = ichmv(ibuf,nch,lds,1,1)
        if (dec50.lt.0.0) nch=ichmv(ibuf,nch,2h- ,1,1)
        is=dcs
        dcs=is
        nch = nch + ir2as(idcd*10000.0+idcm*100.0+dcs,ibuf,nch,7,0)
        nch = mcoma(ibuf,nch)
        call fs_get_ep1950(ep1950)
        nch = nch + ir2as(ep1950,ibuf,nch,6,1)
        nch = mcoma(ibuf,nch)
        call radec(radat,decdat,0.0,irah,iram,ras,
     .     lds,idcd,idcm,dcs,lhs,i,i,d) 
        is=ras*10
        ras=is/10.0
        nch = nch + ir2as(irah*10000.0+iram*100.0+ras,ibuf,nch,8,1)
        nch = mcoma(ibuf,nch)
C       if (ichcm_ch(lds,1,'-').eq.0) nch = ichmv(ibuf,nch,lds,1,1)
        if (decdat.lt.0.0) nch=ichmv(ibuf,nch,2h- ,1,1)
        is=dcs*10
        dcs=is/10.0
        nch = nch + ir2as(idcd*10000.0+idcm*100.0+dcs,ibuf,nch,7,0)
        nch = mcoma(ibuf,nch)
        nch = nch + ir2as(epoch,ibuf,nch,6,1)
      endif
530   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qs',ip(4),1,2)
      return
      end 
