      program fivpt
C
C   Discrete Source Scan program, scan nominally consists of FIVe PoinTs
C
C   This program utilizes the Field System and is highly dependent on it.
C
C
      integer ftry,rn_take
      real latosv,lonosv,latps1,lonps1,latps2,lonps2,latoff,lonoff
      real latpos,lonpos,ltrchi,lnrchi
      real ltpar,lnpar,ltliof,lnliof
      external fgaus
      logical kbreak,kon,rn_test
C
      dimension tim(31), temp(31), off(31), tmplin(4), timlin(4)
      dimension ltpar(5), eltpar(5), lnpar(5), elnpar(5),it(6)
      integer*2 lbuf(40)
      integer*4 ip(5)
      character*4 caxfp
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
C NOTE: THE FOLLOWING VARIABLES ARE READ FROM THE FSCOM:
C 
C       XOFF, YOFF, AZOFF, ELOFF, RAOFF, DECOFF, DIAMAN
C       LAXFP, CALFP, LDEVFP, NREPFP, FREQFP, INTPFP, STEPFP, ANGLFP
C 
C       ADDITONALLY, CHECK THE CALLED SUBROUTINES 
C 
      data ftry/20/,tol/1e-3/,nwait/120/,lwho/2hfp/
      data nmb/5/,ierr/0/,vfivpt/1.00/,isbuf/80/,ntsys/5/ 
C
      call putpname('fivpt')
      call setup_fscom
      call read_fscom
C
C  GET RID OF ANY BREAKS THAT WERE HANGING AROUND
C
1     continue
      call wait_prog('fivpt',ip)
      ierr=0
      kon=.false.
      if(0.ne.rn_take('fivpt',1)) then
        call logit7ic(idum,idum,idum,-1,-2,lwho,'er')
        goto 1
      endif
      call read_fscom
      if(kbreak('fivpt')) continue
C
C   0. Set-up and do preliminary work
C
C        Beamwidth Calculation
C
      bw = sqrt(bmfp_fs*bmfp_fs+ssizfp*ssizfp)
      nwait=iwtfp
      nmb=intpfp
      ntsys=intpfp
      call hol2char(laxfp,1,4,caxfp)
C
C        Write SOURCE, SITE, ORIGIN, and FIVEPT log entries
C
      call fc_rte_time(it,it(6))
      rut=float(it(4))*3600.+float(it(3))*60.0+float(it(2)) 
      call sorce(rut,it(5),it(6),lbuf,isbuf)  
      call site(vfivpt,lbuf,isbuf)
      call fivp(lbuf,isbuf) 
C 
C        Save old offsets 
C 
      call fs_get_xoff(xoff)
      xosav=xoff
      call fs_get_yoff(yoff)
      yosav=yoff
      call fs_get_azoff(azoff)
      azosav=azoff
      call fs_get_eloff(eloff)
      elosav=eloff
      call fs_get_raoff(raoff)
      haosav=-raoff 
      call fs_get_decoff(decoff)
      dcosav=decoff 
      call reoff(lonosv,latosv,ierr)
      if (ierr.ne.0) goto 80010 
      savln2=lonosv 
      savlt2=latosv 
C 
      call orign(xosav,yosav,azosav,elosav,haosav,dcosav,lbuf,isbuf)
C 
C     WAIT TO ACQUIRE SOURCE
C 
      nwt=nwait 
      if(.not.rn_test('aquir')) nwt=nwait*2
      call onsor(nwt,ierr)
      if (ierr.ne.0) goto 80010 
      kon=.true.
C
C lock gain if a bbc
C
      if(ichcm_ch(ldevfp,1,'u').ne.0) then
         call fs_get_rack(rack)
         call fs_get_rack_type(rack_type)
         if(VLBA.eq.rack.or.VLBA4.eq.rack) then
            call fc_mcbcn_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               ierr=-111
               goto 80010
            endif
         else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
C           do nothing ...
         else if(LBA.eq.rack) then
            call fc_dscon_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
         else if(DBBC.eq.rack) then
            call fc_dbbcn_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               ierr=-111
               goto 80010
            endif
         else if(RDBE.eq.rack.and.RDBE.eq.rack_type) then
            call fc_rdbcn_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
         else if(RDBE.eq.rack.and.R2DBE.eq.rack_type) then
            call fc_r2dbcn_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
         else if(DBBC3.eq.rack) then
            call fc_dbbc3n_d(ldevfp,ierr,ip)
            if(ierr.ne.0) then
               ierr=-81
               goto 80010
            endif
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               ierr=-111
               goto 80010
            endif
         endif
      endif
C 
C   1. Get System Temperature OFF source
C 
      if(nptsfp.gt.0) then
         call offco(5.0*bw,azof,elof,azt,elt,ierr) 
         if (ierr.ne.0) goto 80010 
C     
         call gooff(azosav+azof,elosav+elof,'azel',nwait*2,ierr)
         if (ierr.ne.0) goto 80010
C     
         call tsys(temps,sigts,tpia,tima,vbase,vslope,ntsys,rut,ierr)
         if (ierr.ne.0) goto 80010
C
         call wtsys(temps,sigts,azt,elt,ntsys,lbuf,isbuf)
C
         call gooff(azosav,elosav,'azel',-1,ierr)
         if (ierr.ne.0) goto 80010
      else
         vslope=1.0
         vbase=0.0
         temps=0.0
         sigts=0.0
      endif
C
C    MAIN LOOP
C
      iter=iabs(nrepfp)
10    continue
C
      ilat=0
      ilon=0
C
C  REMEMBER WHERE WE ARE
C 
      call local(lonps1,latps1,caxfp,ierr)
      if (ierr.ne.0) goto 80010 
      coslat=cos(latps1)
C 
C   2.Latitude Scan 
C 
      bstep=stepfp*bw
      steplt=bstep
      start= latosv-float((abs(nptsfp)/2))*bstep
      lonoff=lonosv
C
      if (abs(nptsfp).ge.5) goto 90
C
C  GET FIRST LINEARITY POINT
C
      ltliof=float(3+(abs(nptsfp)/2))*bstep
      call gooff(lonoff,latosv-ltliof,caxfp,nwait*2,ierr)
      if (ierr.ne.0) goto 80010
C
      call volts(0,tpia,sig,tdum,sdum,tima,nmb,rut,ierr,icont)
      if (ierr.ne.0) goto 80010
      tmplin(1)=(tpia-vbase)*vslope-temps
      timlin(1)=tima
      sig=sig*vslope
C
      otoff=latosv-ltliof
      call dpoin('lin',1,timlin(1),otoff,tmplin(1),sig,nmb,lbuf,
     +          isbuf)
90    continue
C
C DO SCAN
C
      do i=1,abs(nptsfp)
        latoff=start+float(i-1)*bstep
        if (i.eq.1.and.abs(nptsfp).gt.3) then
          call gooff(lonoff,latoff,caxfp,nwait*2,ierr)
        else
          call gooff(lonoff,latoff,caxfp,nwait,ierr)
        endif
        if (ierr.ne.0) goto 80010
        call volts(0,tpia,sig,tdum,sdum,tima,intpfp,rut,ierr,icont)
        if (ierr.ne.0) goto 80010
        temp(i)=(tpia-vbase)*vslope-temps
        tim(i)=tima
        sig=sig*vslope
        off(i)=latoff
C
        call dpoin('lat',i,tim(i),off(i),temp(i),sig,intpfp,
     +             lbuf,isbuf)   
      enddo
C 
C   SECOND LINEARITY POINT
C 
      if (abs(nptsfp).ge.5) goto 140 
      call gooff(lonoff,latosv+ltliof,caxfp,nwait,ierr) 
      if (ierr.ne.0) goto 80010 
      call volts(0,tpia,sig,tdum,sdum,tima,nmb,rut,ierr,icont)    
      if (ierr.ne.0) goto 80010 
      tmplin(2)=(tpia-vbase)*vslope-temps 
      timlin(2)=tima
      sig=sig*vslope
      otoff=latosv+ltliof 
      call dpoin('lin',2,timlin(2),otoff,tmplin(2),vslope,nmb, 
     +           lbuf,isbuf)  
C 
C    REMOVE LINEAR DRIFT
C 
      call unslp(tmplin,timlin,temp,tim,abs(nptsfp),slope,const)  
C 
140   continue 
C 
C   3. FIT TO A GAUSSIAN
C 
      tmid=tim((abs(nptsfp)+1)/2) 
      ltpar(5) = (temp(abs(nptsfp))-temp(1))/(tim(abs(nptsfp))-tim(1))
      ltpar(4) = temp(1)+ltpar(5)*(tmid-tim(1)) 
      if (abs(nptsfp).lt.5) ltpar(4)=0.0
      if (abs(nptsfp).lt.5) ltpar(5)=0.0
      eltpar(4)=0.0 
      eltpar(5)=0.0 
C 
      tim(1)=tim(1)-tmid 
      tmax=temp(1)-(ltpar(4)+ltpar(5)*tim(1))
      imax=1 
      do 150 i=2,abs(nptsfp)
        tim(i)=tim(i)-tmid
        ti=temp(i)-(ltpar(4)+ltpar(5)*tim(i)) 
        if (tmax.ge.ti) goto 150  
        tmax=ti 
        imax=i
150   continue
C 
      ltpar(1) = tmax 
      ltpar(2) = off(imax)
      ltpar(3) = bw 
C 
      npar=3
      if (abs(nptsfp).ge.5) npar=5
      call fit2(off,temp,tim,ltpar,eltpar,abs(nptsfp),npar,tol,ftry,
     +     fgaus,ltrchi,ierr)
C 
      if (abs(nptsfp).lt.5) ltpar(4)=const
      if (abs(nptsfp).lt.5) ltpar(5)=slope
C 
      call fitot('latfit',ltpar,ierr,lbuf,isbuf)
      call errot('laterr',eltpar,ltrchi,lbuf,isbuf) 
C 
      if (ltpar(2).gt.off(1).and.ltpar(2).lt.off(abs(nptsfp)).and.    
     + ierr.gt.0 ) ilat=1   
      difflt=abs(ltpar(2)-latosv) 
      if (ilat.eq.1) latosv = ltpar(2)   
      if (nrepfp.lt.0.and.iter.gt.1.and.difflt.gt.bw*.2) ilat=0  
      ierr=0  
C 
C   4. SCAN IN LONGITUDE
C 
      bstep=stepfp*bw/coslat
      stepln=bstep  
      start= lonosv-float((abs(nptsfp)/2))*bstep 
      latoff=latosv 
C 
      if (abs(nptsfp).ge.5) goto 190 
C 
C   GET THIRD LINEARITY POINT 
C 
      lnliof=float(3+(abs(nptsfp)/2))*bstep
      call gooff(lonosv-lnliof,latoff,caxfp,nwait,ierr) 
      if (ierr.ne.0) goto 80010 
      call volts(0,tpia,sig,tdum,sdum,tima,nmb,rut,ierr,icont)    
      if (ierr.ne.0) goto 80010 
      tmplin(3)=(tpia-vbase)*vslope-temps 
      timlin(3)=tima
      sig=sig*vslope
      otoff=lonosv-lnliof 
      call dpoin('lin',3,timlin(3),otoff,tmplin(3),sig,nmb,
     +          lbuf,isbuf) 
190   continue
C 
C  DO SCAN
C 
      do i=1,abs(nptsfp) 
        lonoff=start+float(i-1)*bstep
        if (i.eq.1.and.abs(nptsfp).gt.3) then
          call gooff(lonoff,latoff,caxfp,nwait*2,ierr) 
        else
          call gooff(lonoff,latoff,caxfp,nwait,ierr) 
        endif
        if (ierr.ne.0) goto 80010
        call volts(0,tpia,sig,tdum,sdum,tima,intpfp,rut,ierr,icont)  
        if (ierr.ne.0) goto 80010
        temp(i)=(tpia-vbase)*vslope-temps
        tim(i)=tima
        sig=sig*vslope 
        off(i)=lonoff
C 
        call dpoin('lon',i,tim(i),off(i),temp(i),sig,intpfp,
     +             lbuf,isbuf)   
      enddo
C 
      if (abs(nptsfp).ge.5) goto 240 
C 
C   FOURTH LINEARITY POINT
C 
      call gooff(lonosv+lnliof,latoff,caxfp,nwait,ierr) 
      if (ierr.ne.0) goto 80010 
      call volts(0,tpia,sig,tdum,sdum,tima,nmb,rut,ierr,icont)    
      if (ierr.ne.0) goto 80010 
      tmplin(4)=(tpia-vbase)*vslope-temps 
      timlin(4)=tima
      sig=sig*vslope
      otoff=lonosv+lnliof 
      call dpoin('lin',4,timlin(4),otoff,tmplin(4),sig,nmb,
     +           lbuf,isbuf)  
C 
C    REMOVE LINEAR DRIFT
C 
      call unslp(tmplin(3),timlin(3),temp,tim,abs(nptsfp),slope,const)
C 
240   continue 
C 
C    GET ANOTHER LOCAL COORDINATE POSITON TO AVERAGE WITH THE FIRST 
C 
      call local(lonps2,latps2,caxfp,ierr)
      if (ierr.ne.0) goto 80010 
C 
      if(caxfp.eq.'azel') then
         if(lonps1.gt.1.5*RPI.and.lonps2.lt.0.5*RPI) then
            lonps1=lonps1-DTWOPI
         else if(lonps1.lt.0.5*RPI.and.lonps2.gt.1.5*RPI) then
            lonps1=lonps1+DTWOPI
         endif
      endif
      lonpos=(lonps1+lonps2)*.5
      if(caxfp.eq.'azel') then
         lonpos=mod(lonpos+DTWOPI,DTWOPI)
      endif
      latpos=(latps1+latps2)*.5 
C 
C   5. FIT TO A GAUSSIAN
C 
      tmid=tim((abs(nptsfp)+1)/2) 
      lnpar(5) = (temp(abs(nptsfp))-temp(1))/(tim(abs(nptsfp))-tim(1))
      lnpar(4) = temp(1)+lnpar(5)*(tmid-tim(1)) 
      if (abs(nptsfp).lt.5) lnpar(4)=0.0
      if (abs(nptsfp).lt.5) lnpar(5)=0.0
      elnpar(4)=0.0 
      elnpar(5)=0.0 
C 
      tim(1)=tim(1)-tmid 
      tmax=temp(1)-(lnpar(4)+lnpar(5)*tim(1))
      imax=1 
      do 250 i=2,abs(nptsfp)
        tim(i)=tim(i)-tmid
        ti=temp(i)-(lnpar(4)+lnpar(5)*tim(i)) 
        if (tmax.ge.ti) goto 250  
        tmax=ti 
        imax=i
250   continue
C 
      lnpar(1) = tmax 
      lnpar(2) = off(imax)
      lnpar(3) = bw/coslat
C 
      npar=3
      if (abs(nptsfp).ge.5) npar=5
      call fit2(off,temp,tim,lnpar,elnpar,abs(nptsfp),npar,tol,ftry,
     +     fgaus,lnrchi,ierr)
C 
      if (abs(nptsfp).lt.5) lnpar(4)=const
      if (abs(nptsfp).lt.5) lnpar(5)=slope
C 
C   CORRECT LON PARAMETERS AND ERRORS 
C 
      lnpar(3)=lnpar(3)*coslat
      elnpar(3)=elnpar(3)*coslat
C
      call fitot('lonfit',lnpar,ierr,lbuf,isbuf)
      call errot('lonerr',elnpar,lnrchi,lbuf,isbuf)
C
      if (lnpar(2).gt.off(1).and.lnpar(2).lt.off(abs(nptsfp)).and.
     + ierr.gt.0) ilon=1
      diffln=abs(lnpar(2)-lonosv)
      if (ilon.eq.1)  lonosv = lnpar(2)
      if (nrepfp.lt.0.and.iter.gt.1.and.diffln.gt.bw*.2/coslat) ilon=0
      ierr=0
C
      sefd=0.0
      ae  =0.0
      stoc=0.0
      aedts=0.0
      if (ilat.eq.1.and.ilon.eq.1.and.lnpar(1).gt.1e-6) then
         if(nptsfp.lt.0) then
            stoc=0.0
         else
            stoc=lnpar(1)/calfp
         endif
         if (fxfp_fs.gt.0.0) then
            if(nptsfp.lt.0) temps=lnpar(4)
            sefd=temps*(fxfp_fs/lnpar(1))
            call fs_get_diaman(diaman)
            ae=lnpar(1)*2.0*1.380662e0/
     &           (fxfp_fs*1e-3*DPI*(diaman/2.0)**2)
            aedts=1000.*ae/temps
         endif
      endif
      call prfot(stoc,sefd,ae,aedts,lbuf,isbuf)
C
C    LOOP BACK FOR MORE REPITIONS
C
      iter=iter-1
      if ((nrepfp.gt.0.and.iter.gt.0).or.
     +  (nrepfp.lt.0.and.iter.gt.0.and.(ilon.eq.0.or.ilat.eq.0))) then
        call offot(lonpos,latpos,lonosv,latosv,ilon,ilat,lbuf,isbuf)
        goto 10
      endif
      if (ilat.eq.1) savlt2=latosv
      if (ilon.eq.1) savln2=lonosv
      call gooff(savln2,savlt2,caxfp,nwait*2,ierr)
      call offot(lonpos,latpos,lonosv,latosv,ilon,ilat,lbuf,isbuf)
      call xoffot(lonpos,latpos,lonosv,latosv,ilon,ilat,
     &     elnpar(2),eltpar(2),lbuf,isbuf)
      if (ierr.ne.0) call logit7ic(idum,idum,idum,-1,ierr,lwho,'er')
      goto 90000
C
C   ERROR
C
80010 continue
      xoff=xosav
      call fs_set_xoff(xoff)
      yoff=yosav
      call fs_set_yoff(yoff)
      azoff=azosav
      call fs_set_azoff(azoff)
      eloff=elosav
      call fs_set_eloff(eloff)
      raoff=-haosav
      call fs_set_raoff(raoff)
      decoff=dcosav
      call fs_set_decoff(decoff)
      itry=2
C
80011 continue
      jerr=0
      if(.NOT.kon) goto 80015
      call gooff(lonosv,latosv,caxfp,nwait,jerr)
      itry=itry-1
      if (jerr.gt.0.and.itry.gt.0) goto 80011
C
80015 continue
      if (ierr.gt.0) goto 89990
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'er')
      if (jerr.ne.0) call logit7ic(idum,idum,idum,-1,-100,lwho,'er')
      goto 90000
C
C BREAK DETECTED
C
89990 continue
      ierr=-1
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'br')
      if (jerr.ne.0) call logit7ic(idum,idum,idum,-1,-100,lwho,'er')
      goto 90000
C
C CLEAN UP AND EXIT
C
90000 continue
      if(ichcm_ch(ldevfp,1,'u').ne.0) then
         if(VLBA.eq.rack.or.VLBA4.eq.rack) then
            call fc_mcbcn_r(ip)
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               call logit7ic(idum,idum,idum,-1,-112,lwho,'er')
            endif
         else if(DBBC.eq.rack) then
            call fc_dbbcn_r(ip)
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               call logit7ic(idum,idum,idum,-1,-112,lwho,'er')
            endif
         else if(DBBC3.eq.rack) then
            call fc_dbbc3n_r(ip)
            if(ip(3).lt.0) then
               call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
               call logit7ic(idum,idum,idum,-1,-112,lwho,'er')
            endif
         endif
      endif
      call rn_put('fivpt')
      goto 1
      end
