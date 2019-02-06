//===--- SPIR.h - Declare SPIR target feature support -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares SPIR TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_SPIR_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_SPIR_H

#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Support/Compiler.h"

namespace clang {
namespace targets {

static const unsigned SPIRAddrSpaceMap[] = {
    0, // Default
    1, // opencl_global
    3, // opencl_local
    2, // opencl_constant
    0, // opencl_private
    4, // opencl_generic
    0, // cuda_device
    0, // cuda_constant
    0, // cuda_shared
    1, // sycl_global
    3, // sycl_local
    2, // sycl_constant
    5, // sycl_private
    4, // sycl_generic
};

class LLVM_LIBRARY_VISIBILITY SPIRTargetInfo : public TargetInfo {
public:
  SPIRTargetInfo(const llvm::Triple &Triple, const TargetOptions &)
      : TargetInfo(Triple) {
    TLSSupported = false;
    VLASupported = false;
    LongWidth = LongAlign = 64;
    AddrSpaceMap = &SPIRAddrSpaceMap;
    UseAddrSpaceMapMangling = true;
    HasLegalHalfType = true;
    HasFloat16 = true;
    // Define available target features
    // These must be defined in sorted order!
    NoAsmVariants = true;
  }

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  bool hasFeature(StringRef Feature) const override {
    return Feature == "spir";
  }

  // SPIR supports the half type and the only llvm intrinsic allowed in SPIR is
  // memcpy as per section 3 of the SPIR spec.
  bool useFP16ConversionIntrinsics() const override { return false; }

  ArrayRef<Builtin::Info> getTargetBuiltins() const override { return None; }

  const char *getClobbers() const override { return ""; }

  ArrayRef<const char *> getGCCRegNames() const override { return None; }

  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &info) const override {
    return true;
  }

  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override {
    return None;
  }

  BuiltinVaListKind getBuiltinVaListKind() const override {
    return TargetInfo::VoidPtrBuiltinVaList;
  }

  CallingConvCheckResult checkCallingConvention(CallingConv CC) const override {
    return (CC == CC_SpirFunction || CC == CC_OpenCLKernel) ? CCCR_OK
                                                            : CCCR_Warning;
  }

  CallingConv getDefaultCallingConv(CallingConvMethodType MT) const override {
    return CC_SpirFunction;
  }

  void setSupportedOpenCLOpts() override {
    // Assume all OpenCL extensions and optional core features are supported
    // for SPIR since it is a generic target.
    getSupportedOpenCLOpts().supportAll();
  }
};
class LLVM_LIBRARY_VISIBILITY SPIR32TargetInfo : public SPIRTargetInfo {
public:
  SPIR32TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
      : SPIRTargetInfo(Triple, Opts) {
    PointerWidth = PointerAlign = 32;
    SizeType = TargetInfo::UnsignedInt;
    PtrDiffType = IntPtrType = TargetInfo::SignedInt;
    resetDataLayout("e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-"
                    "v96:128-v192:256-v256:256-v512:512-v1024:1024");
  }

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;
};

class LLVM_LIBRARY_VISIBILITY SPIR64TargetInfo : public SPIRTargetInfo {
public:
  SPIR64TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts)
      : SPIRTargetInfo(Triple, Opts) {
    PointerWidth = PointerAlign = 64;
    SizeType = TargetInfo::UnsignedLong;
    PtrDiffType = IntPtrType = TargetInfo::SignedLong;
    resetDataLayout("e-i64:64-v16:16-v24:32-v32:32-v48:64-"
                    "v96:128-v192:256-v256:256-v512:512-v1024:1024");
  }

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;
};

class LLVM_LIBRARY_VISIBILITY SPIR32SYCLDeviceTargetInfo
    : public SPIR32TargetInfo {
public:
  SPIR32SYCLDeviceTargetInfo(const llvm::Triple &Triple,
                             const TargetOptions &Opts)
      : SPIR32TargetInfo(Triple, Opts) {
    // This is workaround for exception_ptr class.
    // Exceptions is not allowed in sycl device code but we should be able
    // to parse host code. So we allow compilation of exception_ptr but
    // if exceptions are used in device code we should emit a diagnostic.
    MaxAtomicInlineWidth = 32;
    // This is workaround for mutex class.
    // I'm not sure about this hack but I guess that mutex_class is same
    // problem.
    TLSSupported = true;
  }
};

class LLVM_LIBRARY_VISIBILITY SPIR64SYCLDeviceTargetInfo
    : public SPIR64TargetInfo {
public:
  SPIR64SYCLDeviceTargetInfo(const llvm::Triple &Triple,
                             const TargetOptions &Opts)
      : SPIR64TargetInfo(Triple, Opts) {
    // This is workaround for exception_ptr class.
    // Exceptions is not allowed in sycl device code but we should be able
    // to parse host code. So we allow compilation of exception_ptr but
    // if exceptions are used in device code we should emit a diagnostic.
    MaxAtomicInlineWidth = 64;
    // This is workaround for mutex class.
    // I'm not sure about this hack but I guess that mutex_class is same
    // problem.
    TLSSupported = true;
  }
};

} // namespace targets
} // namespace clang
#endif // LLVM_CLANG_LIB_BASIC_TARGETS_SPIR_H
