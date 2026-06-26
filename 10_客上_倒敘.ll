; ModuleID = './test/策問/10_客上_倒敘.wy'
source_filename = "./test/策問/10_客上_倒敘.wy"

declare dllimport i32 @_setmode(i32, i32)
declare dllimport i32 @SetConsoleCP(i32)
declare dllimport i32 @SetConsoleOutputCP(i32)
define dso_local void @utf8_init() {
    %1 = call i32 @_setmode(i32 0, i32 32768)
    %2 = call i32 @_setmode(i32 1, i32 32768)
    %3 = call i32 @SetConsoleCP(i32 65001)
    %4 = call i32 @SetConsoleOutputCP(i32 65001)
    ret void
}
@stdout = global ptr null
declare ptr @__acrt_iob_func(i32)

declare i32 @printf(i8*, ...)
declare i32 @_write(i32, ptr, i32)
declare i64 @fwrite(ptr, i64, i64, ptr)
declare ptr @wy_rt_nth_utf8_char(ptr, i64)
declare ptr @wy_rt_str_concat(ptr, ptr)
declare ptr @wy_rt_array_new(i64)
declare void @wy_rt_array_add_ptr(ptr, ptr)
declare ptr @wy_rt_array_get_ptr(ptr, i64)
declare i64 @wy_rt_array_get_length(ptr)
declare i64 @wy_rt_str_length(ptr)

@fmt_i32_n = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt_i32 = private unnamed_addr constant [3 x i8] c"%d\00"
@fmt_i64_n = private unnamed_addr constant [6 x i8] c"%lld\0A\00"
@fmt_i64 = private unnamed_addr constant [5 x i8] c"%lld\00"
@fmt_float_n = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@fmt_float = private unnamed_addr constant [3 x i8] c"%f\00"
@fmt_double_n = private unnamed_addr constant [4 x i8] c"%g\0A\00"
@fmt_double = private unnamed_addr constant [3 x i8] c"%g\00"
@fmt_ptr_n = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt_ptr = private unnamed_addr constant [3 x i8] c"%s\00"
@space = private unnamed_addr constant [1 x i8] c" "

declare double @llvm.sqrt.f32(float)
declare double @llvm.sqrt.f64(double)
declare double @llvm.pow.f32.f32(float, float)
declare double @llvm.pow.f64.f64(double, double)
@str.0 = private unnamed_addr constant [16 x i8] c"\E5\AE\A2\E4\B8\8A\E5\A4\A9\E7\84\B6\E5\B1\85\00"
@str.1 = private unnamed_addr constant [1 x i8] c"\00"
@str.2 = private unnamed_addr constant [16 x i8] c"\E6\AD\A3\E5\90\91\E8\A7\80\E4\B9\8B\EF\BC\9A\00"
@str.3 = private unnamed_addr constant [16 x i8] c"\E5\80\92\E5\90\91\E8\AE\80\E4\B9\8B\EF\BC\9A\00"
@str_true = private unnamed_addr constant [4 x i8] c"\E9\99\BD\00"
@str_true_n = private unnamed_addr constant [5 x i8] c"\E9\99\BD\0A\00"
@str_false = private unnamed_addr constant [4 x i8] c"\E9\99\B0\00"
@str_false_n = private unnamed_addr constant [5 x i8] c"\E9\99\B0\0A\00"

define i32 @main() {
    call void @utf8_init()
    %_stdout = call ptr @__acrt_iob_func(i32 1)
    store ptr %_stdout, ptr @stdout
    %g_stdout = load ptr, ptr @stdout
    %var.0 = alloca ptr
    store ptr @str.0, ptr %var.0
    %var.1 = alloca i32
    store i32 5, ptr %var.1
    %var.2 = alloca ptr
    store ptr @str.1, ptr %var.2
    %var.3 = alloca i32
    store i32 0, ptr %var.3
        
        br label %loop1.body
    loop1.body:
        %reg1 = load i32, ptr %var.3
        %reg2 = load i32, ptr %var.1
        %r654646eg0 = icmp eq i32 %reg1, %reg2
            br i1 %reg0, label %if2.true, label %if2.false
        if2.true:
            br label %loop1.exit
            br label %if2.false
    if2.false:
        
        %reg4 = load i32, ptr %var.1
        %reg5 = load i32, ptr %var.3
        %r654646eg3 = sub i32 %reg4, %reg5
        %var.4 = alloca i32
        store i32 %reg3, ptr %var.4
        %reg6 = load ptr, ptr %var.0
        %reg7 = load i32, ptr %var.4
        %reg8 = sext i32 %reg7 to i64
        %reg9 = sub i64 %reg8, 1
        %reg10 = call ptr @wy_rt_nth_utf8_char(ptr %reg6, i64 %reg9)
        %var.5 = alloca ptr
        store ptr %reg10, ptr %var.5
        %reg12 = load ptr, ptr %var.2
        %reg13 = load ptr, ptr %var.5
        %r654646eg11 = add ptr %reg12, %reg13
        store ptr %reg11, ptr %var.2
        %reg15 = load i32, ptr %var.3
        %r654646eg14 = add i32 1, %reg15
        store i32 %reg14, ptr %var.3
        br label %loop1.body
    loop1.exit:
        
    call i32 (ptr, ...) @printf(ptr @fmt_ptr, ptr @str.2)
    %reg16 = load ptr, ptr %var.0
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr %reg16)
    call i32 (ptr, ...) @printf(ptr @fmt_ptr, ptr @str.3)
    %reg17 = load ptr, ptr %var.2
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr %reg17)
    ret i32 0
}
