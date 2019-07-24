c params.i
c compile time parameters
c
      integer INT_BITS      ! bits/int
      integer INT_CHARS     ! chars/int
      integer INT_ALIGN     ! number of ints for maximum aligned unit
      integer MAXNRX_FS     ! maximum number of values in rxdiode.ctl
      integer MK3           ! Mark III comparison bit variable
      integer VLBA          ! VLBA comparison bit variable
      integer MK4           ! Mark IV comparison bit variable
      character*5 FS_ROOT
      integer MAX_BBC
      integer CH_PRIOR      ! chekr        realtime priority
      integer CL_PRIOR      ! clock func.  realtime priority
      integer FS_PRIOR      ! Field System realtime priority
      integer AN_PRIOR      ! Antenna      realtime priority
      integer MAX_RXCODES   ! Max number of entries in rxdef.ctl
      integer MAX_HOR      ! Max number of horizon mask entries
c
      parameter ( INT_BITS = 32 )
      parameter ( INT_CHARS=  4 )
      parameter ( INT_ALIGN=  2 )
      parameter ( MAXNRX_FS= 30 )
      parameter ( MK3 = z'01'   )
      parameter ( VLBA = z'02'  )
      parameter ( MK4 = z'04'   )
      parameter ( FS_ROOT='/usr2')
      parameter ( MAX_BBC = 14 )
      parameter ( CH_PRIOR= 90)
      parameter ( CL_PRIOR= 30)
      parameter ( FS_PRIOR= 20)
      parameter ( AN_PRIOR= 10)
      parameter ( MAX_RXCODES = 40)
      parameter ( MAX_HOR = 30)
