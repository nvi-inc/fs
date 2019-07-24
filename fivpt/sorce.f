      subroutine sorce(rut,idoy,iyr,lbuf,isbuf) 
      integer*2 lbuf(1) 
C 
C WRITE SOURCE LOG ENTRY
C 
      include '../include/fscom.i'
C 
C  WE READ THE FOLLOWING FROM FSCOM:
C 
C    LSORNA,  DEC50, RA50, EP1950,
C 
C  SOURCE ENTRY IDENTIFIER
C 
      icnext=1
      icnext=ichmv(lbuf,icnext,8hsource  ,1,7)
C 
C  SOURCE NAME
C 
      call fs_get_lsorna(lsorna)
      icnext=ichmv(lbuf,icnext,lsorna,1,10) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C RA
C 
      call fs_get_ra50(ra50)
      icnext=iptra(ra50,lbuf,icnext)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C DECLINATION 
C 
      call fs_get_dec50(dec50)
      icnext=iptdc(dec50,lbuf,icnext) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C EPOCH 
C 
      call fs_get_ep1950(ep1950)
      icnext=icnext+jr2as(ep1950,lbuf,icnext,-6,1,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C  TIME 
C 
      ih=int(rut/3600.0)
      rut1=rut-3600.0*float(ih) 
      im=int(rut1/60.0) 
      rut2=rut1-60.0*float(im)
      is=int(rut2+0.5)
C 
      iy=mod(iyr,100) 
      icnext=icnext+ib2as(iy,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv(lbuf,icnext,2H/  ,1,1) 
      icnext=icnext+ib2as(idoy,lbuf,icnext,o'40000'+o'400'*3+3) 
      icnext=ichmv(lbuf,icnext,2H.  ,1,1) 
      icnext=icnext+ib2as(ih,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv(lbuf,icnext,2H:  ,1,1) 
      icnext=icnext+ib2as(im,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv(lbuf,icnext,2H:  ,1,1) 
      icnext=icnext+ib2as(is,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C EVEN OFF THE LAST WORD AND SEND IT
C 
      nchar=icnext-1
      if(1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1) 
      call logit2(lbuf,nchar)
C 
      return
      end 
