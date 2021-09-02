$ ON ERROR THEN $ GOSUB ON_ERROR
$ FAILED = 0
$ CUR_DIR = F$ENVIRONMENT("DEFAULT")
$ SET DEFAULT python$root:[lib.python3^.10.ctypes.test]
$ START:
$   FILE = F$SEARCH("*.py")
$   IF FILE .EQS. "" THEN GOTO FINISHED
$   NAME = F$PARSE(FILE,,,"NAME")
$   IF F$EXTRACT(0, 1, NAME) .EQS. "_" THEN GOTO START
$   WRITE SYS$OUTPUT "======== start running ''NAME'"
$   ! DEFINE /USER SYS$OUTPUT nl:
$   python 'NAME'.py -v
$   GOTO START
$ FINISHED:
$ WRITE SYS$OUTPUT "======== total failed ''FAILED'"
$ SET DEFAULT 'CUR_DIR'
$ EXIT
$ ON_ERROR:
$ ON ERROR THEN $ GOSUB ON_ERROR
$ WRITE SYS$OUTPUT "======== ''NAME' is failed"
$ FAILED = FAILED + 1
$ RETURN
