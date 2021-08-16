! MMS/EXT/DESCR=libffi_x86.mms/MACRO=("OUTDIR=OUT","CONFIG=DEBUG","POINTER=32")

! define pointer size
.IF POINTER
! defined - ok
.ELSE
! not defined - define as 32
POINTER = 32
.ENDIF

CC_QUALIFIERS = -
/NAMES=(AS_IS,SHORTENED) -
/NOOPT -
/POINTER=$(POINTER) -
/WARNINGS=(WARNINGS=ALL, DISABLE=(EXTRASEMI,INCLUDEINFO)) -
/FLOAT=IEEE -
/IEEE_MODE=FAST -
/ACCEPT=NOVAXC_KEYWORDS -
/REENTRANCY=MULTITHREAD

CC_DEFINES = -
_USE_STD_STAT, -                ! COMMON
HAVE_CONFIG_H, -
_POSIX_EXIT

! define output folder
.IF OUTDIR
! defined - ok
.ELSE
! not defined - define as OUT
OUTDIR = OUT
.ENDIF

! check DEBUG or RELEASE
.IF CONFIG
! defined - ok
.ELSE
! not defined - define as DEBUG
CONFIG = DEBUG
.ENDIF

.IF $(CONFIG) .EQ DEBUG
! debug
CC_QUALIFIERS = $(CC_QUALIFIERS)/DEBUG/NOOPTIMIZE/LIST=$(MMS$TARGET_NAME)/SHOW=ALL
CC_DEFINES = $(CC_DEFINES),_DEBUG
OUT_DIR = $(OUTDIR).$(CONFIG)
OBJ_DIR = $(OUT_DIR).OBJ
LINK_FLAGS = /NODEBUG/MAP=[.$(OUT_DIR)]$(NOTDIR $(MMS$TARGET_NAME))/TRACE/DSF=[.$(OUT_DIR)]$(NOTDIR $(MMS$TARGET_NAME)).DSF
.ELSE
! release
CC_QUALIFIERS = $(CC_QUALIFIERS)/NODEBUG/OPTIMIZE/NOLIST
CC_DEFINES = $(CC_DEFINES),_NDEBUG
OUT_DIR = $(OUTDIR).$(CONFIG)
OBJ_DIR = $(OUT_DIR).OBJ
LINK_FLAGS = /NODEBUG/NOMAP/NOTRACEBACK
.ENDIF

CC_S_QUALIFIERS = -
/WARN=DISAB=INCLUDEINFO -
/PREPROCESS=$(MMS$TARGET_NAME) -
/NOLIST -
/NOLINE

CC_S_INCLUDES = -
[.vms], -
[.vms.include], -
[.src.x86], -
[]

CC_INCLUDES = $(CC_S_INCLUDES), [.include], [.src]

CC_S_FLAGS = $(CC_S_QUALIFIERS)/INCLUDE_DIRECTORY=($(CC_S_INCLUDES))
CC_FLAGS = $(CC_QUALIFIERS)/DEFINE=($(CC_DEFINES))/INCLUDE_DIRECTORY=($(CC_INCLUDES))

.FIRST
    ! x86 setup
    @SYS$MANAGER:X86_XTOOLS$SYLOGIN
    define sys$library X86$LIBRARY
    ! defines for nested includes, like:
    ! #include "clinic/transmogrify.h.h"
    ! names
    BUILD_OUT_DIR = F$ENVIRONMENT("DEFAULT")-"]"+".$(OUT_DIR).]"
    BUILD_OBJ_DIR = F$ENVIRONMENT("DEFAULT")-"]"+".$(OBJ_DIR).]"
    define /trans=concealed libffi$build_out 'BUILD_OUT_DIR'
    define /trans=concealed libffi$build_obj 'BUILD_OBJ_DIR'

.SUFFIXES
.SUFFIXES .EXE .OLB .OBJ .ASM .I .S .C

! CORE
.S.I
    @ pipe create/dir $(DIR $(MMS$TARGET)) | copy SYS$INPUT nl:
    $(CC) $(CC_S_FLAGS) $(MMS$SOURCE)

.I.ASM
    SAVE_DIR = F$DIRECTORY()
    SET DEFAULT $(DIR $(MMS$TARGET))
    python -c "with open('$(NOTDIR $(MMS$TARGET_NAME)).i') as fi, open('$(NOTDIR $(MMS$TARGET_NAME)).asm', 'w') as fo: fo.writelines(list(fi))"
    SET DEFAULT 'SAVE_DIR'

.ASM.OBJ
    @ pipe create/dir $(DIR $(MMS$TARGET)) | copy SYS$INPUT nl:
    LLVM_MC $(MMS$SOURCE) -x86-asm-syntax=att -filetype=obj -o=$(MMS$TARGET)

.C.OBJ
    @ pipe create/dir $(DIR $(MMS$TARGET)) | copy SYS$INPUT nl:
    $(CC) $(CC_FLAGS) /OBJECT=$(MMS$TARGET) $(MMS$SOURCE)

.OBJ.OLB
    @ IF F$SEARCH("$(MMS$TARGET)") .EQS. "" -
        THEN $(LIBR)/CREATE $(MMS$TARGET)
    $(LIBR) $(MMS$TARGET) $(MMS$SOURCE)

##########################################################################
TARGET : [.$(OUT_DIR)]libffi$shr$(POINTER).exe, TESTSUITE
    ! TARGET BUILT

[.$(OUT_DIR)]libffi$shr$(POINTER).exe : [.$(OUT_DIR)]libffi$shr$(POINTER).olb
    @ pipe create/dir $(DIR $(MMS$TARGET)) | copy SYS$INPUT nl:
    $(LINK) $(LINK_FLAGS)/SHARE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe [.$(OUT_DIR)]libffi$shr$(POINTER).olb/lib,[.vms]libffi.opt/opt

LIBRARY_OBJS= -
[.$(OBJ_DIR)]openvms64.obj -
[.$(OBJ_DIR)]prep_cif.obj -
[.$(OBJ_DIR)]types.obj -
[.$(OBJ_DIR)]raw_api.obj -
[.$(OBJ_DIR)]java_raw_api.obj -
[.$(OBJ_DIR)]closures.obj -
[.$(OBJ_DIR)]ffi64.obj

############################################################################
# Library
[.$(OUT_DIR)]libffi$shr$(POINTER).olb : [.$(OUT_DIR)]libffi$shr$(POINTER).olb($(LIBRARY_OBJS))
    continue

[.$(OBJ_DIR)]openvms64.i : [.vms]openvms64.s
[.$(OBJ_DIR)]openvms64.asm : [.$(OBJ_DIR)]openvms64.i
[.$(OBJ_DIR)]openvms64.obj : [.$(OBJ_DIR)]openvms64.asm

[.$(OBJ_DIR)]prep_cif.obj : [.src]prep_cif.c
[.$(OBJ_DIR)]types.obj : [.src]types.c
[.$(OBJ_DIR)]raw_api.obj : [.src]raw_api.c
[.$(OBJ_DIR)]java_raw_api.obj : [.src]java_raw_api.c
[.$(OBJ_DIR)]closures.obj : [.src]closures.c
[.$(OBJ_DIR)]ffi64.obj : [.src.x86]ffi64.c

############################################################################
CLEAN :
    del/tree [.$(OUT_DIR)...]*.*;*

############################################################################
TESTSUITEFILES = -
[.$(OUT_DIR)]align_mixed.exe

TESTSUITE : $(TESTSUITEFILES)
    ! ok

[.$(OUT_DIR)]align_mixed.exe : [.$(OBJ_DIR)]align_mixed.obj, [.$(OUT_DIR)]libffi$shr$(POINTER).olb
    $(LINK) $(LINK_FLAGS) /SHARE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe $(MMS$SOURCE),[.$(OUT_DIR)]libffi$shr$(POINTER).olb/lib

[.$(OBJ_DIR)]align_mixed.obj : [.testsuite.libffi^.call]align_mixed.c
