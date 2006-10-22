!     Last change:  JG   29 Jan 2004    2:57 pm
!
      INTEGER MySQLHandle(400)  !handle for Mysql
      Integer MySQLRes(40)       !handlfor result
      INTEGER iSQLHandle

!stuff to initialize mysql.
      character*20 lmysql_db
      character*20 lmysql_user
      character*20 lmysql_password
      character*50 lmysql_host
      character*80 lmysql_socket
      integer iport_mysql
      integer iclient_flag
! other info stuff
      integer ilen_fd                   !length
      integer imaxlen_fd                !max length
      integer itype_fd                  !type
      integer iflag_fd                  !bit flag
      integer idec_fd                   !# of decimal points


! things to use in making queries.
      character*255 lSQLquery
      character*30 ldef_fd              !default value
      character*20 lwild
      character*20 ltable
! Stuff for fields.
      character*50 lfield(50)         !field name
      character*30 ltable_fd            !table it is from

      common /mysql_cmn/MySqlHandle,MySQLRes,iSQlHandle
      common /mysql_cmn/iport_mysql,iclient_flag
      common /mysql_cmn/ilen_fd,imaxlen_fd,itype_fd,iflag_fd,idec_fd
      common /mysql_cmn/lmysql_db,lmysql_user,lmysql_password
      common /mysql_cmn/lmysql_host,lmysql_socket,ldef_fd
      common /mysql_cmn/lsqlquery,lwild,ltable,lfield,ltable_fd


