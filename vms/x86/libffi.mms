! MMS/EXT/DESCR=libffi_x86.mms/MACRO=("OUTDIR=OUT","CONFIG=DEBUG","POINTER=32")
! x86
! MMS/EXT/DESCR=libffi_x86.mms/MACRO=("OUTDIR=OUT","CONFIG=DEBUG","POINTER=32","X86_64=1")

POINTER_SIZE = 

.IF X86_64
LINK_ADD=/SEGMENT=CODE=P0
X86_64_START=@sys$login:setup_compilers
.ENDIF

.IF X86_CROSS
X86_START = pipe @SYS$MANAGER:X86_XTOOLS$SYLOGIN ; define sys$library X86$LIBRARY
.ENDIF

.IF X86_CROSS
X86HOST = BALDER
X86DISK = $172$DKA300
X86USER = vorfolomeev
X86PASSWORD = AAwf12jg%3kW
.ENDIF

! set def $172$DKA300:
! @usr_disk:[vorfolomeev.cpython.vms]python^.def_x86
! python /$172$DKA300/vorfolomeev/cpython/lib/ctypes/test/ -v

.IF POINTER .EQ 32
POINTER_SIZE = /POINTER_SIZE=32
.ELSIF POINTER .EQ 64
POINTER_SIZE = /POINTER_SIZE=64
.ENDIF

CC_QUALIFIERS = -
/NAMES=(AS_IS,SHORTENED) -
/NOOPT -
$(POINTER_SIZE) -
/WARNINGS=(WARNINGS=ALL, DISABLE=(EXTRASEMI,INCLUDEINFO,UNDERFLOW)) -
/FLOAT=IEEE -
/IEEE_MODE=FAST -
/ACCEPT=NOVAXC_KEYWORDS -
/REENTRANCY=MULTITHREAD

CC_DEFINES = -
_USE_STD_STAT, -                ! COMMON
HAVE_CONFIG_H, -
_POSIX_EXIT, -
FFI_NO_RAW_API=1                ! no raw api

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

.IF $(FINDSTRING DEBUG, $(CONFIG)) .EQ DEBUG
! debug
CC_QUALIFIERS = $(CC_QUALIFIERS)/DEBUG/NOOPTIMIZE/LIST=$(MMS$TARGET_NAME)/SHOW=ALL
CC_DEFINES = $(CC_DEFINES),_DEBUG
OUT_DIR = $(OUTDIR).$(CONFIG)
OBJ_DIR = $(OUT_DIR).OBJ
LINK_FLAGS = $(LINK_ADD)/NODEBUG/MAP=[.$(OUT_DIR)]$(NOTDIR $(MMS$TARGET_NAME))/TRACE/DSF=[.$(OUT_DIR)]$(NOTDIR $(MMS$TARGET_NAME)).DSF
.ELSE
! release
CC_QUALIFIERS = $(CC_QUALIFIERS)/NODEBUG/OPTIMIZE/NOLIST
CC_DEFINES = $(CC_DEFINES),_NDEBUG
OUT_DIR = $(OUTDIR).$(CONFIG)
OBJ_DIR = $(OUT_DIR).OBJ
LINK_FLAGS = $(LINK_ADD)/NODEBUG/NOMAP/NOTRACEBACK
.ENDIF

LIBFFI_LIB = [.$(OUT_DIR)]libffi$shr$(POINTER).olb

CC_S_QUALIFIERS = -
/PREPROCESS=$(MMS$TARGET_NAME) -
/NOLIST -
/NOLINE

.IF X86_64
CC_S_QUALIFIERS = $(CC_S_QUALIFIERS)-
/WARN=DISAB=INCLUDEINFO
.ENDIF

CC_S_INCLUDES = -
[.vms.x86], -
[], -
[.src.x86]

CC_INCLUDES = $(CC_S_INCLUDES), [.include], [.src], [.testsuite.libffi^.call]

CC_S_FLAGS = $(CC_S_QUALIFIERS)/INCLUDE_DIRECTORY=($(CC_S_INCLUDES))
CC_FLAGS = $(CC_QUALIFIERS)/DEFINE=($(CC_DEFINES))/INCLUDE_DIRECTORY=($(CC_INCLUDES))

.FIRST
    $(X86_64_START)
    $(X86_START)
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
    python vms/x86/make_asm.py "$(MMS$TARGET_NAME).i"

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

.OBJ.EXE
.IF X86_64
    $(LINK) $(LINK_FLAGS) /EXE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe $(MMS$SOURCE), $(LIBFFI_LIB)/lib,[.vms.x86]common_native.opt/opt
.ELSE
    $(LINK) $(LINK_FLAGS) /EXE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe $(MMS$SOURCE), $(LIBFFI_LIB)/lib,[.vms.x86]common.opt/opt
.ENDIF

##########################################################################
TARGET : [.$(OUT_DIR)]libffi$shr$(POINTER).exe
    ! TARGET BUILT

[.$(OUT_DIR)]libffi$shr$(POINTER).exe : $(LIBFFI_LIB)
    @ pipe create/dir $(DIR $(MMS$TARGET)) | copy SYS$INPUT nl:
.IF X86_64
    $(LINK) $(LINK_FLAGS)/SHARE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe $(LIBFFI_LIB)/lib,[.vms.x86]libffi_native.opt/opt
.ELSE
    $(LINK) $(LINK_FLAGS)/SHARE=libffi$build_out:[000000]$(NOTDIR $(MMS$TARGET_NAME)).exe $(LIBFFI_LIB)/lib,[.vms.x86]libffi.opt/opt
.ENDIF

HEADERS = -
[.vms.x86]ffi.h -
[.vms.x86]fficonfig.h -
[.vms.x86]internal64.h -
[.src.x86]ffitarget.h

LIBRARY_OBJS = -
[.$(OBJ_DIR)]vms64.obj -
[.$(OBJ_DIR)]prep_cif.obj -
[.$(OBJ_DIR)]types.obj -
[.$(OBJ_DIR)]closures.obj -
[.$(OBJ_DIR)]ffi64.obj

############################################################################
# Library
$(LIBFFI_LIB) : $(LIBFFI_LIB)($(LIBRARY_OBJS))
    continue

[.$(OBJ_DIR)]vms64.i : [.vms.x86]vms64.s $(HEADERS)
[.$(OBJ_DIR)]vms64.asm : [.$(OBJ_DIR)]vms64.i
[.$(OBJ_DIR)]vms64.obj : [.$(OBJ_DIR)]vms64.asm

[.$(OBJ_DIR)]prep_cif.obj : [.src]prep_cif.c $(HEADERS)
[.$(OBJ_DIR)]types.obj : [.src]types.c $(HEADERS)
[.$(OBJ_DIR)]closures.obj : [.src]closures.c $(HEADERS)
[.$(OBJ_DIR)]ffi64.obj : [.vms.x86]ffi64.c $(HEADERS)

############################################################################
CLEAN :
    del/tree [.$(OUT_DIR)...]*.*;*

############################################################################
TESTCALL_FILES = -
[.$(OUT_DIR)]align_mixed.exe -
[.$(OUT_DIR)]align_stdcall.exe -
[.$(OUT_DIR)]err_bad_typedef.exe -
[.$(OUT_DIR)]float_va.exe -
[.$(OUT_DIR)]float.exe -
[.$(OUT_DIR)]float1.exe -
[.$(OUT_DIR)]float2.exe -
[.$(OUT_DIR)]float3.exe -
[.$(OUT_DIR)]float4.exe -
[.$(OUT_DIR)]many_double.exe -
[.$(OUT_DIR)]many_mixed.exe -
[.$(OUT_DIR)]many.exe -
[.$(OUT_DIR)]many2.exe -
[.$(OUT_DIR)]negint.exe -
[.$(OUT_DIR)]offsets.exe -
[.$(OUT_DIR)]pr1172638.exe -
[.$(OUT_DIR)]promotion.exe -
[.$(OUT_DIR)]pyobjc-tc.exe -
[.$(OUT_DIR)]return_dbl.exe -
[.$(OUT_DIR)]return_dbl1.exe -
[.$(OUT_DIR)]return_dbl2.exe -
[.$(OUT_DIR)]return_fl.exe -
[.$(OUT_DIR)]return_fl1.exe -
[.$(OUT_DIR)]return_fl2.exe -
[.$(OUT_DIR)]return_fl3.exe -
[.$(OUT_DIR)]return_ldl.exe -
[.$(OUT_DIR)]return_ll.exe -
[.$(OUT_DIR)]return_ll1.exe -
[.$(OUT_DIR)]return_sc.exe -
[.$(OUT_DIR)]return_sl.exe -
[.$(OUT_DIR)]return_uc.exe -
[.$(OUT_DIR)]return_ul.exe -
[.$(OUT_DIR)]strlen.exe -
[.$(OUT_DIR)]strlen2.exe -
[.$(OUT_DIR)]strlen3.exe -
[.$(OUT_DIR)]strlen4.exe -
[.$(OUT_DIR)]struct1.exe -
[.$(OUT_DIR)]struct2.exe -
[.$(OUT_DIR)]struct3.exe -
[.$(OUT_DIR)]struct4.exe -
[.$(OUT_DIR)]struct5.exe -
[.$(OUT_DIR)]struct6.exe -
[.$(OUT_DIR)]struct7.exe -
[.$(OUT_DIR)]struct8.exe -
[.$(OUT_DIR)]struct9.exe -
[.$(OUT_DIR)]struct10.exe -
[.$(OUT_DIR)]uninitialized.exe
! next files cause compiler error
! [.$(OUT_DIR)]va_1.exe 
! [.$(OUT_DIR)]va_struct1.exe
! [.$(OUT_DIR)]va_struct2.exe
! [.$(OUT_DIR)]va_struct3.exe

TESTCLOSURE_FILES = -
[.$(OUT_DIR)]closure_fn0.exe -
[.$(OUT_DIR)]closure_fn1.exe -
[.$(OUT_DIR)]closure_fn2.exe -
[.$(OUT_DIR)]closure_fn3.exe -
[.$(OUT_DIR)]closure_fn4.exe -
[.$(OUT_DIR)]closure_fn5.exe -
[.$(OUT_DIR)]closure_fn6.exe -
[.$(OUT_DIR)]closure_loc_fn0.exe -
[.$(OUT_DIR)]closure_simple.exe -
[.$(OUT_DIR)]cls_1_1byte.exe -
[.$(OUT_DIR)]cls_2byte.exe -
[.$(OUT_DIR)]cls_3_1byte.exe -
[.$(OUT_DIR)]cls_3byte1.exe -
[.$(OUT_DIR)]cls_3byte2.exe -
[.$(OUT_DIR)]cls_3float.exe -
[.$(OUT_DIR)]cls_4_1byte.exe -
[.$(OUT_DIR)]cls_4byte.exe -
[.$(OUT_DIR)]cls_5_1_byte.exe -
[.$(OUT_DIR)]cls_5byte.exe -
[.$(OUT_DIR)]cls_6_1_byte.exe -
[.$(OUT_DIR)]cls_6byte.exe -
[.$(OUT_DIR)]cls_7_1_byte.exe -
[.$(OUT_DIR)]cls_7byte.exe -
[.$(OUT_DIR)]cls_8byte.exe -
[.$(OUT_DIR)]cls_9byte1.exe -
[.$(OUT_DIR)]cls_9byte2.exe -
[.$(OUT_DIR)]cls_12byte.exe -
[.$(OUT_DIR)]cls_16byte.exe -
[.$(OUT_DIR)]cls_18byte.exe -
[.$(OUT_DIR)]cls_19byte.exe -
[.$(OUT_DIR)]cls_20byte.exe -
[.$(OUT_DIR)]cls_20byte1.exe -
[.$(OUT_DIR)]cls_24byte.exe -
[.$(OUT_DIR)]cls_64byte.exe -
[.$(OUT_DIR)]cls_align_double.exe -
[.$(OUT_DIR)]cls_align_float.exe -
[.$(OUT_DIR)]cls_align_longdouble_split.exe -
[.$(OUT_DIR)]cls_align_longdouble_split2.exe -
[.$(OUT_DIR)]cls_align_longdouble.exe -
[.$(OUT_DIR)]cls_align_pointer.exe -
[.$(OUT_DIR)]cls_align_sint16.exe -
[.$(OUT_DIR)]cls_align_sint32.exe -
[.$(OUT_DIR)]cls_align_sint64.exe -
[.$(OUT_DIR)]cls_align_uint16.exe -
[.$(OUT_DIR)]cls_align_uint32.exe -
[.$(OUT_DIR)]cls_align_uint64.exe -
[.$(OUT_DIR)]cls_dbls_struct.exe -
[.$(OUT_DIR)]cls_double_va.exe -
[.$(OUT_DIR)]cls_double.exe -
[.$(OUT_DIR)]cls_float.exe -
[.$(OUT_DIR)]cls_longdouble_va.exe -
[.$(OUT_DIR)]cls_longdouble.exe -
[.$(OUT_DIR)]cls_many_mixed_args.exe -
[.$(OUT_DIR)]cls_many_mixed_float_double.exe -
[.$(OUT_DIR)]cls_multi_schar.exe -
[.$(OUT_DIR)]cls_multi_sshort.exe -
[.$(OUT_DIR)]cls_multi_sshortchar.exe -
[.$(OUT_DIR)]cls_multi_uchar.exe -
[.$(OUT_DIR)]cls_multi_ushort.exe -
[.$(OUT_DIR)]cls_multi_ushortchar.exe -
[.$(OUT_DIR)]cls_pointer_stack.exe -
[.$(OUT_DIR)]cls_pointer.exe -
[.$(OUT_DIR)]cls_schar.exe -
[.$(OUT_DIR)]cls_sint.exe -
[.$(OUT_DIR)]cls_sshort.exe -
[.$(OUT_DIR)]cls_struct_va1.exe -
[.$(OUT_DIR)]cls_uchar_va.exe -
[.$(OUT_DIR)]cls_uchar.exe -
[.$(OUT_DIR)]cls_uint_va.exe -
[.$(OUT_DIR)]cls_uint.exe -
[.$(OUT_DIR)]cls_ulong_va.exe -
[.$(OUT_DIR)]cls_ulonglong.exe -
[.$(OUT_DIR)]cls_ushort_va.exe -
[.$(OUT_DIR)]cls_ushort.exe -
[.$(OUT_DIR)]err_bad_abi.exe -
[.$(OUT_DIR)]huge_struct.exe -
[.$(OUT_DIR)]nested_struct.exe -
[.$(OUT_DIR)]nested_struct1.exe -
[.$(OUT_DIR)]nested_struct2.exe -
[.$(OUT_DIR)]nested_struct3.exe -
[.$(OUT_DIR)]nested_struct4.exe -
[.$(OUT_DIR)]nested_struct5.exe -
[.$(OUT_DIR)]nested_struct6.exe -
[.$(OUT_DIR)]nested_struct7.exe -
[.$(OUT_DIR)]nested_struct8.exe -
[.$(OUT_DIR)]nested_struct9.exe -
[.$(OUT_DIR)]nested_struct10.exe -
[.$(OUT_DIR)]nested_struct11.exe -
[.$(OUT_DIR)]problem1.exe -
[.$(OUT_DIR)]stret_large.exe -
[.$(OUT_DIR)]stret_large2.exe -
[.$(OUT_DIR)]stret_medium.exe -
[.$(OUT_DIR)]stret_medium2.exe -
[.$(OUT_DIR)]testclosure.exe

TESTCOMPLEX_FILES = -
[.$(OUT_DIR)]cls_align_complex_double.exe -
[.$(OUT_DIR)]cls_align_complex_float.exe -
- ! [.$(OUT_DIR)]cls_align_complex_longdouble.exe -
[.$(OUT_DIR)]cls_complex_double.exe -
[.$(OUT_DIR)]cls_complex_float.exe -
- ! [.$(OUT_DIR)]cls_complex_longdouble.exe -
[.$(OUT_DIR)]cls_complex_struct_double.exe -
[.$(OUT_DIR)]cls_complex_struct_float.exe -
- ! [.$(OUT_DIR)]cls_complex_struct_longdouble.exe -
- ! [.$(OUT_DIR)]cls_complex_va_double.exe -
- ! [.$(OUT_DIR)]cls_complex_va_float.exe -
- ! [.$(OUT_DIR)]cls_complex_va_longdouble.exe -
[.$(OUT_DIR)]complex_double.exe -
[.$(OUT_DIR)]complex_float.exe -
- ! [.$(OUT_DIR)]complex_int.exe -
- ! [.$(OUT_DIR)]complex_longdouble.exe -
[.$(OUT_DIR)]many_complex_double.exe -
[.$(OUT_DIR)]many_complex_float.exe -
- ! [.$(OUT_DIR)]many_complex_longdouble.exe -
[.$(OUT_DIR)]return_complex_double.exe -
[.$(OUT_DIR)]return_complex_float.exe -
- ! [.$(OUT_DIR)]return_complex_longdouble.exe -
[.$(OUT_DIR)]return_complex1_double.exe -
[.$(OUT_DIR)]return_complex1_float.exe -
- ! [.$(OUT_DIR)]return_complex1_longdouble.exe -
[.$(OUT_DIR)]return_complex2_double.exe -
[.$(OUT_DIR)]return_complex2_float.exe -
- ! [.$(OUT_DIR)]return_complex2_longdouble.exe -

TESTBH_FILES = -
[.$(OUT_DIR)]test-call.exe -
[.$(OUT_DIR)]test-callback.exe -

TESTSUITE : $(TESTCALL_FILES) $(TESTCLOSURE_FILES) $(TESTCOMPLEX_FILES) $(TESTBH_FILES)
    purge [...]
    copy [.VMS.X86]RUN_*.COM $(X86HOST)"$(X86USER) $(X86PASSWORD)"::$(X86DISK):[$(X86USER).libffi] /repl
    copy [.$(OUT_DIR)]*.EXE $(X86HOST)"$(X86USER) $(X86PASSWORD)"::$(X86DISK):[$(X86USER).libffi] /repl
    ! copy [.$(OBJ_DIR)]*.OBJ $(X86HOST)"$(X86USER) $(X86PASSWORD)"::$(X86DISK):[$(X86USER).libffi] /repl
    ! ok

[.$(OUT_DIR)]align_mixed.exe : [.$(OBJ_DIR)]align_mixed.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]align_stdcall.exe : [.$(OBJ_DIR)]align_stdcall.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]err_bad_typedef.exe : [.$(OBJ_DIR)]err_bad_typedef.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float_va.exe : [.$(OBJ_DIR)]float_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float.exe : [.$(OBJ_DIR)]float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float1.exe : [.$(OBJ_DIR)]float1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float2.exe : [.$(OBJ_DIR)]float2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float3.exe : [.$(OBJ_DIR)]float3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]float4.exe : [.$(OBJ_DIR)]float4.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many_double.exe : [.$(OBJ_DIR)]many_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many_mixed.exe : [.$(OBJ_DIR)]many_mixed.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many.exe : [.$(OBJ_DIR)]many.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many2.exe : [.$(OBJ_DIR)]many2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]negint.exe : [.$(OBJ_DIR)]negint.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]offsets.exe : [.$(OBJ_DIR)]offsets.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]pr1172638.exe : [.$(OBJ_DIR)]pr1172638.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]promotion.exe : [.$(OBJ_DIR)]promotion.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]pyobjc-tc.exe : [.$(OBJ_DIR)]pyobjc-tc.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_dbl.exe : [.$(OBJ_DIR)]return_dbl.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_dbl1.exe : [.$(OBJ_DIR)]return_dbl1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_dbl2.exe : [.$(OBJ_DIR)]return_dbl2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_fl.exe : [.$(OBJ_DIR)]return_fl.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_fl1.exe : [.$(OBJ_DIR)]return_fl1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_fl2.exe : [.$(OBJ_DIR)]return_fl2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_fl3.exe : [.$(OBJ_DIR)]return_fl3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_ldl.exe : [.$(OBJ_DIR)]return_ldl.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_ll.exe : [.$(OBJ_DIR)]return_ll.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_ll1.exe : [.$(OBJ_DIR)]return_ll1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_sc.exe : [.$(OBJ_DIR)]return_sc.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_sl.exe : [.$(OBJ_DIR)]return_sl.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_uc.exe : [.$(OBJ_DIR)]return_uc.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_ul.exe : [.$(OBJ_DIR)]return_ul.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]strlen.exe : [.$(OBJ_DIR)]strlen.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]strlen2.exe : [.$(OBJ_DIR)]strlen2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]strlen3.exe : [.$(OBJ_DIR)]strlen3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]strlen4.exe : [.$(OBJ_DIR)]strlen4.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct1.exe : [.$(OBJ_DIR)]struct1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct2.exe : [.$(OBJ_DIR)]struct2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct3.exe : [.$(OBJ_DIR)]struct3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct4.exe : [.$(OBJ_DIR)]struct4.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct5.exe : [.$(OBJ_DIR)]struct5.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct6.exe : [.$(OBJ_DIR)]struct6.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct7.exe : [.$(OBJ_DIR)]struct7.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct8.exe : [.$(OBJ_DIR)]struct8.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct9.exe : [.$(OBJ_DIR)]struct9.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]struct10.exe : [.$(OBJ_DIR)]struct10.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]uninitialized.exe : [.$(OBJ_DIR)]uninitialized.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]va_1.exe : [.$(OBJ_DIR)]va_1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]va_struct1.exe : [.$(OBJ_DIR)]va_struct1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]va_struct2.exe : [.$(OBJ_DIR)]va_struct2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]va_struct3.exe : [.$(OBJ_DIR)]va_struct3.obj, $(LIBFFI_LIB)

[.$(OBJ_DIR)]align_mixed.obj : [.testsuite.libffi^.call]align_mixed.c $(HEADERS)
[.$(OBJ_DIR)]align_stdcall.obj : [.testsuite.libffi^.call]align_stdcall.c $(HEADERS)
[.$(OBJ_DIR)]err_bad_typedef.obj : [.testsuite.libffi^.call]err_bad_typedef.c $(HEADERS)
[.$(OBJ_DIR)]float_va.obj : [.testsuite.libffi^.call]float_va.c $(HEADERS)
[.$(OBJ_DIR)]float.obj : [.testsuite.libffi^.call]float.c $(HEADERS)
[.$(OBJ_DIR)]float1.obj : [.testsuite.libffi^.call]float1.c $(HEADERS)
[.$(OBJ_DIR)]float2.obj : [.testsuite.libffi^.call]float2.c $(HEADERS)
[.$(OBJ_DIR)]float3.obj : [.testsuite.libffi^.call]float3.c $(HEADERS)
[.$(OBJ_DIR)]float4.obj : [.testsuite.libffi^.call]float4.c $(HEADERS)
[.$(OBJ_DIR)]many_double.obj : [.testsuite.libffi^.call]many_double.c $(HEADERS)
[.$(OBJ_DIR)]many_mixed.obj : [.testsuite.libffi^.call]many_mixed.c $(HEADERS)
[.$(OBJ_DIR)]many.obj : [.testsuite.libffi^.call]many.c $(HEADERS)
[.$(OBJ_DIR)]many2.obj : [.testsuite.libffi^.call]many2.c $(HEADERS)
[.$(OBJ_DIR)]negint.obj : [.testsuite.libffi^.call]negint.c $(HEADERS)
[.$(OBJ_DIR)]offsets.obj : [.testsuite.libffi^.call]offsets.c $(HEADERS)
[.$(OBJ_DIR)]pr1172638.obj : [.testsuite.libffi^.call]pr1172638.c $(HEADERS)
[.$(OBJ_DIR)]promotion.obj : [.testsuite.libffi^.call]promotion.c $(HEADERS)
[.$(OBJ_DIR)]pyobjc-tc.obj : [.testsuite.libffi^.call]pyobjc-tc.c $(HEADERS)
[.$(OBJ_DIR)]return_dbl.obj : [.testsuite.libffi^.call]return_dbl.c $(HEADERS)
[.$(OBJ_DIR)]return_dbl1.obj : [.testsuite.libffi^.call]return_dbl1.c $(HEADERS)
[.$(OBJ_DIR)]return_dbl2.obj : [.testsuite.libffi^.call]return_dbl2.c $(HEADERS)
[.$(OBJ_DIR)]return_fl.obj : [.testsuite.libffi^.call]return_fl.c $(HEADERS)
[.$(OBJ_DIR)]return_fl1.obj : [.testsuite.libffi^.call]return_fl1.c $(HEADERS)
[.$(OBJ_DIR)]return_fl2.obj : [.testsuite.libffi^.call]return_fl2.c $(HEADERS)
[.$(OBJ_DIR)]return_fl3.obj : [.testsuite.libffi^.call]return_fl3.c $(HEADERS)
[.$(OBJ_DIR)]return_ldl.obj : [.testsuite.libffi^.call]return_ldl.c $(HEADERS)
[.$(OBJ_DIR)]return_ll.obj : [.testsuite.libffi^.call]return_ll.c $(HEADERS)
[.$(OBJ_DIR)]return_ll1.obj : [.testsuite.libffi^.call]return_ll1.c $(HEADERS)
[.$(OBJ_DIR)]return_sc.obj : [.testsuite.libffi^.call]return_sc.c $(HEADERS)
[.$(OBJ_DIR)]return_sl.obj : [.testsuite.libffi^.call]return_sl.c $(HEADERS)
[.$(OBJ_DIR)]return_uc.obj : [.testsuite.libffi^.call]return_uc.c $(HEADERS)
[.$(OBJ_DIR)]return_ul.obj : [.testsuite.libffi^.call]return_ul.c $(HEADERS)
[.$(OBJ_DIR)]strlen.obj : [.testsuite.libffi^.call]strlen.c $(HEADERS)
[.$(OBJ_DIR)]strlen2.obj : [.testsuite.libffi^.call]strlen2.c $(HEADERS)
[.$(OBJ_DIR)]strlen3.obj : [.testsuite.libffi^.call]strlen3.c $(HEADERS)
[.$(OBJ_DIR)]strlen4.obj : [.testsuite.libffi^.call]strlen4.c $(HEADERS)
[.$(OBJ_DIR)]struct1.obj : [.testsuite.libffi^.call]struct1.c $(HEADERS)
[.$(OBJ_DIR)]struct2.obj : [.testsuite.libffi^.call]struct2.c $(HEADERS)
[.$(OBJ_DIR)]struct3.obj : [.testsuite.libffi^.call]struct3.c $(HEADERS)
[.$(OBJ_DIR)]struct4.obj : [.testsuite.libffi^.call]struct4.c $(HEADERS)
[.$(OBJ_DIR)]struct5.obj : [.testsuite.libffi^.call]struct5.c $(HEADERS)
[.$(OBJ_DIR)]struct6.obj : [.testsuite.libffi^.call]struct6.c $(HEADERS)
[.$(OBJ_DIR)]struct7.obj : [.testsuite.libffi^.call]struct7.c $(HEADERS)
[.$(OBJ_DIR)]struct8.obj : [.testsuite.libffi^.call]struct8.c $(HEADERS)
[.$(OBJ_DIR)]struct9.obj : [.testsuite.libffi^.call]struct9.c $(HEADERS)
[.$(OBJ_DIR)]struct10.obj : [.testsuite.libffi^.call]struct10.c $(HEADERS)
[.$(OBJ_DIR)]uninitialized.obj : [.testsuite.libffi^.call]uninitialized.c $(HEADERS)

[.$(OBJ_DIR)]va_1.obj : [.testsuite.libffi^.call]va_1.c $(HEADERS)
[.$(OBJ_DIR)]va_struct1.obj : [.testsuite.libffi^.call]va_struct1.c $(HEADERS)
[.$(OBJ_DIR)]va_struct2.obj : [.testsuite.libffi^.call]va_struct2.c $(HEADERS)
[.$(OBJ_DIR)]va_struct3.obj : [.testsuite.libffi^.call]va_struct3.c $(HEADERS)

[.$(OUT_DIR)]closure_fn0.exe : [.$(OBJ_DIR)]closure_fn0.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn1.exe : [.$(OBJ_DIR)]closure_fn1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn2.exe : [.$(OBJ_DIR)]closure_fn2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn3.exe : [.$(OBJ_DIR)]closure_fn3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn4.exe : [.$(OBJ_DIR)]closure_fn4.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn5.exe : [.$(OBJ_DIR)]closure_fn5.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_fn6.exe : [.$(OBJ_DIR)]closure_fn6.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_loc_fn0.exe : [.$(OBJ_DIR)]closure_loc_fn0.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]closure_simple.exe : [.$(OBJ_DIR)]closure_simple.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_1_1byte.exe : [.$(OBJ_DIR)]cls_1_1byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_2byte.exe : [.$(OBJ_DIR)]cls_2byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_3_1byte.exe : [.$(OBJ_DIR)]cls_3_1byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_3byte1.exe : [.$(OBJ_DIR)]cls_3byte1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_3byte2.exe : [.$(OBJ_DIR)]cls_3byte2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_3float.exe : [.$(OBJ_DIR)]cls_3float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_4_1byte.exe : [.$(OBJ_DIR)]cls_4_1byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_4byte.exe : [.$(OBJ_DIR)]cls_4byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_5_1_byte.exe : [.$(OBJ_DIR)]cls_5_1_byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_5byte.exe : [.$(OBJ_DIR)]cls_5byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_6_1_byte.exe : [.$(OBJ_DIR)]cls_6_1_byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_6byte.exe : [.$(OBJ_DIR)]cls_6byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_7_1_byte.exe : [.$(OBJ_DIR)]cls_7_1_byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_7byte.exe : [.$(OBJ_DIR)]cls_7byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_8byte.exe : [.$(OBJ_DIR)]cls_8byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_9byte1.exe : [.$(OBJ_DIR)]cls_9byte1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_9byte2.exe : [.$(OBJ_DIR)]cls_9byte2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_12byte.exe : [.$(OBJ_DIR)]cls_12byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_16byte.exe : [.$(OBJ_DIR)]cls_16byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_18byte.exe : [.$(OBJ_DIR)]cls_18byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_19byte.exe : [.$(OBJ_DIR)]cls_19byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_20byte.exe : [.$(OBJ_DIR)]cls_20byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_20byte1.exe : [.$(OBJ_DIR)]cls_20byte1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_24byte.exe : [.$(OBJ_DIR)]cls_24byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_64byte.exe : [.$(OBJ_DIR)]cls_64byte.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_double.exe : [.$(OBJ_DIR)]cls_align_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_float.exe : [.$(OBJ_DIR)]cls_align_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_longdouble_split.exe : [.$(OBJ_DIR)]cls_align_longdouble_split.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_longdouble_split2.exe : [.$(OBJ_DIR)]cls_align_longdouble_split2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_longdouble.exe : [.$(OBJ_DIR)]cls_align_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_pointer.exe : [.$(OBJ_DIR)]cls_align_pointer.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_sint16.exe : [.$(OBJ_DIR)]cls_align_sint16.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_sint32.exe : [.$(OBJ_DIR)]cls_align_sint32.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_sint64.exe : [.$(OBJ_DIR)]cls_align_sint64.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_uint16.exe : [.$(OBJ_DIR)]cls_align_uint16.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_uint32.exe : [.$(OBJ_DIR)]cls_align_uint32.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_uint64.exe : [.$(OBJ_DIR)]cls_align_uint64.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_dbls_struct.exe : [.$(OBJ_DIR)]cls_dbls_struct.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_double_va.exe : [.$(OBJ_DIR)]cls_double_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_double.exe : [.$(OBJ_DIR)]cls_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_float.exe : [.$(OBJ_DIR)]cls_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_longdouble_va.exe : [.$(OBJ_DIR)]cls_longdouble_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_longdouble.exe : [.$(OBJ_DIR)]cls_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_many_mixed_args.exe : [.$(OBJ_DIR)]cls_many_mixed_args.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_many_mixed_float_double.exe : [.$(OBJ_DIR)]cls_many_mixed_float_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_schar.exe : [.$(OBJ_DIR)]cls_multi_schar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_sshort.exe : [.$(OBJ_DIR)]cls_multi_sshort.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_sshortchar.exe : [.$(OBJ_DIR)]cls_multi_sshortchar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_uchar.exe : [.$(OBJ_DIR)]cls_multi_uchar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_ushort.exe : [.$(OBJ_DIR)]cls_multi_ushort.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_multi_ushortchar.exe : [.$(OBJ_DIR)]cls_multi_ushortchar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_pointer_stack.exe : [.$(OBJ_DIR)]cls_pointer_stack.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_pointer.exe : [.$(OBJ_DIR)]cls_pointer.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_schar.exe : [.$(OBJ_DIR)]cls_schar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_sint.exe : [.$(OBJ_DIR)]cls_sint.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_sshort.exe : [.$(OBJ_DIR)]cls_sshort.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_struct_va1.exe : [.$(OBJ_DIR)]cls_struct_va1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_uchar_va.exe : [.$(OBJ_DIR)]cls_uchar_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_uchar.exe : [.$(OBJ_DIR)]cls_uchar.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_uint_va.exe : [.$(OBJ_DIR)]cls_uint_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_uint.exe : [.$(OBJ_DIR)]cls_uint.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_ulong_va.exe : [.$(OBJ_DIR)]cls_ulong_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_ulonglong.exe : [.$(OBJ_DIR)]cls_ulonglong.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_ushort_va.exe : [.$(OBJ_DIR)]cls_ushort_va.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_ushort.exe : [.$(OBJ_DIR)]cls_ushort.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]err_bad_abi.exe : [.$(OBJ_DIR)]err_bad_abi.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]huge_struct.exe : [.$(OBJ_DIR)]huge_struct.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct.exe : [.$(OBJ_DIR)]nested_struct.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct1.exe : [.$(OBJ_DIR)]nested_struct1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct2.exe : [.$(OBJ_DIR)]nested_struct2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct3.exe : [.$(OBJ_DIR)]nested_struct3.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct4.exe : [.$(OBJ_DIR)]nested_struct4.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct5.exe : [.$(OBJ_DIR)]nested_struct5.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct6.exe : [.$(OBJ_DIR)]nested_struct6.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct7.exe : [.$(OBJ_DIR)]nested_struct7.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct8.exe : [.$(OBJ_DIR)]nested_struct8.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct9.exe : [.$(OBJ_DIR)]nested_struct9.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct10.exe : [.$(OBJ_DIR)]nested_struct10.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]nested_struct11.exe : [.$(OBJ_DIR)]nested_struct11.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]problem1.exe : [.$(OBJ_DIR)]problem1.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]stret_large.exe : [.$(OBJ_DIR)]stret_large.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]stret_large2.exe : [.$(OBJ_DIR)]stret_large2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]stret_medium.exe : [.$(OBJ_DIR)]stret_medium.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]stret_medium2.exe : [.$(OBJ_DIR)]stret_medium2.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]testclosure.exe : [.$(OBJ_DIR)]testclosure.obj, $(LIBFFI_LIB)

[.$(OBJ_DIR)]closure_simple.obj : [.testsuite.libffi^.closures]closure_simple.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn0.obj : [.testsuite.libffi^.closures]closure_fn0.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn1.obj : [.testsuite.libffi^.closures]closure_fn1.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn2.obj : [.testsuite.libffi^.closures]closure_fn2.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn3.obj : [.testsuite.libffi^.closures]closure_fn3.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn4.obj : [.testsuite.libffi^.closures]closure_fn4.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn5.obj : [.testsuite.libffi^.closures]closure_fn5.c $(HEADERS)
[.$(OBJ_DIR)]closure_fn6.obj : [.testsuite.libffi^.closures]closure_fn6.c $(HEADERS)
[.$(OBJ_DIR)]closure_loc_fn0.obj : [.testsuite.libffi^.closures]closure_loc_fn0.c $(HEADERS)
[.$(OBJ_DIR)]closure_simple.obj : [.testsuite.libffi^.closures]closure_simple.c $(HEADERS)
[.$(OBJ_DIR)]cls_1_1byte.obj : [.testsuite.libffi^.closures]cls_1_1byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_2byte.obj : [.testsuite.libffi^.closures]cls_2byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_3_1byte.obj : [.testsuite.libffi^.closures]cls_3_1byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_3byte1.obj : [.testsuite.libffi^.closures]cls_3byte1.c $(HEADERS)
[.$(OBJ_DIR)]cls_3byte2.obj : [.testsuite.libffi^.closures]cls_3byte2.c $(HEADERS)
[.$(OBJ_DIR)]cls_3float.obj : [.testsuite.libffi^.closures]cls_3float.c $(HEADERS)
[.$(OBJ_DIR)]cls_4_1byte.obj : [.testsuite.libffi^.closures]cls_4_1byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_4byte.obj : [.testsuite.libffi^.closures]cls_4byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_5_1_byte.obj : [.testsuite.libffi^.closures]cls_5_1_byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_5byte.obj : [.testsuite.libffi^.closures]cls_5byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_6_1_byte.obj : [.testsuite.libffi^.closures]cls_6_1_byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_6byte.obj : [.testsuite.libffi^.closures]cls_6byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_7_1_byte.obj : [.testsuite.libffi^.closures]cls_7_1_byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_7byte.obj : [.testsuite.libffi^.closures]cls_7byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_8byte.obj : [.testsuite.libffi^.closures]cls_8byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_9byte1.obj : [.testsuite.libffi^.closures]cls_9byte1.c $(HEADERS)
[.$(OBJ_DIR)]cls_9byte2.obj : [.testsuite.libffi^.closures]cls_9byte2.c $(HEADERS)
[.$(OBJ_DIR)]cls_12byte.obj : [.testsuite.libffi^.closures]cls_12byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_16byte.obj : [.testsuite.libffi^.closures]cls_16byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_18byte.obj : [.testsuite.libffi^.closures]cls_18byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_19byte.obj : [.testsuite.libffi^.closures]cls_19byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_20byte.obj : [.testsuite.libffi^.closures]cls_20byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_20byte1.obj : [.testsuite.libffi^.closures]cls_20byte1.c $(HEADERS)
[.$(OBJ_DIR)]cls_24byte.obj : [.testsuite.libffi^.closures]cls_24byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_64byte.obj : [.testsuite.libffi^.closures]cls_64byte.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_double.obj : [.testsuite.libffi^.closures]cls_align_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_float.obj : [.testsuite.libffi^.closures]cls_align_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_longdouble_split.obj : [.testsuite.libffi^.closures]cls_align_longdouble_split.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_longdouble_split2.obj : [.testsuite.libffi^.closures]cls_align_longdouble_split2.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_longdouble.obj : [.testsuite.libffi^.closures]cls_align_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_pointer.obj : [.testsuite.libffi^.closures]cls_align_pointer.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_sint16.obj : [.testsuite.libffi^.closures]cls_align_sint16.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_sint32.obj : [.testsuite.libffi^.closures]cls_align_sint32.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_sint64.obj : [.testsuite.libffi^.closures]cls_align_sint64.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_uint16.obj : [.testsuite.libffi^.closures]cls_align_uint16.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_uint32.obj : [.testsuite.libffi^.closures]cls_align_uint32.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_uint64.obj : [.testsuite.libffi^.closures]cls_align_uint64.c $(HEADERS)
[.$(OBJ_DIR)]cls_dbls_struct.obj : [.testsuite.libffi^.closures]cls_dbls_struct.c $(HEADERS)
[.$(OBJ_DIR)]cls_double_va.obj : [.testsuite.libffi^.closures]cls_double_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_double.obj : [.testsuite.libffi^.closures]cls_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_float.obj : [.testsuite.libffi^.closures]cls_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_longdouble_va.obj : [.testsuite.libffi^.closures]cls_longdouble_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_longdouble.obj : [.testsuite.libffi^.closures]cls_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]cls_many_mixed_args.obj : [.testsuite.libffi^.closures]cls_many_mixed_args.c $(HEADERS)
[.$(OBJ_DIR)]cls_many_mixed_float_double.obj : [.testsuite.libffi^.closures]cls_many_mixed_float_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_schar.obj : [.testsuite.libffi^.closures]cls_multi_schar.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_sshort.obj : [.testsuite.libffi^.closures]cls_multi_sshort.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_sshortchar.obj : [.testsuite.libffi^.closures]cls_multi_sshortchar.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_uchar.obj : [.testsuite.libffi^.closures]cls_multi_uchar.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_ushort.obj : [.testsuite.libffi^.closures]cls_multi_ushort.c $(HEADERS)
[.$(OBJ_DIR)]cls_multi_ushortchar.obj : [.testsuite.libffi^.closures]cls_multi_ushortchar.c $(HEADERS)
[.$(OBJ_DIR)]cls_pointer_stack.obj : [.testsuite.libffi^.closures]cls_pointer_stack.c $(HEADERS)
[.$(OBJ_DIR)]cls_pointer.obj : [.testsuite.libffi^.closures]cls_pointer.c $(HEADERS)
[.$(OBJ_DIR)]cls_schar.obj : [.testsuite.libffi^.closures]cls_schar.c $(HEADERS)
[.$(OBJ_DIR)]cls_sint.obj : [.testsuite.libffi^.closures]cls_sint.c $(HEADERS)
[.$(OBJ_DIR)]cls_sshort.obj : [.testsuite.libffi^.closures]cls_sshort.c $(HEADERS)
[.$(OBJ_DIR)]cls_struct_va1.obj : [.testsuite.libffi^.closures]cls_struct_va1.c $(HEADERS)
[.$(OBJ_DIR)]cls_uchar_va.obj : [.testsuite.libffi^.closures]cls_uchar_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_uchar.obj : [.testsuite.libffi^.closures]cls_uchar.c $(HEADERS)
[.$(OBJ_DIR)]cls_uint_va.obj : [.testsuite.libffi^.closures]cls_uint_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_uint.obj : [.testsuite.libffi^.closures]cls_uint.c $(HEADERS)
[.$(OBJ_DIR)]cls_ulong_va.obj : [.testsuite.libffi^.closures]cls_ulong_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_ulonglong.obj : [.testsuite.libffi^.closures]cls_ulonglong.c $(HEADERS)
[.$(OBJ_DIR)]cls_ushort_va.obj : [.testsuite.libffi^.closures]cls_ushort_va.c $(HEADERS)
[.$(OBJ_DIR)]cls_ushort.obj : [.testsuite.libffi^.closures]cls_ushort.c $(HEADERS)
[.$(OBJ_DIR)]err_bad_abi.obj : [.testsuite.libffi^.closures]err_bad_abi.c $(HEADERS)
[.$(OBJ_DIR)]huge_struct.obj : [.testsuite.libffi^.closures]huge_struct.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct.obj : [.testsuite.libffi^.closures]nested_struct.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct1.obj : [.testsuite.libffi^.closures]nested_struct1.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct2.obj : [.testsuite.libffi^.closures]nested_struct2.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct3.obj : [.testsuite.libffi^.closures]nested_struct3.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct4.obj : [.testsuite.libffi^.closures]nested_struct4.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct5.obj : [.testsuite.libffi^.closures]nested_struct5.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct6.obj : [.testsuite.libffi^.closures]nested_struct6.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct7.obj : [.testsuite.libffi^.closures]nested_struct7.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct8.obj : [.testsuite.libffi^.closures]nested_struct8.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct9.obj : [.testsuite.libffi^.closures]nested_struct9.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct10.obj : [.testsuite.libffi^.closures]nested_struct10.c $(HEADERS)
[.$(OBJ_DIR)]nested_struct11.obj : [.testsuite.libffi^.closures]nested_struct11.c $(HEADERS)
[.$(OBJ_DIR)]problem1.obj : [.testsuite.libffi^.closures]problem1.c $(HEADERS)
[.$(OBJ_DIR)]stret_large.obj : [.testsuite.libffi^.closures]stret_large.c $(HEADERS)
[.$(OBJ_DIR)]stret_large2.obj : [.testsuite.libffi^.closures]stret_large2.c $(HEADERS)
[.$(OBJ_DIR)]stret_medium.obj : [.testsuite.libffi^.closures]stret_medium.c $(HEADERS)
[.$(OBJ_DIR)]stret_medium2.obj : [.testsuite.libffi^.closures]stret_medium2.c $(HEADERS)
[.$(OBJ_DIR)]testclosure.obj : [.testsuite.libffi^.closures]testclosure.c $(HEADERS)

[.$(OUT_DIR)]cls_align_complex_double.exe : [.$(OBJ_DIR)]cls_align_complex_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_complex_float.exe : [.$(OBJ_DIR)]cls_align_complex_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_align_complex_longdouble.exe : [.$(OBJ_DIR)]cls_align_complex_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_double.exe : [.$(OBJ_DIR)]cls_complex_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_float.exe : [.$(OBJ_DIR)]cls_complex_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_longdouble.exe : [.$(OBJ_DIR)]cls_complex_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_struct_double.exe : [.$(OBJ_DIR)]cls_complex_struct_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_struct_float.exe : [.$(OBJ_DIR)]cls_complex_struct_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_struct_longdouble.exe : [.$(OBJ_DIR)]cls_complex_struct_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_va_double.exe : [.$(OBJ_DIR)]cls_complex_va_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_va_float.exe : [.$(OBJ_DIR)]cls_complex_va_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]cls_complex_va_longdouble.exe : [.$(OBJ_DIR)]cls_complex_va_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]complex_double.exe : [.$(OBJ_DIR)]complex_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]complex_float.exe : [.$(OBJ_DIR)]complex_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]complex_int.exe : [.$(OBJ_DIR)]complex_int.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]complex_longdouble.exe : [.$(OBJ_DIR)]complex_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]complex.exexe : [.$(OBJ_DIR)]complex.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]ffitest.exe : [.$(OBJ_DIR)]ffitest.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many_complex_double.exe : [.$(OBJ_DIR)]many_complex_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many_complex_float.exe : [.$(OBJ_DIR)]many_complex_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]many_complex_longdouble.exe : [.$(OBJ_DIR)]many_complex_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex_double.exe : [.$(OBJ_DIR)]return_complex_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex_float.exe : [.$(OBJ_DIR)]return_complex_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex_longdouble.exe : [.$(OBJ_DIR)]return_complex_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex1_double.exe : [.$(OBJ_DIR)]return_complex1_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex1_float.exe : [.$(OBJ_DIR)]return_complex1_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex1_longdouble.exe : [.$(OBJ_DIR)]return_complex1_longdouble.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex2_double.exe : [.$(OBJ_DIR)]return_complex2_double.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex2_float.exe : [.$(OBJ_DIR)]return_complex2_float.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]return_complex2_longdouble.exe : [.$(OBJ_DIR)]return_complex2_longdouble.obj, $(LIBFFI_LIB)

[.$(OBJ_DIR)]cls_align_complex_double.obj : [.testsuite.libffi^.complex]cls_align_complex_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_complex_float.obj : [.testsuite.libffi^.complex]cls_align_complex_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_align_complex_longdouble.obj : [.testsuite.libffi^.complex]cls_align_complex_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_double.obj : [.testsuite.libffi^.complex]cls_complex_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_float.obj : [.testsuite.libffi^.complex]cls_complex_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_longdouble.obj : [.testsuite.libffi^.complex]cls_complex_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_struct_double.obj : [.testsuite.libffi^.complex]cls_complex_struct_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_struct_float.obj : [.testsuite.libffi^.complex]cls_complex_struct_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_struct_longdouble.obj : [.testsuite.libffi^.complex]cls_complex_struct_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_va_double.obj : [.testsuite.libffi^.complex]cls_complex_va_double.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_va_float.obj : [.testsuite.libffi^.complex]cls_complex_va_float.c $(HEADERS)
[.$(OBJ_DIR)]cls_complex_va_longdouble.obj : [.testsuite.libffi^.complex]cls_complex_va_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]complex_double.obj : [.testsuite.libffi^.complex]complex_double.c $(HEADERS)
[.$(OBJ_DIR)]complex_float.obj : [.testsuite.libffi^.complex]complex_float.c $(HEADERS)
[.$(OBJ_DIR)]complex_int.obj : [.testsuite.libffi^.complex]complex_int.c $(HEADERS)
[.$(OBJ_DIR)]complex_longdouble.obj : [.testsuite.libffi^.complex]complex_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]complex.exexe : [.testsuite.libffi^.complex]complex.c $(HEADERS)
[.$(OBJ_DIR)]ffitest.obj : [.testsuite.libffi^.complex]ffitest.c $(HEADERS)
[.$(OBJ_DIR)]many_complex_double.obj : [.testsuite.libffi^.complex]many_complex_double.c $(HEADERS)
[.$(OBJ_DIR)]many_complex_float.obj : [.testsuite.libffi^.complex]many_complex_float.c $(HEADERS)
[.$(OBJ_DIR)]many_complex_longdouble.obj : [.testsuite.libffi^.complex]many_complex_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]return_complex_double.obj : [.testsuite.libffi^.complex]return_complex_double.c $(HEADERS)
[.$(OBJ_DIR)]return_complex_float.obj : [.testsuite.libffi^.complex]return_complex_float.c $(HEADERS)
[.$(OBJ_DIR)]return_complex_longdouble.obj : [.testsuite.libffi^.complex]return_complex_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]return_complex1_double.obj : [.testsuite.libffi^.complex]return_complex1_double.c $(HEADERS)
[.$(OBJ_DIR)]return_complex1_float.obj : [.testsuite.libffi^.complex]return_complex1_float.c $(HEADERS)
[.$(OBJ_DIR)]return_complex1_longdouble.obj : [.testsuite.libffi^.complex]return_complex1_longdouble.c $(HEADERS)
[.$(OBJ_DIR)]return_complex2_double.obj : [.testsuite.libffi^.complex]return_complex2_double.c $(HEADERS)
[.$(OBJ_DIR)]return_complex2_float.obj : [.testsuite.libffi^.complex]return_complex2_float.c $(HEADERS)
[.$(OBJ_DIR)]return_complex2_longdouble.obj : [.testsuite.libffi^.complex]return_complex2_longdouble.c $(HEADERS)

[.$(OUT_DIR)]test-call.exe : [.$(OBJ_DIR)]test-call.obj, $(LIBFFI_LIB)
[.$(OUT_DIR)]test-callback.exe : [.$(OBJ_DIR)]test-callback.obj, $(LIBFFI_LIB)

[.$(OBJ_DIR)]test-call.obj : [.testsuite.libffi^.bhaible]test-call.c $(HEADERS)
[.$(OBJ_DIR)]test-callback.obj : [.testsuite.libffi^.bhaible]test-callback.c $(HEADERS)
