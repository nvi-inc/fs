      subroutine wrsor(lsname,irah2,iram2,ras2,ldsign2,idecd2,idecm2,
     .decs2,lu)
C Write the line in the VLBA flies with the source name
C 970509 nrv New. Extracted from VLBAT.
C 980409 nrv Get rid of data statement to clean up output.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'

C Input
      integer idec2d,in,irah2,iram2,idecd2,idecm2
      real ras2,decs2
      integer*2 ldsign2,lsname(4)

C Local
      integer*2 isname(30)
      integer iras,isra,idecs,izero2,z4000,z100,idum,lu,ierr,ich
      integer ichmv,iflch,ib2as,ichmv_ch
      DATA Z4000/Z'4000'/, Z100/Z'100'/

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
       call ifill(isname,1,60,oblank)
       ich = ichmv_ch(isname,1,'sname=''')
       in=iflch(lsname,max_sorlen)
       ich = ichmv(isname,ich,lsname,1,in)
       ich = ichmv_ch(isname,ich,'''  ra=')
      ich = ich + ib2as(irah2,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'h')
      ich = ich + ib2as(iram2,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'m')
      ich = ich + ib2as(iras,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'.')
      ich = ich + ib2as(isra,isname,ich,1)
       ich = ichmv_ch(isname,ich,'s dec=')
      ich = ichmv(isname,ich,ldsign2,1,1)
      ich = ich + ib2as(idecd2,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'d')
      ich = ich + ib2as(idecm2,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'''')
      ich = ich + ib2as(idecs,isname,ich,izero2)
       ich = ichmv_ch(isname,ich,'"')
      CALL writf_asc(LU,IERR,isname,(ich+1)/2)

      return
      end
