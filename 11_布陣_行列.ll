; ModuleID = './test/策問/11_布陣_行列.wy'
source_filename = "./test/策問/11_布陣_行列.wy"

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
@str.0 = private unnamed_addr constant [4 x i8] c"\E5\AE\AE\00"
@str.1 = private unnamed_addr constant [4 x i8] c"\E5\95\86\00"
@str.2 = private unnamed_addr constant [4 x i8] c"\E8\A7\92\00"
@str.3 = private unnamed_addr constant [4 x i8] c"\E5\BE\B5\00"
@str.4 = private unnamed_addr constant [4 x i8] c"\E7\BE\BD\00"
@str.5 = private unnamed_addr constant [7 x i8] c"\E9\9D\92\E9\BE\8D\00"
@str.6 = private unnamed_addr constant [7 x i8] c"\E7\99\BD\E8\99\8E\00"
@str.7 = private unnamed_addr constant [7 x i8] c"\E6\9C\B1\E9\9B\80\00"
@str.8 = private unnamed_addr constant [7 x i8] c"\E7\8E\84\E6\AD\A6\00"
@str.9 = private unnamed_addr constant [25 x i8] c"\E4\BA\94\E9\9F\B3\E4\B9\8B\E9\95\B7\EF\BC\8C\E8\A8\88\E6\9C\89\EF\BC\9A\00"
@str.10 = private unnamed_addr constant [25 x i8] c"\E5\9B\9B\E8\B1\A1\E4\B9\8B\E9\95\B7\EF\BC\8C\E8\A8\88\E6\9C\89\EF\BC\9A\00"
@str.11 = private unnamed_addr constant [49 x i8] c"\E5\A4\A9\E5\9C\B0\E8\90\AC\E8\B1\A1\E4\B9\8B\E9\95\B7\EF\BC\88\E5\85\A7\E5\90\AB\E5\B9\BE\E5\88\97\EF\BC\89\EF\BC\8C\E8\A8\88\E6\9C\89\EF\BC\9A\00"
@str.12 = private unnamed_addr constant [40 x i8] c"\E4\BB\A5\E8\BF\B4\E5\9C\88\E9\80\90\E4\B8\80\E5\8F\96\E4\BA\94\E9\9F\B3\E5\88\97\E4\B8\AD\E4\B9\8B\E7\89\A9\EF\BC\9A\00"
@str.13 = private unnamed_addr constant [40 x i8] c"\E4\BB\A5\E8\BF\B4\E5\9C\88\E9\80\90\E4\B8\80\E5\8F\96\E5\9B\9B\E8\B1\A1\E5\88\97\E4\B8\AD\E4\B9\8B\E7\89\A9\EF\BC\9A\00"
@str_true = private unnamed_addr constant [4 x i8] c"\E9\99\BD\00"
@str_true_n = private unnamed_addr constant [5 x i8] c"\E9\99\BD\0A\00"
@str_false = private unnamed_addr constant [4 x i8] c"\E9\99\B0\00"
@str_false_n = private unnamed_addr constant [5 x i8] c"\E9\99\B0\0A\00"

define i32 @main() {
    call void @utf8_init()
    %_stdout = call ptr @__acrt_iob_func(i32 1)
    store ptr %_stdout, ptr @stdout
    %g_stdout = load ptr, ptr @stdout
    %reg0 = call ptr @wy_rt_array_new(i64 8)
    %var.0 = alloca ptr
    store ptr %reg0, ptr %var.0
    %reg1 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg1, ptr @str.0)
    %reg2 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg2, ptr @str.1)
    %reg3 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg3, ptr @str.2)
    %reg4 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg4, ptr @str.3)
    %reg5 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg5, ptr @str.4)
    %reg6 = call ptr @wy_rt_array_new(i64 8)
    %var.1 = alloca ptr
    store ptr %reg6, ptr %var.1
    %reg7 = loadddd ptr, ptr %var.1
    call void @wy_rt_array_add_ptr(ptr %reg7, ptr @str.5)
    %reg8 = loadddd ptr, ptr %var.1
    call void @wy_rt_array_add_ptr(ptr %reg8, ptr @str.6)
    %reg9 = loadddd ptr, ptr %var.1
    call void @wy_rt_array_add_ptr(ptr %reg9, ptr @str.7)
    %reg10 = loadddd ptr, ptr %var.1
    call void @wy_rt_array_add_ptr(ptr %reg10, ptr @str.8)
    %reg11 = call ptr @wy_rt_array_new(i64 8)
    %var.2 = alloca ptr
    store ptr %reg11, ptr %var.2
    %reg12 = loadddd ptr, ptr %var.2
    %reg13 = loadddd ptr, ptr %var.0
    call void @wy_rt_array_add_ptr(ptr %reg12, ptr %reg13)
    %reg14 = loadddd ptr, ptr %var.2
    %reg15 = loadddd ptr, ptr %var.1
    call void @wy_rt_array_add_ptr(ptr %reg14, ptr %reg15)
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr @str.9)
    %reg16 = loadddd ptr, ptr %var.0
        %reg17 = call i64 @wy_rt_array_get_length(ptr %reg16)
    call i32 (ptr, ...) @printf(ptr @fmt_i64_n, i64 %reg17)
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr @str.10)
    %reg18 = loadddd ptr, ptr %var.1
        %reg19 = call i64 @wy_rt_array_get_length(ptr %reg18)
    call i32 (ptr, ...) @printf(ptr @fmt_i64_n, i64 %reg19)
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr @str.11)
    %reg20 = loadddd ptr, ptr %var.2
        %reg21 = call i64 @wy_rt_array_get_length(ptr %reg20)
    call i32 (ptr, ...) @printf(ptr @fmt_i64_n, i64 %reg21)
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr @str.12)
    %var.3 = alloca i32
    store i32 1, ptr %var.3
        
        br label %loop1.body
    loop1.body:
        %reg22 = loadddd ptr, ptr %var.0
            %reg23 = call i64 @wy_rt_array_get_length(ptr %reg22)
        %reg25 = loadddd i32, ptr %var.3
            %reg24 = icmp sgt i64 %reg25, %reg23
            br i1 %reg24, label %if2.true, label %if2.false
        if2.true:
            br label %loop1.exit
            br label %if2.false
    if2.false:
        
        %reg26 = loadddd ptr, ptr %var.0
        %reg27 = loadddd i32, ptr %var.3
        %reg28 = sext i32 %reg27 to i64
        %reg29 = sub i64 %reg28, 1
        %reg30 = call ptr @wy_rt_array_get_ptr(ptr %reg26, i64 %reg29)
        %reg31 = load ptr, ptr %reg30
        call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr %reg31)
        %reg33 = loadddd i32, ptr %var.3
            %reg32 = add i32 %reg33, 1
        store i32 %reg32, ptr %var.3
        br label %loop1.body
    loop1.exit:
        
    call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr @str.13)
    %var.4 = alloca i32
    store i32 1, ptr %var.4
        
        br label %loop3.body
    loop3.body:
        %reg34 = loadddd ptr, ptr %var.1
            %reg35 = call i64 @wy_rt_array_get_length(ptr %reg34)
        %reg37 = loadddd i32, ptr %var.4
            %reg36 = icmp sgt i64 %reg37, %reg35
            br i1 %reg36, label %if4.true, label %if4.false
        if4.true:
            br label %loop3.exit
            br label %if4.false
    if4.false:
        
        %reg38 = loadddd ptr, ptr %var.1
        %reg39 = loadddd i32, ptr %var.4
        %reg40 = sext i32 %reg39 to i64
        %reg41 = sub i64 %reg40, 1
        %reg42 = call ptr @wy_rt_array_get_ptr(ptr %reg38, i64 %reg41)
        %reg43 = load ptr, ptr %reg42
        call i32 (ptr, ...) @printf(ptr @fmt_ptr_n, ptr %reg43)
        %reg45 = loadddd i32, ptr %var.4
            %reg44 = add i32 %reg45, 1
        store i32 %reg44, ptr %var.4
        br label %loop3.body
    loop3.exit:
        
    ret i32 0
}
