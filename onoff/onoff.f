      program onoff
C 
C   SOURCE RADIOMETERY PROGRAM
C 
C This program utilizes the Field System and is highly dependent on it. 
C 
C 
      double precision avg1,avg2,sig1,sig2,dtemp1,dtemp2,dri,dim1 
      double precision drdrm1,tsyav1,tsyav2,tsysi1,tsysi2 
      logical rn_test,kbreak,kon
      integer rn_take
      integer*4 ip(5)
      integer*2 lbuf(40)
      integer*2 lwho,i10blnks(5)
      dimension it(6)
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C NOTE: THE FOLLOWING VARIABLES ARE READ FROM THE FSCOM:
C 
C       XOFF, YOFF, AZOFF, ELOFF, RAOFF, DECOFF,
C       DIAMAN, 
C       NREPNF, INTPNF, LDV1NF, LDV2NF, FRQ1NF, FRQ2NF, CTOFNF
C       CAL1NF, CAL2NF
C 
C       ADDITONALLY, CHECK THE CALLED SUBROUTINES 
C 
      dimension vons(2),vofs(2),vcal(2),sigons(2),sigofs(2),sigcal(2) 
      dimension vzer(2),sigzer(2) 
C 
      data nwait/120/,lwho/2Hnf/ 
      data ierr/0/,vonoff/1.00/,isbuf/80/ 
C
C  GET RID OF ANY BREAKS THAT WERE HANGING AROUND
C
      call char2hol(' ',i10blnks,1,10)
      call putpname('onoff')
      call setup_fscom
      call read_fscom
C
C  GET RID OF ANY BREAKS THAT WERE HANGING AROUND
C
1     continue
      call wait_prog('onoff',ip)
      ierr=0
      kon=.false.
      if(0.ne.rn_take('onoff',1)) then
        call logit7ic(idum,idum,idum,-2,ierr,lwho,'er')
        goto 1
      endif
      call read_quikr
2     continue
      if(kbreak('onoff')) goto 2
C
C   0. Set-up and do preliminary work
C
C        Beamwidth Calculation
C
      bw1 = bm1nf_fs
      bw2 = bm2nf_fs
      bw= amax1(bw1,bw2)
      isgn=1
C
C
C        Write SOURCE, SITE, and ONOFF log entries
C 
      call fc_rte_time(it,it(6))
      rut=float(it(4))*3600.+float(it(3))*60.0+float(it(2)) 
      call sorce(rut,it(5),it(6),lbuf,isbuf)
      call site(vonoff,lbuf,isbuf)
      call onof(lbuf,isbuf) 
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
C 
      call orign(xosav,yosav,azosav,elosav,haosav,dcosav,lbuf,isbuf)
C 
      nwt=nwait 
      if(rn_test('aquir')) nwt=300
      call onsor(nwt,ierr)
      if(ierr.ne.0) goto 80010 
      kon=.true.
c
c lock the bbcs we are using to MAN gain mode
c
      call fs_get_rack(rack)
      if(VLBA.eq.and(rack,VLBA)) then
        call fc_mcbcn_d2(ldv1nf,ldv2nf,ierr,ip)
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
C 
C MAKE SURE THE CAL IS OFF
C 
      if(cal1nf.gt.0.0.or.cal2nf.gt.0.0) then
         call scmds('caloffnf',1)  
      endif
C 
C  REMEMBER WHERE WE ARE
C 
      call local(az,el,'azel',ierr) 
      if(ierr.ne.0) goto 80010 
      cosel=cos(el) 
C 
C 
C    MAIN LOOP
C 
      avg1=0
      avg2=0
      sig1=0
      sig2=0
      tsyav1=0
      tsyav2=0
      tsysi1=0
      tsysi2=0
      do 10 i=1,nrepnf
C 
C   2.ON SOURCE POINT 
C 
      call vlts2(vons,sigons,tmons,intpnf,rut,ierr) 
      if(ierr.ne.0) goto 80010 
      call dpnt2('on  ',i,tmons,0.0,0.0,vons,sigons,intpnf,lbuf,isbuf)
C 
      isgn=-isgn
      if(el.gt.ctofnf) goto 20 
      astep=(isgn*bw*stepnf)/cosel
      estep=0.0 
      goto 30
C 
20    continue
      astep=0.0 
      estep=isgn*bw*stepnf
C 
30    continue
      call gooff(azosav+astep,elosav+estep,'azel',nwait,ierr) 
      if(ierr.ne.0) goto 80010
C
      call vlts2(vofs,sigofs,tmofs,intpnf,rut,ierr)
      if(ierr.ne.0) goto 80010
      call dpnt2('off ',i,tmofs,astep,estep,vofs,sigofs,intpnf,lbuf,
     +           isbuf)
C
C       TURN CAL ON
C
      if(cal1nf.gt.0.0.or.cal2nf.gt.0.0) then
         call scmds('calonnf',1)
         call vlts2(vcal,sigcal,tmcal,intpnf,rut,ierr)
         if(ierr.ne.0) goto 80010
C
         call dpnt2('cal ',i,tmcal,astep,estep,vcal,sigcal,intpnf,lbuf,
     +        isbuf)
C
C  TURN CAL OFF
C
         call scmds('caloffnf',1)
      endif
C
      if(i.gt.1) goto 9
      call tzer(vzer,sigzer,tmzer,intpnf,rut,ierr)
      if(ierr.ne.0) goto 80010
      call dpnt2('zero',i,tmzer,astep,estep,vzer,sigzer,intpnf,
     +           lbuf,isbuf)
C
9     continue
C
C  fix up cal voltage if there is no cal
C
      if(cal1nf.le.0.0) then
         vcal(1)=vzer(1)
      endif
      if(cal2nf.le.0.0) then
         vcal(2)=vzer(2)
      endif

      dri=1.d0/dble(float(i))
      dim1=dble(float(i-1))
C
      dtemp1=cal1nf*((vons(1)-vofs(1))/(vcal(1)-vofs(1)))
      avg1 =(avg1*dim1+dtemp1)*dri
      sig1 =(sig1*dim1+dtemp1*dtemp1)*dri
C
      dtemp2=cal2nf*((vons(2)-vofs(2))/(vcal(2)-vofs(2)))
      avg2 =(avg2*dim1+dtemp2)*dri
      sig2 =(sig2*dim1+dtemp2*dtemp2)*dri
C
      dtemp1=cal1nf*((vofs(1)-vzer(1))/(vcal(1)-vofs(1))) 
      dtemp2=cal2nf*((vofs(2)-vzer(2))/(vcal(2)-vofs(2))) 
      tsyav1 =(tsyav1*dim1+dtemp1)*dri
      tsyav2 =(tsyav2*dim1+dtemp2)*dri
      tsysi1 =(tsysi1*dim1+dtemp1*dtemp1)*dri 
      tsysi2 =(tsysi2*dim1+dtemp2*dtemp2)*dri 
      call gooff(azosav,elosav,'azel',nwait,ierr) 
      if(ierr.ne.0) goto 80010 
C 
C    LOOP BACK FOR MORE REPITIONS 
C
10    continue
C
      call local(az2,el2,'azel',ierr)
      if(ierr.ne.0) goto 80010
      if(az2.gt.RPI*1.5.and.az .lt.RPI*.5) az =az +DTWOPI
      if(az .gt.RPI*1.5.and.az2.lt.RPI*.5) az =az -DTWOPI
      az=(az+az2)*.5
      az=mod(az+DTWOPI,DTWOPI)
      el=(el+el2)*.5
C
      if(nrepnf.gt.1) goto 50
      sig1=0
      sig2=0
      tsysi1=0
      tsysi2=0
      goto 60
C
50    continue
      drdrm1=dble(float(nrepnf))/dble(float(nrepnf-1))
      sig1=dsqrt(dabs(sig1-avg1*avg1)*drdrm1)
      sig2=dsqrt(dabs(sig2-avg2*avg2)*drdrm1)
      tsysi1=dsqrt(dabs(tsysi1-tsyav1*tsyav1)*drdrm1)
      tsysi2=dsqrt(dabs(tsysi2-tsyav2*tsyav2)*drdrm1)
C
60    continue
      savg1=tsyav1
      savg2=tsyav2
      ssig1=tsysi1
      ssig2=tsysi2
      call reslt('tsys   ',i10blnks,10,az,el,savg1,savg2,ssig1,
     +           ssig2,nrepnf,lbuf,isbuf)
      savg1=avg1
      savg2=avg2
      ssig1=sig1
      ssig2=sig2
      call fs_get_lsorna(lsorna)
      call reslt('signal ',lsorna,10,az,el,savg1,savg2,ssig1,
     +           ssig2,nrepnf,lbuf,isbuf)
C
      sdc1=avg1/cal1nf
      sdc1s=sig1/cal1nf
      sdc2=avg2/cal2nf
      sdc2s=sig2/cal2nf
      call reslt('src/cal',lsorna,10,az,el,sdc1,sdc2,sdc1s,sdc2s,
     +           nrepnf,lbuf,isbuf)
      fx1=max(fx1nf_fs,0.0)
      fx2=max(fx2nf_fs,0.0)
      sefd1=0.0
      sefd2=0.0
      sefd1s=0.0
      sefd2s=0.0
      if(avg1.gt.1e-6.and.fx1.gt.0.0) then
        sefd1=tsyav1*(fx1/avg1)
        sefd1s=(fx1/avg1)*sqrt(tsysi1**2+(sig1*(tsyav1/avg1))**2)
      endif
      if(avg2.gt.1e-6.and.fx1.gt.0.0) then
        sefd2=tsyav2*(fx2/avg2)
        sefd2s=(fx2/avg2)*sqrt(tsysi2**2+(sig2*(tsyav2/avg2))**2)
      endif
      if(fx1nf_fs.gt.0.0.or.fx2nf_fs.gt.0.0) then
        call reslt('sefd   ',lsorna,10,az,el,sefd1,sefd2,sefd1s,
     +             sefd2s,nrepnf,lbuf,isbuf)
      endif
      ae1=0.0d0
      ae2=0.0d0
      ae1s=0.0d0
      ae2s=0.0d0
      call fs_get_diaman(diaman)
      if(fx1.gt.1e-6.and.avg1.gt.1e-6) then
        ae1 =avg1*2.0*1.380662e0/(fx1*1e-3*DPI*(diaman/2.0)**2)
        ae1s=sig1*2.0*1.380662e0/(fx1*1e-3*DPI*(diaman/2.0)**2)
      endif
      if(fx2.gt.1e-6.and.avg2.gt.1e-6) then
        ae2 =avg2*2.0*1.380662e0/(fx2*1e-3*DPI*(diaman/2.0)**2)
        ae2s=sig2*2.0*1.380662e0/(fx2*1e-3*DPI*(diaman/2.0)**2)
      endif
      if(fx1nf_fs.gt.0.or.fx2nf_fs.gt.0) then
        call reslt('eta    ',lsorna,10,az,el,ae1,ae2,ae1s,
     +             ae2s,nrepnf,lbuf,isbuf)
        edts1=1000.*ae1/tsyav1
        edts1s=sqrt(ae1s**2+(tsysi1/tsyav1)**2)*1000./tsyav1
        edts2=1000.*ae2/tsyav2
        edts2s=sqrt(ae2s**2+(tsysi2/tsyav2)**2)*1000./tsyav2
        call reslt('1k*e/ts',lsorna,10,az,el,edts1,edts2,
     +             edts1s,edts2s,nrepnf,lbuf,isbuf)
      endif
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
      if(kon) goto 89990
      call gooff(azosav,elosav,'azel',nwait,jerr) 
      itry=itry-1 
      if(jerr.gt.0.and.itry.gt.0) goto 80011 
C 
      if(ierr.gt.0) goto 89990 
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'er')
      if(jerr.ne.0) call logit7ic(idum,idum,idum,-1,-100,lwho,'er')
      goto 90000 
C 
c error detected
C 
89990 continue
      call logit7ic(idum,idum,idum,-1,ierr,lwho,'br')
      if(jerr.ne.0) call logit7ic(idum,idum,idum,-1,-100,lwho,'er')
      goto 90000 
C 
C CLEAN UP AND EXIT 
C 
90000 continue
      if(VLBA.eq.and(rack,VLBA)) then
        call fc_mcbcn_r2(ip)
        if(ip(3).lt.0) then
          call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
          call logit7ic(idum,idum,idum,-1,-112,lwho,'er')
        endif
      endif
      call rn_put('onoff')
      goto 1
      end 
