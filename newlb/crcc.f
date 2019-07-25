      subroutine crcc(n,mask,istate,idata,idbit,nbits,ibuf,isbit) 
      implicit none
      integer*2 mask,istate,idata,ibuf(1)
      integer n,idbit,nbits,isbit
C 
C     ROUTINE TO GENERATE A CRCC CODE SEQUENCE
C 
C     ARW 780917
C     WEH 911012 port to PC, use DOD MIL-STD-1753 bit intrinsics
C     WEH 950330 port to linux f2c
C 
C     "N" IS THE # OF BITS IN THE CRCC GENERATOR. 
C     "MASK" HAS "1"'s IN ALL POSITIONS WHERE AN XOR GATE FOLLOWS THE 
C        CORRESPONDING D FLIP-FLOP. IF THE LEAST SIG BIT OF MASK IS "0",
C        IDATA IS NOT USED (I.E. THE EFFECT IS EXACTLY THE SAME AS IF 
C        THE LEAST SIG BIT OF MASK IS "1" AND IDATA IS ALL ZERO). 
C        ONLY THE N LSB POSITIONS OF MASK ARE USED. 
C        FOR EXAMPLE, A CRCC GENERATOR WITH POLYNOMIAL
C        1 + X + X**2 + X**3 + X**11 + X**12  WILL BE N=12, MASK=o'7003'. 
C     "ISTATE" IS THE INITIAL STATE OF THE CRCC FLIP-FLOPS (IN THE N LSB's).
C        ON RETURN, ISTATE IS SET TO THE FINAL STATE OF THE CRCC GENERATOR. 
C        ONLY THE N LSB's OF ISTATE ARE USED. 
C     "IDATA" IS THE DATA STREAM APPLIED TO THE D-INPUT OF THE CRCC 
C        GENERATOR. THE IDth BIT OF IDATA IS ASSUMED TO BE IN FORCE IN
C        THE INITIALIZED STATE SO THAT THE STATE OF THE CRCC IMMEDIATELY
C        AFTER THE FIRST CLOCK IS INFLUENCED BY THE IDth DATA BIT.
C     "IDBIT" IS THE BIT# OF IDATA FIRST APPLIED TO THE D-INPUT OF THE
C        CRCC GENERATOR.
C        ON RETURN, IDBIT=IDBIT+NBITS 
C     "NBITS" IS THE NUMBER OF BITS FOR WHICH THE CRCC SEQUENCE IS COMPUTED.
C     "IBUF" IS THE OUTPUT BIT STREAM (OF LENGTH NBITS) EMANATING FROM THE
C        Q-OUTPUT OF THE CRCC GENERATOR. THE FIRST BIT PLACED IN IBUF 
C        (AT IBUF BIT# ISBIT) REFLECTS THE Q-OUTPUT FOLLOWING THE FIRST 
C        CLOCKING OF THE CRCC GENERATOR.
C     "ISBIT" IS THE BIT# IN IBUF IN WHICH THE FIRST OUTPUT BIT OF THE CRCC 
C        IS PLACED. FIRST BIT IN IBUF IF BIT #1.
C        ON RETURN, ISBIT=ISBIT+NBITS.
C        IF ISBIT=0, NO OUTPUT IS PLACED IN IBUF. 
C 
C  NOTE!!!!!! ISTAT, IDBIT, AND ISBIT MAY BE MODIFIED ON RETURN.
C
c  the bits in arrays idata and ibuf are accessed by the routines
c  igetb and putb. The bit ordering for these routines is the from
c  the most significant (2**(8-1)) in a byte to least significant
c  (2**(1-1)), and then in byte order, note that this order is different
c  on little adend and big adend machines and also is different from
c  DOD MIL-STD-1753 order
c  
      integer igetb,i
      integer*2 nmask,notmsk,ipat,jdata,k1,k2,iishftc,iishft
      integer*2 m1,m2,m32768
      data m1/o'177777'/,m2/o'177776'/,m32768/o'100000'/
C
C     CREATE MASK OF N ONES.
50     continue
      nmask=iishft(m1,n-16) 
      istate=and(istate,nmask) 
C     CREATE COMPLEMENT OF EXCLUSIVE-OR MASK
      notmsk=xor(nmask,mask) 
      do 100 i=1,nbits
C 
C     DETERMINE FEEDBACK PATTERN
      ipat=0
      if (and(mask,1) .eq. 0) go to 70 
C 
C     LEAST SIG BIT OF MASK IS SET
      jdata=igetb(idata,idbit)
      idbit=idbit+1 
      if (xor(and(istate,1),jdata) .eq. 1) ipat=nmask 
C     MODIFY LAST BIT OF IPAT TO CORRESPOND TO JDATA
      ipat=or(and(ipat,m2),jdata)
      go to 80
C 
C     LEAST SIG BIT OF MASK IS ZERO 
70    if (and(istate,1) .eq. 1) ipat=nmask 
C 
C     XOR THE APPROPRIATE BITS
80    continue
      k1=and(xor(istate,ipat),mask) 
C     MASK BITS WHICH ARE DIRECTLY TRANSMITTED
      k2=and(istate,notmsk)
C 
C     CREATE NEW STATE OF GENERATOR BY "OR"ing K1 & K2 AND ROTATING 
C     LOWER N BITS RIGHT 1 BIT. 
c     istate=ishftc2(or(k1,k2),15,16) !should be next line
c     istate=ishftc2(or(k1,k2),-1,16) !doesn't work oasys fortran 1.8.5
      istate=iishftc(or(k1,k2),-1,16)
      if (and(istate,m32768) .eq. 0) go to 90 
      istate=and(istate,nmask) 
      istate=or(istate,iishft(m32768,n-16))
90    if (isbit .eq. 0) go to 100 
      call putb(ibuf,isbit,istate)
      isbit=isbit+1 
100   continue
      return
      end 
