      integer function feetscan(ibuf,nch,ipas,ifeet,idrive,istn,icod)

C  FEETSCAN converts the footage and pass number and
C  puts them into the scan buffer.

C History
C 970722 nrv New. Removed form newscan and addscan.

C Common blocks
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

C Input and Output
      integer*2 ibuf(*)
      integer nch ! character to start with, updated 
      integer istn,icod
      integer ipas,ifeet,idrive

C Local
      integer i,nchx
      logical kfor
      character*1 cdir
      integer*2 ibufx(4)
      character*1 pnum ! function
      integer ib2as,ichcm_ch,ichmv_ch,ichmv

C  Insert the pass number in the scan, then determine
C  whether this is a forward or reverse pass by the
C  evenness or oddness of the pass number.
C  If it's a non-recording scan, set the pass to '0'.

      if (ichcm_ch(lstrec(1,istn),1,'S2').eq.0) then
        kfor=.true. ! always forward
        nch=ichmv_ch(ibuf,nch,cpassorderl(ipas,istn,icod)(1:1)) ! group number
      else ! non-S2
        NCH = ICHMV_ch(IBUF,NCH+1,pnum(ipas))
        i=ipas/2
        kfor= ipas.ne.i*2 ! always odd forward, even reverse
      endif
      if (kfor) cdir='F'
      if (.not.kfor) cdir='R'
      if (idrive.eq.0) cdir='0'
C  Insert the direction
      NCH = ICHMV_ch(IBUF,NCH,cdir)
C  Put in footage. For S2 this is in seconds.
      nchx=ib2as(ifeet,ibufx,1,5+o'40000'+o'400'*5)
      nch=ichmv(ibuf,nch,ibufx,1,5)
      feetscan=nch
       
      return
      end
