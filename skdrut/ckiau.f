      subroutine ckiau(liau,lcom,rarad,decrad,lu)

C    CKIAU generates the IAU name and checks it against
C    the name of the source.

      include '../skdrincl/skparm.ftni'

C Input
      integer*2 liau(4),lcom(4)
      integer lu
      real*8 rarad,decrad

C Called by: SOINP, WRSOS

C Local:
      real*8 ra50,dec50
      real*8 md
      integer*2 iau_ck(4)
      integer iz2,iz1,ih,im,id,ifd,idum
      integer ichmv_ch,ichcm ! function

C Initialized:

      iz2 = 2+o'40000'+o'400'*2
      iz1 = 1+o'40000'+o'400'*1

C 1. Precess to get the 1950 position.

      call prefr(rarad,decrad,2000,ra50,dec50)

C 2. Elements of the IAU name.

      ih = ra50*12.d0/pi
      im = ((ra50*12.d0/pi) - ih)*60.d0
      id = dec50*180.d0/pi
      md = ((dec50*180.d0/pi) - id + 0.d0001)*60.d0
      ifd = abs(md)/6.0

C 3. Convert integer to ASCII

      call ib2as(ih,iau_ck,1,iz2)
      call ib2as(im,iau_ck,3,iz2)
      call ib2as(iabs(id),iau_ck,6,iz2)
      call ib2as(iabs(ifd),iau_ck,8,iz1)
      idum= ichmv_ch(iau_ck,5,'+')
      if (dec50.lt.0.d0) idum= ichmv_ch(iau_ck,5,'-')

C 4. Compare to input name

      if (ichcm(liau,1,iau_ck,1,8).ne.0) then !disagreement
        write(lu,9100) liau,lcom,iau_ck
9100    format('NOTE: IAU name for ',4a2,' (',4a2,') should be ',4a2)
      endif

      return
      end
