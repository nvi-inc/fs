      subroutine orign(xo,yo,azo,elo,hao,dco,lbuf,isbuf)
      integer*2 lbuf(1) 
C 
C WRITE ORIGIN LOG ENTRY
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C INPUT:
C 
C XO = XOFFSET
C YO  =Y  OFSET 
C AZO = AZ OFFSET 
C ELO = EL OFFSET 
C HAO = HA OFFSET 
C DECO = DEC OFFSET 
C 
C     WRITE ORIGIN IDENTIFIER 
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,'origin ')
C 
C HAOFFSET
C 
      icnext=icnext+jr2as(hao*180.0/RPI,lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C DECLINATION OFFSET
C 
      icnext=icnext+jr2as(dco*180.0/RPI,lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C AZIMUTH OFFSET
C 
      icnext=icnext+jr2as(azo*180.0/RPI,lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C ELEVATION OFFSET
C 
      icnext=icnext+jr2as(elo*180.0/RPI,lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C X OFFSET
C 
      icnext=icnext+jr2as(xo*180.0/RPI,lbuf,icnext,-8,4,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C Y OFFSET
C 
      icnext=icnext+jr2as(yo*180.0/RPI,lbuf,icnext,-8,4,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C CLEAN UP AND SEND IT
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 
C 
      return
      end 
