      function ivced(iwhat,index,extbw,ias,ic1,ic2)

C  This routine encodes or decodes information relating
C  to MAT communications for video converters
C 
      include '../include/fscom.i'
C
C  INPUT: 
C 
C     IWHAT - code for type of conversion, <0 encode, >0 decode 
      integer*2 ias(1)
C      - string with ASCII characters 
C 
C 
C  If encode
C 
C     INDEX - input index of quantity 
C     IAS - string to hold ASCII characters 
C     IC1 - first char available in IAS 
C     IC2 - last char available in IAS
C     IVCED - next available char in IAS after encoding 
C 
C  If decode: 
C 
C     INDEX - returned index of quantity, error if zero 
C     IAS - string containing ASCII characters to be decoded
C     IC1 - first char to use in IAS
C     IC2 - last char to use in IAS 
C 
C  CALLED BY:  quikr/vc  quikr/vcdis
C
C 
C  SUBROUTINES called: character manipulation 
C 
C 
C  LOCAL: 
C 
      double precision das2b
      dimension bw(7),nchtp(8),nrem(2),nlok(2) 
      dimension bw4(7)
      real extbw
      integer*2 ltp(8)
      integer*2 lrem(4),llok(4)
      data bw/0.0,0.125,0.250,0.50,1.0,2.0,4.0/ 
      data bw4/0.0,0.125,16.0,0.50,8.0,2.0,4.0/ 
      data ltp/2Hul,2Hl ,2Hu ,2Hif,2Hlo,2Hgr,2Hgr,2Hgr/ 
      data nchtp/2,1,1,2,2,2,2,2/ 
      data lrem/2Hre,2Hm ,2Hlo,2Hc /
      data nrem/3,3/ 
      data llok/2Hlo,2Hck,2Hun,2Hlk/
      data nlok/4,4/ 
      data nbw/7/, ntp/8/ 
C 
C  HISTORY:
C    WHO  WHEN    WHAT
C    gag  920713  Added bw4 array and check for MK4.
C    gag  920727  Changed 0.25 to 16 in bandwidth array.
C 
C  Initialize returned parameter in case we have to quit early. 
C 
      ivced = ic1 
      if (iwhat.gt.0) index = -1
C 
      goto (204,203,202,201,990,301,302) iwhat+5
C 
C  Code -1, VC bandwidth. 
C 
201   continue
      if (ic1+5.gt.ic2) return
      call fs_get_rack(rack)
      if (rack.eq.MK3) then
        ivced = ic1 + ir2as(bw(index+1),ias,ic1,5,3)
      else
        ivced = ic1 + ir2as(bw4(index+1),ias,ic1,6,3)
      endif
      if(index.eq.0.and.extbw.ge.0.0) then
         ivced=ichmv_ch(ias,ivced,"(")
         ivced = ivced + ir2as(extbw,ias,ivced,6,3)
         ivced=ichmv_ch(ias,ivced,")")
      endif
      return
C 
C  Code -2, VC TPI selection
C 
202   continue
      if(index.lt.0.or.index.gt.7) then
         ivced=ic1
         return
      endif
      if (ic1-1+nchtp(index+1).gt.ic2) return 
      ivced = ichmv(ias,ic1,ltp(index+1),1,nchtp(index+1))
      return
C 
C  Code -3, General LOCAL/REMOTE. 
C 
203   continue
      if (ic1-1+nrem(index+1).gt.ic2) return
      ivced = ichmv(ias,ic1,lrem,index*4+1,nrem(index+1)) 
      return
C 
C  Code -4, LOCK/UNLOCK.
C 
204   continue
      if (ic1-1+nlok(index+1).gt.ic2) return
      ivced = ichmv(ias,ic1,llok,index*4+1,nlok(index+1)) 
      return
C 
C 
C  Initialize for the DECODE case.
C 
C  VC bandwidth choices.
C 
301   continue
      extbw=-1.
      ilp=iscn_ch(ias,ic1,ic2,'(')
      if(ilp.ne.0) then
         val = das2b(ias,ic1,ilp-ic1,ierr) 
      else
         val = das2b(ias,ic1,ic2-ic1+1,ierr) 
      endif
      if (ierr.ne.0) return 
      call fs_get_rack(rack)
      if (rack.eq.MK3) then
        do 3010 i=1,nbw 
          if (val.eq.bw(i)) index = i-1 
3010      continue
      else
        do 3011 i=1,nbw 
          if (val.eq.bw4(i)) index = i-1 
3011      continue
      endif
      if(index.eq.0.and.ilp.ne.0) then
         irp=iscn_ch(ias,ic1,ic2,')')
         if(irp.ne.0) then
            extbw = das2b(ias,ilp+1,irp-ilp-1,ierr) 
         else
            extbw = das2b(ias,ilp,ic2-ilp,ierr) 
         endif
         if(ierr.ne.0) return
         if(extbw.lt.0.0) then
            ierr=-1
            return
         endif
      endif
      return
C 
C 
C  VC TPI selection codes.
C 
302   continue
      do 3020 i=1,ntp 
        if (ichcm(ias,ic1,ltp(i),1,2).eq.0) index = i-1 
3020    continue
      return
C 
990   return
      end 
