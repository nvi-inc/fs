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
      integer FS_PRIOR      ! Field System realtime priority
      integer AN_PRIOR      ! Antenna      realtime priority
c
      parameter ( INT_BITS = 32 )
      parameter ( INT_CHARS=  4 )
      parameter ( INT_ALIGN=  2 )
      parameter ( MAXNRX_FS= 30 )
      parameter ( MK3 = z'01'   )
      parameter ( VLBA = z'02'  )
      parameter ( MK4 = z'04'   )
      parameter ( FS_ROOT='/usr2')
      parameter ( MAX_BBC = 15 )
      parameter ( FS_PRIOR= 20)
      parameter ( AN_PRIOR= 10)
