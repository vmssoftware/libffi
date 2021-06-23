$ set noon
$
$ run closure_fn0.exe
$
$ run closure_fn1.exe
$
$ run closure_fn2.exe
$
$ run closure_fn3.exe
$
$ run closure_fn4.exe
$
$ run closure_fn5.exe
$
$ run closure_fn6.exe
$
$ run closure_loc_fn0.exe
$
$ run closure_simple.exe
$
$ run cls_12byte.exe
$
$ run cls_16byte.exe
$
$ run cls_18byte.exe
$
$ run cls_19byte.exe
$
$ run cls_1_1byte.exe
$
$ run cls_20byte.exe
$
$ run cls_20byte1.exe
$
$ run cls_24byte.exe
$
$ run cls_2byte.exe
$
$ run cls_3byte1.exe
$
$ run cls_3byte2.exe
$
$ run cls_3_1byte.exe
$
$ run cls_4byte.exe
$
$ run cls_4_1byte.exe
$
$ run cls_5byte.exe
$
$ run cls_5_1_byte.exe
$
$ run cls_64byte.exe
$
$ run cls_6byte.exe
$
$ run cls_6_1_byte.exe
$
$ run cls_7byte.exe
$
$ run cls_7_1_byte.exe
$
$ run cls_8byte.exe
$
$ run cls_9byte1.exe
$
$ run cls_9byte2.exe
$
$ run cls_align_double.exe
$
$ run cls_align_float.exe
$
$ run cls_align_longdouble.exe
$
$ run cls_align_longdouble_split.exe
$
$ run cls_align_longdouble_split2.exe
$
$ run cls_align_pointer.exe
$
$ run cls_align_sint16.exe
$
$ run cls_align_sint32.exe
$
$ run cls_align_sint64.exe
$
$ run cls_align_uint16.exe
$
$ run cls_align_uint32.exe
$
$ run cls_align_uint64.exe
$
$ run cls_dbls_struct.exe
$
$ run cls_double.exe
$
$ run cls_double_va.exe
$
$ run cls_float.exe
$
$ run cls_longdouble.exe
$
$ run cls_longdouble_va.exe
$
$ run cls_multi_schar.exe
$
$ run cls_multi_sshort.exe
$
$ run cls_multi_sshortchar.exe
$
$ run cls_multi_uchar.exe
$
$ run cls_multi_ushort.exe
$
$ run cls_multi_ushortchar.exe
$
$ run cls_pointer.exe
$
$ run cls_pointer_stack.exe
$
$ run cls_schar.exe
$
$ run cls_sint.exe
$
$ run cls_sshort.exe
$
$ run cls_struct_va1.exe
$
$ run cls_uchar.exe
$
$ run cls_uchar_va.exe
$
$ run cls_uint.exe
$
$ run cls_uint_va.exe
$
$ run cls_ulonglong.exe
$
$ run cls_ulong_va.exe
$
$ run cls_ushort.exe
$
$ run cls_ushort_va.exe
$
$ run err_bad_abi.exe
$
$ run err_bad_typedef.exe
$
$ run float.exe
$
$ run float1.exe
$
$ run float2.exe
$
$ run float3.exe
$
$ run float4.exe
$
$ run float_va.exe
$
$ run huge_struct.exe
$
$ run many.exe
$
$ run many2.exe
$
$ run negint.exe
$
$ run nested_struct.exe
$
$ run nested_struct1.exe
$
$ run nested_struct10.exe
$
$ run nested_struct11.exe
$
$ run nested_struct2.exe
$
$ run nested_struct3.exe
$
$ run nested_struct4.exe
$
$ run nested_struct5.exe
$
$ run nested_struct6.exe
$
$ run nested_struct7.exe
$
$ run nested_struct8.exe
$
$ run nested_struct9.exe
$
$ run problem1.exe
$
$ run promotion.exe
$
$ run pyobjc-tc.exe
$
$ run return_dbl.exe
$
$ run return_dbl1.exe
$
$ run return_dbl2.exe
$
$ run return_fl.exe
$
$ run return_fl1.exe
$
$ run return_fl2.exe
$
$ run return_fl3.exe
$
$ run return_ldl.exe
$
$ run return_ll.exe
$
$ run return_ll1.exe
$
$ run return_sc.exe
$
$ run return_sl.exe
$
$ run return_uc.exe
$
$ run return_ul.exe
$
$ run stret_large.exe
$
$ run stret_large2.exe
$
$ run stret_medium.exe
$
$ run stret_medium2.exe
$
$ run strlen.exe
$
$ run strlen2.exe
$
$ run strlen3.exe
$
$ run strlen4.exe
$
$ run struct1.exe
$
$ run struct2.exe
$
$ run struct3.exe
$
$ run struct4.exe
$
$ run struct5.exe
$
$ run struct6.exe
$
$ run struct7.exe
$
$ run struct8.exe
$
$ run struct9.exe
$
$ run testclosure.exe
$
$ run uninitialized.exe
$
$ run va_1.exe
$
$ run va_struct1.exe
$
$ run va_struct2.exe
$
$ run va_struct3.exe
$
$ exit
