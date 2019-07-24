      subroutine messg(kfield,ksplit,ampa,phasea,ampb,phaseb,dlyab, 
     . itrk,ivc,ivc2,kcorel,correl)
C 
      include '../include/fscom.i'
C 
      logical ksplit,kfield,kcorel
C
      dimension lmessg(30)
C      - buffer holding formatted result
C
C     Format buffer for LOGIT, channel B
C
      call ifill_ch(lmessg,1,60,' ')
      icn = ichmv(lmessg,1,6Htone/ ,1,5)
      icn = ichmv(lmessg,icn,2Hv ,1,1)
C     IF (.NOT.KFIELD) GOTO 100
      icn = icn+ib2as(ivc,lmessg,icn,o'100000'+2)
      icn = mcoma(lmessg,icn)
      icn = icn+ib2as(itrk,lmessg,icn,o'100000'+2)
      goto 110
100   icn = ichmv(lmessg,icn,4H0,0 ,1,3)
110   icn = mcoma(lmessg,icn)
      icn = icn+ir2as(ampb,lmessg,icn,6,1)
      icn = mcoma(lmessg,icn)
      icn = icn+ir2as(phaseb,lmessg,icn,7,1)
      icn = mcoma(lmessg,icn)
      icn = icn+ib2as(nblkpc,lmessg,icn,o'100000'+3)
      if (kfield) call logit2(lmessg,icn)
      if (.not.kfield) write(lu,9540) (lmessg(i),i=1,icn/2) 
9540  format(1x,30a2) 
C 
      if (.not.ksplit) goto 950 
      call ifill_ch(lmessg,1,60,' ') 
      icn = ichmv(lmessg,1,6Htone/ ,1,5)
      icn = ichmv(lmessg,icn,2Hv ,1,1)
      if (.not.kfield) goto 200 
      icn = icn+ib2as(ivc2,lmessg,icn,o'100000'+2)
      icn = mcoma(lmessg,icn) 
      icn = icn+ib2as(itrkpc(itrk),lmessg,icn,o'100000'+2)
      goto 210
200   icn = ichmv(lmessg,icn,4H0,0 ,1,3)
210   icn = mcoma(lmessg,icn) 
      icn = icn+ir2as(ampa,lmessg,icn,6,1)
      icn = mcoma(lmessg,icn) 
      icn = icn+ir2as(phasea,lmessg,icn,7,1)
      icn = mcoma(lmessg,icn) 
      icn = icn+ib2as(nblkpc,lmessg,icn,o'100000'+3)
      if (kfield) call logit2(lmessg,icn)
      if (.not.kfield) write(lu,9540) (lmessg(i),i=1,icn/2) 
C 
C     Format buffer for LOGIT, delay
C 
      if (.not.kfield) goto 950 
      call ifill_ch(lmessg,1,60,' ') 
      icn = ichmv(lmessg,1,6Hdelay/,1,6)
      icn = icn+ib2as(itrkpc(itrk),lmessg,icn,o'100000'+2)
      icn = mcoma(lmessg,icn) 
      icn = icn+ib2as(itrk,lmessg,icn,o'100000'+2)
      icn = mcoma(lmessg,icn) 
      icn = icn+ir2as(dlyab,lmessg,icn,6,3) 
      call logit2(lmessg,icn)
C 
C     Format buffer for LOGIT, correlation
C 
950   if (.not.kcorel) goto 990 
      call ifill_ch(lmessg,1,60,' ')
      icn = ichmv(lmessg,1,7Hcorrel/,1,7) 
      icn = ichmv(lmessg,icn,2Hv ,1,1)
      icn = icn+ib2as(ivc,lmessg,icn,o'100000'+2) 
      icn = mcoma(lmessg,icn) 
      icn = ichmv(lmessg,icn,2Hv ,1,1)
      icn = icn+ib2as(ivc2,lmessg,icn,o'100000'+2)
      icn = mcoma(lmessg,icn) 
      icn = icn+ir2as(correl,lmessg,icn,7,3)
      if (kfield) call logit2(lmessg,icn)
      if (.not.kfield) write(lu,9540) (lmessg(i),i=1,icn/2) 
990   continue
      end 
