      logical function knup(lname,cra,cdec,cepoch,az,el,azar,elar,
     +                imask,elmax,mc,isrcld)
C
      double precision dra,ddec,daz,del,dlat,dlon
C
      real azar(1),elar(1)
      integer*2 lname(mc),ibufi(18),ibufo(8)
      double precision alati,elong,gheig,delr,deld,dc
      integer get_buf,it(6),itb(6)
      integer*4 ip(5)
C
      include '../include/fscom.i'
      include '../include/dpi.i'
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
      equivalence (ibufo(1),dra),
     +            (ibufo(5),ddec)
C
C
      if (ichcm_ch(lname,1,'sun       ').ne.0) goto 20
      call fc_rte_time(it,it(6))
      call sunpo(dra,ddec,it)
      goto 100
C
20    continue
      if (ichcm_ch(lname,1,'moon      ').ne.0) goto 30
      call fs_get_alat(alat)
      call fs_get_wlong(wlong)
      alati=alat
      elong=-wlong
      call fs_get_height(height)
      gheig=height
      call fc_rte_time(it,it(6))
      do i=1,6
        itb(i)=it(i)
      enddo
      ip(1)=0
      call put_buf(ip(1),ibufi,-48,'  ','  ')
      call run_prog('moon ','wait',ip(1),ip(2),ip(3),ip(4),ip(5))
      call rmpar(ip)
      idum = get_buf(ip(1),ibufo,-16,idum,idum)
      goto 100
C
30    continue
      dra=dble(cra)
      ddec=dble(cdec)
      call fc_rte_time(it,it(6))
      iyr=cepoch+.5
      call move(iyr,it(6),1,it(5),dra,ddec,delr,deld,dc)
c
      dra=dra+delr
      ddec=ddec+deld
C
100   continue
      call fs_get_alat(alat)
      call fs_get_wlong(wlong)
      dlat=alat
      dlon=wlong
      call fc_rte_time(it,it(6))
C
      it(2)=it(2)+isrcld
      call cnvrt(1,dra,ddec,daz,del,it,dlat,dlon)
C
      az=sngl(daz)
      el=sngl(del)
C
      knup=.false.
      do i=1,imask-1
        if(az.ge.azar(i).and.az.le.azar(i+1)) then
          knup=.not.(el.gt.elar(i).and.el.lt.elmax)
          return
        endif
      enddo
C
      return
      end
