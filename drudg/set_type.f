      subroutine set_type(istn,km3rack,km4rack,kvrack,kv4rack,
     .kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,k8bbc,
     .km3rec,km4rec,kvrec,
     .kv4rec,ks2rec,kk41rec,kk42rec,km5rec)
C
C SET_TYPE sets the logical variables indicating equipment types.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C History
C 991102 nrv New. Removed from PROCS.
C 991205 nrv Correct spelling of 8-BBC rack names. Remove VLBAG.
C 991214 nrv Add kkfmk4rack for K3 formatters
C 000329 nrv VLBAG rack same as VLBA
C 020923 nrv Add Mark5 recorders.

C Input
      integer istn
C Output
      logical km3rack,km4rack,kvrack,kv4rack,
     .kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,k8bbc,
     .km3rec(2),km4rec(2),kvrec(2),km5rec(2),
     .kv4rec(2),ks2rec(2),kk41rec(2),kk42rec(2)
C Called by: PROCS, SNAP
C  LOCAL:
      integer ilrack,ilrec,ilrec2
      integer iflch,ichcm_ch

      km3rack=.false.
      km4rack=.false.
      k8bbc=.false.
      kvrack=.false.
      kv4rack=.false.
      kk41rack=.false.
      kk42rack=.false.
      km4fmk4rack=.false.
      kk3fmk4rack=.false.
      km3rec(1)=.false.
      km3rec(2)=.false.
      km4rec(1)=.false.
      km4rec(2)=.false.
      kvrec(1)=.false.
      kvrec(2)=.false.
      kv4rec(1)=.false.
      kv4rec(2)=.false.
      ks2rec(1)=.false.
      ks2rec(2)=.false.
      kk41rec(1)=.false.
      kk41rec(2)=.false.
      kk42rec(1)=.false.
      kk42rec(2)=.false.
      km5rec(1)=.false.
      km5rec(2)=.false.
C Equipment type has been set by schedule file, Option 11, or control file.
      ilrec=iflch(lstrec(1,istn),8)
      ilrec2=iflch(lstrec2(1,istn),8)
      ilrack=iflch(lstrack(1,istn),8)
      ks2rec(1)=   ichcm_ch(lstrec(1,istn),1,'S2').eq.0
      ks2rec(2)=   ichcm_ch(lstrec2(1,istn),1,'S2').eq.0
C This is for VLBA but not for VLBA4
      kvrec(1)=  ichcm_ch(lstrec(1,istn),1,'VLBA ').eq.0
      kvrec(2)=  ichcm_ch(lstrec2(1,istn),1,'VLBA ').eq.0
C This is only for VLBA4
      kv4rec(1)= ichcm_ch(lstrec(1,istn),1,'VLBA4').eq.0
      kv4rec(2)= ichcm_ch(lstrec2(1,istn),1,'VLBA4').eq.0
C This is for Mark3A 
      km3rec(1)= ichcm_ch(lstrec(1,istn),1,'Mark3A').eq.0
      km3rec(2)= ichcm_ch(lstrec2(1,istn),1,'Mark3A').eq.0
C This is for Mark4
      km4rec(1)  = ichcm_ch(lstrec(1,istn),1,'Mark4').eq.0 
      km4rec(2)  = ichcm_ch(lstrec2(1,istn),1,'Mark4').eq.0 
C Mark5 recorders
      km5rec(1)  = ichcm_ch(lstrec(1,istn),1,'Mark5').eq.0 
      km5rec(2)  = ichcm_ch(lstrec2(1,istn),1,'Mark5').eq.0 
C K4 recorders
      kk41rec(1)  = ichcm_ch(lstrec(1,istn),1,'K4-1').eq.0 
      kk41rec(2)  = ichcm_ch(lstrec2(1,istn),1,'K4-1').eq.0 
      kk42rec(1)  = ichcm_ch(lstrec(1,istn),1,'K4-2').eq.0 
      kk42rec(2)  = ichcm_ch(lstrec2(1,istn),1,'K4-2').eq.0 
C Racks
      kvrack =  (ichcm_ch(lstrack(1,istn),1,'VLBA').eq.0 .and.
     .          ilrack.eq.4)
     .     .or. ichcm_ch(lstrack(1,istn),1,'VLBA/8').eq.0 
     .     .or. ichcm_ch(lstrack(1,istn),1,'VLBAG').eq.0 
      k8bbc =  ichcm_ch(lstrack(1,istn),1,'VLBA/8').eq.0 
     .     .or.ichcm_ch(lstrack(1,istn),1,'VLBA4/8').eq.0 
      kv4rack = ichcm_ch(lstrack(1,istn),1,'VLBA4').eq.0 
     .     .or.ichcm_ch(lstrack(1,istn),1,'VLBA4/8').eq.0 
      km3rack = ichcm_ch(lstrack(1,istn),1,'Mark3A').eq.0 
      km4rack = ichcm_ch(lstrack(1,istn),1,'Mark4').eq.0 
      kk41rack = ichcm_ch(lstrack(1,istn),1,'K4-1').eq.0 
      kk42rack = ichcm_ch(lstrack(1,istn),1,'K4-2').eq.0 
      km4fmk4rack = ichcm_ch(lstrack(1,istn),1,'K4-').eq.0.and.
     .              ichcm_ch(lstrack(1,istn),5,'/M4').eq.0 
      kk3fmk4rack = ichcm_ch(lstrack(1,istn),1,'K4-').eq.0.and.
     .              ichcm_ch(lstrack(1,istn),5,'/K3').eq.0 

      return
      end
