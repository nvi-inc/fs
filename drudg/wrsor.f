      subroutine wrsor(lsname,irah2,iram2,ras2,ldsign2,idecd2,idecm2,
     .decs2,lu)
C Write the line in the VLBA flies with the source name
C 970509 nrv New. Extracted from VLBAT.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'

C Input
      integer idec2d,in,irah2,iram2,idecd2,idecm2
      real ras2,decs2
      integer*2 ldsign2,lsname(4)

C Local
      integer*2 isname(23),blank10(5),oapostrophe
      integer iras,isra,idecs,izero2,z4000,z100,idum,lu,ierr
      integer ichmv,iflch,ib2as
      DATA isname/'sn','am','e=',''' ','  ','  ','  ','  ',
     . ' r','a=','00',
     . 'h0','0m','00','.0','s ','de','c=',' 0','0d','00','''0','0"'/
      DATA Z4000/Z'4000'/, Z100/Z'100'/, oapostrophe/2h' /

      izero2=2+z4000+z100*2
      IRAS = RAS2+.05
      isra = ((ras2-iras)*10.0)+.5
      IDECS = DECS2+0.5
      if (idecs.ge.60) then
        idecs=idecs-60
        idecm2=idecm2+1
      endif
      if (idecm2.ge.60) then
        idecm2=idecm2-60
        idecd2=idec2d+1
      endif
        in=iflch(lsname,max_sorlen)
        idum = ichmv(isname,8,blank10,1,9)
      idum = ichmv(isname,8,lsname,1,in)
        idum = ichmv(isname,8+in,oapostrophe,1,1)
      idum = ib2as(irah2,isname,21,izero2)
      idum = ib2as(iram2,isname,24,izero2)
      idum = ib2as(iras,isname,27,izero2)
      idum = ib2as(isra,isname,30,1)
      idum = ichmv(isname,37,ldsign2,1,1)
      idum = ib2as(idecd2,isname,38,izero2)
      idum = ib2as(idecm2,isname,41,izero2)
      idum = ib2as(idecs,isname,44,izero2)
      CALL writf_asc(LU,IERR,isname,23)

      return
      end
