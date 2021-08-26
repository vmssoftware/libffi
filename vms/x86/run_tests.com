$ ON ERROR THEN $ GOSUB ON_ERROR
$ FAILED = 0
$ START:
$   FILE = F$SEARCH("*.EXE")
$   IF FILE .EQS. "" THEN GOTO FINISHED
$   NAME = F$PARSE(FILE,,,"NAME")
$   IF F$EDIT(NAME,"UPCASE") .EQS. "LIBFFI$SHR" THEN GOTO START
$   WRITE SYS$OUTPUT "======== start running ''NAME'"
$   DEFINE /USER SYS$OUTPUT nl:
$   RUN 'NAME'
$   GOTO START
$ FINISHED:
$ WRITE SYS$OUTPUT "======== total failed ''FAILED'"
$ EXIT
$ ON_ERROR:
$ ON ERROR THEN $ GOSUB ON_ERROR
$ WRITE SYS$OUTPUT "======== ''NAME' is failed"
$ FAILED = FAILED + 1
$ RETURN
