      logical function kinit(icbuf)
C
C
C  WHO  WHEN    DESCRIPTION
C  GAG  901228  Changed IPGST call to KBOSS call to see if BOSS is running.
C
C
      logical kif
C
      character*(*) icbuf
c     character*63 icdbuf
C
      integer*2 lfs(16),lfs2(16),lfp(16),lnf(16)
      character*32 lfsc,lfs2c,lfpc,lnfc
      integer trimlen
      logical rn_test
C
      data lfsc   /  'the field system must be running'/
      data lfs2c  /  'before aquir can be run.        '/
      data lfpc   /  'fivpt must dormant              '/
      data lnfc   /  'onoff must dormant              '/
c
c     data icdbuf/'/usr2/control/'/
C
      call char2hol(lfsc,lfs,1,32)
      lfs1=trimlen(lfsc)
c
      call char2hol(lfs2c,lfs2,1,32)
      lfs21=trimlen(lfs2c)
c
      call char2hol(lfpc,lfp,1,32)
      lfp1=trimlen(lfpc)
c
      call char2hol(lnfc,lnf,1,32)
      lnf1=trimlen(lnfc)
c
      kinit=.true.
      luz=1
C
      icbuf=' '
      call rcpar(1,icbuf)
      if (icbuf.eq.' ') goto 8000
C
C CHECK FOR FIELD SYSTEM
C
      if (kif(lfs,lfs1,lfs2,1,lfs21,.not.rn_test('fs   '),luz))
     + goto 10000
C
C CHECK FOR FIVPT
C
      if (kif(lfp,lfp1,lfs2,1,lfs21,rn_test('fivpt'),luz))
     + goto 10000
C
C CHECK FOR ONOFF
C
      if (kif(lnf,lnf1,lfs2,1,lfs21,rn_test('onoff'),luz))
     + goto 10000
C
      kinit=.false.
      goto 10000
C
8000  continue
      call po_put_c('aquir: acquire pointing data')
      call po_put_c('usage: aquir control')
      call po_put_c('where: control is the control file name')
      call po_put_c('beware: this progam takes control of the field syst
     .em')
      goto 10000
C
8100  continue
      call po_put_c('for help: aquir')
C
10000 continue
C
      return
      end
