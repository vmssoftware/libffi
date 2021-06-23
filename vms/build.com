$ set verify
$
$ delete/log/noconf *.obj;*
$
$ call doit 32
$ call doit 64
$
$ exit
$
$ doit: subroutine
$ define cc$include [.include],[.vms.include],[.vms],[.src.ia64],[.src]
$ ccopt = "/names=(as_is,shortened)/noopt/pointer=''p1'/list/define=(HAVE_CONFIG_H,_USE_STD_STAT,_POSIX_EXIT)/include=cc$include/float=ieee/ieee_mode=fast"
$
$ cc'ccopt' [.src]prep_cif.c
$ cc'ccopt' [.src]types.c
$ cc'ccopt' [.src]raw_api.c
$ cc'ccopt' [.src]java_raw_api.c
$ cc'ccopt' [.src]closures.c
$ cc'ccopt' [.src.ia64]ffi.c
$
$! iasi64 doesn't much like life if decc$file_sharing is defined...
$!
$ if f$trnlnm("DECC$FILE_SHARING", "lnm$job") .nes. ""
$ then
$    deassign/job DECC$FILE_SHARING
$ endif
$
$ cc/nolist/include=cc$include/preproc/noline [.src.ia64]vms.S
$ iasi64 "-Milp64" "-o" vms.obj "-Wx" "-N" "vms_upcase" vms.I
$ delete/log/noconf vms.I;*
$
$ olb = "libffi''p1'.olb"
$ lib/create 'olb'
$ purge/log
$
$ lib/insert 'olb' closures.obj
$ lib/insert 'olb' ffi.obj
$ lib/insert 'olb' java_raw_api.obj
$ lib/insert 'olb' prep_cif.obj
$ lib/insert 'olb' raw_api.obj
$ lib/insert 'olb' types.obj
$ lib/insert 'olb' vms.obj
$
$ delete/log/noconf *.obj;*
$
$ exe = "libffi$shr''p1'.exe"
$ link/share='exe' 'olb'/lib,options.opt/opt
$ purge/log
$
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn0.c
$ link closure_fn0.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn1.c
$ link closure_fn1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn2.c
$ link closure_fn2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn3.c
$ link closure_fn3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn4.c
$ link closure_fn4.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn5.c
$ link closure_fn5.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_fn6.c
$ link closure_fn6.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_loc_fn0.c
$ link closure_loc_fn0.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]closure_simple.c
$ link closure_simple.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_12byte.c
$ link cls_12byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_16byte.c
$ link cls_16byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_18byte.c
$ link cls_18byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_19byte.c
$ link cls_19byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_1_1byte.c
$ link cls_1_1byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_20byte.c
$ link cls_20byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_20byte1.c
$ link cls_20byte1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_24byte.c
$ link cls_24byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_2byte.c
$ link cls_2byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_3byte1.c
$ link cls_3byte1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_3byte2.c
$ link cls_3byte2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_3_1byte.c
$ link cls_3_1byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_4byte.c
$ link cls_4byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_4_1byte.c
$ link cls_4_1byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_5byte.c
$ link cls_5byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_5_1_byte.c
$ link cls_5_1_byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_64byte.c
$ link cls_64byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_6byte.c
$ link cls_6byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_6_1_byte.c
$ link cls_6_1_byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_7byte.c
$ link cls_7byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_7_1_byte.c
$ link cls_7_1_byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_8byte.c
$ link cls_8byte.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_9byte1.c
$ link cls_9byte1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_9byte2.c
$ link cls_9byte2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_double.c
$ link cls_align_double.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_float.c
$ link cls_align_float.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_longdouble.c
$ link cls_align_longdouble.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_longdouble_split.c
$ link cls_align_longdouble_split.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_longdouble_split2.c
$ link cls_align_longdouble_split2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_pointer.c
$ link cls_align_pointer.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_sint16.c
$ link cls_align_sint16.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_sint32.c
$ link cls_align_sint32.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_sint64.c
$ link cls_align_sint64.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_uint16.c
$ link cls_align_uint16.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_uint32.c
$ link cls_align_uint32.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_align_uint64.c
$ link cls_align_uint64.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_dbls_struct.c
$ link cls_dbls_struct.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_double.c
$ link cls_double.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_double_va.c
$ link cls_double_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_float.c
$ link cls_float.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_longdouble.c
$ link cls_longdouble.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_longdouble_va.c
$ link cls_longdouble_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_schar.c
$ link cls_multi_schar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_sshort.c
$ link cls_multi_sshort.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_sshortchar.c
$ link cls_multi_sshortchar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_uchar.c
$ link cls_multi_uchar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_ushort.c
$ link cls_multi_ushort.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_multi_ushortchar.c
$ link cls_multi_ushortchar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_pointer.c
$ link cls_pointer.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_pointer_stack.c
$ link cls_pointer_stack.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_schar.c
$ link cls_schar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_sint.c
$ link cls_sint.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_sshort.c
$ link cls_sshort.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_struct_va1.c
$ link cls_struct_va1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_uchar.c
$ link cls_uchar.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_uchar_va.c
$ link cls_uchar_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_uint.c
$ link cls_uint.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_uint_va.c
$ link cls_uint_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_ulonglong.c
$ link cls_ulonglong.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_ulong_va.c
$ link cls_ulong_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_ushort.c
$ link cls_ushort.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]cls_ushort_va.c
$ link cls_ushort_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]err_bad_abi.c
$ link err_bad_abi.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]err_bad_typedef.c
$ link err_bad_typedef.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float.c
$ link float.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float1.c
$ link float1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float2.c
$ link float2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float3.c
$ link float3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float4.c
$ link float4.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]float_va.c
$ link float_va.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]huge_struct.c
$ link huge_struct.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]many.c
$ link many.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]many2.c
$ link many2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]negint.c
$ link negint.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct.c
$ link nested_struct.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct1.c
$ link nested_struct1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct10.c
$ link nested_struct10.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct11.c
$ link nested_struct11.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct2.c
$ link nested_struct2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct3.c
$ link nested_struct3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct4.c
$ link nested_struct4.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct5.c
$ link nested_struct5.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct6.c
$ link nested_struct6.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct7.c
$ link nested_struct7.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct8.c
$ link nested_struct8.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]nested_struct9.c
$ link nested_struct9.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]problem1.c
$ link problem1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]promotion.c
$ link promotion.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]pyobjc-tc.c
$ link pyobjc-tc.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_dbl.c
$ link return_dbl.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_dbl1.c
$ link return_dbl1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_dbl2.c
$ link return_dbl2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_fl.c
$ link return_fl.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_fl1.c
$ link return_fl1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_fl2.c
$ link return_fl2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_fl3.c
$ link return_fl3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_ldl.c
$ link return_ldl.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_ll.c
$ link return_ll.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_ll1.c
$ link return_ll1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_sc.c
$ link return_sc.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_sl.c
$ link return_sl.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_uc.c
$ link return_uc.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]return_ul.c
$ link return_ul.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]stret_large.c
$ link stret_large.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]stret_large2.c
$ link stret_large2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]stret_medium.c
$ link stret_medium.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]stret_medium2.c
$ link stret_medium2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]strlen.c
$ link strlen.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]strlen2.c
$ link strlen2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]strlen3.c
$ link strlen3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]strlen4.c
$ link strlen4.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct1.c
$ link struct1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct2.c
$ link struct2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct3.c
$ link struct3.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct4.c
$ link struct4.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct5.c
$ link struct5.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct6.c
$ link struct6.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct7.c
$ link struct7.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct8.c
$ link struct8.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]struct9.c
$ link struct9.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]testclosure.c
$ link testclosure.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]uninitialized.c
$ link uninitialized.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]va_1.c
$ link va_1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]va_struct1.c
$ link va_struct1.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]va_struct2.c
$ link va_struct2.obj,'olb'/lib
$ purge/log
$
$ cc'ccopt' [.testsuite.libffi^.call]va_struct3.c
$ link va_struct3.obj,'olb'/lib
$ purge/log
$
$! Let's run the test suite... Be sure to check for any aborts.
$ @tests.com
$
$ exit
$ endsubroutine
