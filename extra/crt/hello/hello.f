C     HELLO.F: A FRIENDLY GREETING FROM TICO.
C
      PROGRAM HELLO
      INTEGER I, N
      CHARACTER*64 NAME
C
      N = IARGC()
      IF (N .EQ. 0) THEN
         WRITE (*, 100) 'world'
         STOP
      END IF
C
      DO 10 I = 1, N
         CALL GETARG(I, NAME)
         WRITE (*, 100) NAME(1:LNBLNK(NAME))
   10 CONTINUE
C
  100 FORMAT ('Hello, ', A, '!')
      END
