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
      integer S2            ! S2 comparison bit variable
      integer K4            ! K4 comparison bit variable
      integer K4MK4         ! K4MK4 comparison bit variable
      integer K4K3          ! K4K3 comparison bit variable
      integer VLBA4         ! VLBA4 comparison bit variable
      integer VLBAG         ! VLBA geodesy rack
      integer VLBA2         ! VLBA drive type 2
      integer VLBAB         ! VLBA drive type B
      integer MK4B          ! Mark IV 1 head
      integer K41           ! K41 comparison bit variable
      integer K41U          ! K41U comparison bit variable
      integer K42           ! K42 comparison bit variable
      integer K42A          ! K42A comparison bit variable
      integer K42B          ! K42B comparison bit variable
      integer K42BU         ! K42BU comparison bit variable
      integer K42C          ! K42C comparison bit variable
      integer K41DMS        ! K41DMS comparison bit variable
      integer K42DMS        ! K42DMS comparison bit variable
      character*5 FS_ROOT
      integer MAX_BBC
      integer CH_PRIOR      ! chekr        realtime priority
      integer CL_PRIOR      ! clock func.  realtime priority
      integer FS_PRIOR      ! Field System realtime priority
      integer AN_PRIOR      ! Antenna      realtime priority
      integer MAX_RXCODES   ! Max number of entries in rxdef.ctl
      integer MAX_HOR      ! Max number of horizon mask entries
c
      integer MAX_PROC1, MAX_PROC2
      PARAMETER (MAX_PROC1=256, MAX_PROC2=1500)
c
      parameter ( INT_BITS = 32 )
      parameter ( INT_CHARS=  4 )
      parameter ( INT_ALIGN=  2 )
      parameter ( MAXNRX_FS= 30 )
C rack/drive
      parameter ( MK3 = z'01'   )
      parameter ( VLBA = z'02'  )
      parameter ( MK4 = z'04'   )
      parameter ( S2  = z'08'   )
      parameter ( VLBA4 = z'10' )
      parameter ( K4 = z'20' )
      parameter ( K4MK4 = z'40' )
      parameter ( K4K3 = z'80' )
C rack/drive _types
      parameter ( VLBAG    = z'100' )
      parameter ( VLBA2    = z'200' )
      parameter ( MK4B     = z'400'  )
      parameter ( K41      = z'800'  )
      parameter ( K41U     = z'1000'  )
      parameter ( K42      = z'2000'  )
      parameter ( K42A     = z'4000'  )
      parameter ( K42BU    = z'8000'  )
      parameter ( VLBAB    = z'10000' )
      parameter ( K41DMS   = z'20000' )
      parameter ( K42DMS   = z'40000' )
      parameter ( K42B     = z'80000'  )
      parameter ( K42C     = z'100000'  )
C
      parameter ( FS_ROOT='/usr2')
      parameter ( MAX_BBC = 14 )
      parameter ( CH_PRIOR=-04)
      parameter ( CL_PRIOR=-08)
      parameter ( FS_PRIOR=-12)
      parameter ( AN_PRIOR=-16)
      parameter ( MAX_RXCODES = 40)
      parameter ( MAX_HOR = 30)






