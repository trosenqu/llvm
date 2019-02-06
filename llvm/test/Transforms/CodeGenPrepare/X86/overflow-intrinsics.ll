; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -codegenprepare -S < %s | FileCheck %s
; RUN: opt -enable-debugify -codegenprepare -S < %s 2>&1 | FileCheck %s -check-prefix=DEBUG

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.0.0"

define i64 @test1(i64 %a, i64 %b) nounwind ssp {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 [[B:%.*]], i64 [[A:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    [[Q:%.*]] = select i1 [[OVERFLOW]], i64 [[B]], i64 42
; CHECK-NEXT:    ret i64 [[Q]]
;
  %add = add i64 %b, %a
  %cmp = icmp ult i64 %add, %a
  %Q = select i1 %cmp, i64 %b, i64 42
  ret i64 %Q
}

define i64 @test2(i64 %a, i64 %b) nounwind ssp {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 [[B:%.*]], i64 [[A:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    [[Q:%.*]] = select i1 [[OVERFLOW]], i64 [[B]], i64 42
; CHECK-NEXT:    ret i64 [[Q]]
;
  %add = add i64 %b, %a
  %cmp = icmp ult i64 %add, %b
  %Q = select i1 %cmp, i64 %b, i64 42
  ret i64 %Q
}

define i64 @test3(i64 %a, i64 %b) nounwind ssp {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 [[B:%.*]], i64 [[A:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    [[Q:%.*]] = select i1 [[OVERFLOW]], i64 [[B]], i64 42
; CHECK-NEXT:    ret i64 [[Q]]
;
  %add = add i64 %b, %a
  %cmp = icmp ugt i64 %b, %add
  %Q = select i1 %cmp, i64 %b, i64 42
  ret i64 %Q
}

define i64 @test4(i64 %a, i64 %b, i1 %c) nounwind ssp {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[NEXT:%.*]], label [[EXIT:%.*]]
; CHECK:       next:
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 [[B:%.*]], i64 [[A:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    [[Q:%.*]] = select i1 [[OVERFLOW]], i64 [[B]], i64 42
; CHECK-NEXT:    ret i64 [[Q]]
; CHECK:       exit:
; CHECK-NEXT:    ret i64 0
;
entry:
  %add = add i64 %b, %a
  %cmp = icmp ugt i64 %b, %add
  br i1 %c, label %next, label %exit

next:
  %Q = select i1 %cmp, i64 %b, i64 42
  ret i64 %Q

exit:
  ret i64 0
}

define i64 @test5(i64 %a, i64 %b, i64* %ptr, i1 %c) nounwind ssp {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ADD:%.*]] = add i64 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    store i64 [[ADD]], i64* [[PTR:%.*]]
; CHECK-NEXT:    br i1 [[C:%.*]], label [[NEXT:%.*]], label [[EXIT:%.*]]
; CHECK:       next:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ugt i64 [[B]], [[ADD]]
; CHECK-NEXT:    [[Q:%.*]] = select i1 [[TMP0]], i64 [[B]], i64 42
; CHECK-NEXT:    ret i64 [[Q]]
; CHECK:       exit:
; CHECK-NEXT:    ret i64 0
;
entry:
  %add = add i64 %b, %a
  store i64 %add, i64* %ptr
  %cmp = icmp ugt i64 %b, %add
  br i1 %c, label %next, label %exit

next:
  %Q = select i1 %cmp, i64 %b, i64 42
  ret i64 %Q

exit:
  ret i64 0
}

; When adding 1, the general pattern for add-overflow may be different due to icmp canonicalization.
; PR31754: https://bugs.llvm.org/show_bug.cgi?id=31754

define i1 @uaddo_i64_increment(i64 %x, i64* %p) {
; CHECK-LABEL: @uaddo_i64_increment(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 [[X:%.*]], i64 1)
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i64, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    store i64 [[UADD]], i64* [[P:%.*]]
; CHECK-NEXT:    ret i1 [[OVERFLOW]]
;
  %a = add i64 %x, 1
  %ov = icmp eq i64 %a, 0
  store i64 %a, i64* %p
  ret i1 %ov
}

define i1 @uaddo_i8_increment_noncanonical_1(i8 %x, i8* %p) {
; CHECK-LABEL: @uaddo_i8_increment_noncanonical_1(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i8, i1 } @llvm.uadd.with.overflow.i8(i8 1, i8 [[X:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i8, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i8, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    store i8 [[UADD]], i8* [[P:%.*]]
; CHECK-NEXT:    ret i1 [[OVERFLOW]]
;
  %a = add i8 1, %x        ; commute
  %ov = icmp eq i8 %a, 0
  store i8 %a, i8* %p
  ret i1 %ov
}

define i1 @uaddo_i32_increment_noncanonical_2(i32 %x, i32* %p) {
; CHECK-LABEL: @uaddo_i32_increment_noncanonical_2(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 [[X:%.*]], i32 1)
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i32, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i32, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    store i32 [[UADD]], i32* [[P:%.*]]
; CHECK-NEXT:    ret i1 [[OVERFLOW]]
;
  %a = add i32 %x, 1
  %ov = icmp eq i32 0, %a   ; commute
  store i32 %a, i32* %p
  ret i1 %ov
}

define i1 @uaddo_i16_increment_noncanonical_3(i16 %x, i16* %p) {
; CHECK-LABEL: @uaddo_i16_increment_noncanonical_3(
; CHECK-NEXT:    [[UADD_OVERFLOW:%.*]] = call { i16, i1 } @llvm.uadd.with.overflow.i16(i16 1, i16 [[X:%.*]])
; CHECK-NEXT:    [[UADD:%.*]] = extractvalue { i16, i1 } [[UADD_OVERFLOW]], 0
; CHECK-NEXT:    [[OVERFLOW:%.*]] = extractvalue { i16, i1 } [[UADD_OVERFLOW]], 1
; CHECK-NEXT:    store i16 [[UADD]], i16* [[P:%.*]]
; CHECK-NEXT:    ret i1 [[OVERFLOW]]
;
  %a = add i16 1, %x        ; commute
  %ov = icmp eq i16 0, %a   ; commute
  store i16 %a, i16* %p
  ret i1 %ov
}

; TODO: Did we really intend to match this if it's not supported by the target?

define i1 @uaddo_i42_increment_illegal_type(i42 %x, i42* %p) {
; CHECK-LABEL: @uaddo_i42_increment_illegal_type(
; CHECK-NEXT:    [[A:%.*]] = add i42 [[X:%.*]], 1
; CHECK-NEXT:    [[OV:%.*]] = icmp eq i42 [[A]], 0
; CHECK-NEXT:    store i42 [[A]], i42* [[P:%.*]]
; CHECK-NEXT:    ret i1 [[OV]]
;
  %a = add i42 %x, 1
  %ov = icmp eq i42 %a, 0
  store i42 %a, i42* %p
  ret i1 %ov
}

; Check that every instruction inserted by -codegenprepare has a debug location.
; DEBUG: CheckModuleDebugify: PASS

