; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64    | FileCheck %s --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64-v2 | FileCheck %s --check-prefix=SSE4
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64-v3 | FileCheck %s --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64-v4 | FileCheck %s --check-prefix=AVX512

define i32 @PR135917(i1 %a0) {
; SSE2-LABEL: PR135917:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movd %edi, %xmm0
; SSE2-NEXT:    pandn {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE2-NEXT:    movd %xmm0, %ecx
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,1,1]
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    addl %ecx, %eax
; SSE2-NEXT:    retq
;
; SSE4-LABEL: PR135917:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movd %edi, %xmm0
; SSE4-NEXT:    pandn {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE4-NEXT:    movd %xmm0, %ecx
; SSE4-NEXT:    pextrd $1, %xmm0, %eax
; SSE4-NEXT:    addl %ecx, %eax
; SSE4-NEXT:    retq
;
; AVX2-LABEL: PR135917:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [1,1,1,1]
; AVX2-NEXT:    vpandn %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovd %xmm0, %ecx
; AVX2-NEXT:    vpextrd $1, %xmm0, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    retq
;
; AVX512-LABEL: PR135917:
; AVX512:       # %bb.0:
; AVX512-NEXT:    andb $1, %dil
; AVX512-NEXT:    negb %dil
; AVX512-NEXT:    kmovd %edi, %k0
; AVX512-NEXT:    knotw %k0, %k0
; AVX512-NEXT:    vpmovm2d %k0, %xmm0
; AVX512-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrd $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    retq
  %splat = insertelement <4 x i1> poison, i1 %a0, i64 0
  %xor = xor <4 x i1> %splat, splat (i1 true)
  %not = shufflevector <4 x i1> %xor, <4 x i1> poison, <4 x i32> zeroinitializer
  %zext = zext <4 x i1> %not to <4 x i32>
  %elt0 = extractelement <4 x i32> %zext, i64 0
  %elt1 = extractelement <4 x i32> %zext, i64 1
  %res = add i32 %elt0, %elt1
  ret i32 %res
}

