class Ovmf < Formula
  desc "UEFI firmware for aarch64 and x86-64 virtual machines"
  homepage "https://github.com/tianocore/tianocore.github.io/wiki/EDK-II"
  url "https://github.com/tianocore/edk2/releases/download/edk2-stable202102/edk2-stable202102.zip"
  sha256 "14bb77927b7bc035a3dc50c1fb88779929c3b730bb3a49d1e31e6117fd20552c"
  license all_of: ["BSD-2-Clause-Patent", "MIT", "OpenSSL"]
  version "stable202102"
  head "https://github.com/tianocore/edk2.git"

  bottle do
    root_url "https://github.com/uenoB/homebrew-qemu-hvf/releases/download/v1"
    sha256 cellar: :any_skip_relocation, all: "dde11b5f2e81488a3a85094115f860bc708d6a81fb32701b5214b27c93a94a57"
  end

  depends_on "aarch64-linux-gnu-binutils" => :build
  depends_on "aarch64-linux-gnu-gcc" => :build
  depends_on "x86_64-linux-gnu-binutils" => :build
  depends_on "x86_64-linux-gnu-gcc" => :build
  depends_on "nasm" => :build
  depends_on "acpica" => :build
  depends_on "python@3" => :build

  resource "BaseTools" do
    url "https://github.com/tianocore/edk2/releases/download/edk2-stable202102/submodule-BaseTools-Source-C-BrotliCompress-brotli.zip"
    sha256 "1fc6e9330078fc471969ffa44bb1683f3989b15f452c0549eec151816d260d3f"
  end

  resource "CryptoPkg" do
    url "https://github.com/tianocore/edk2/releases/download/edk2-stable202102/submodule-CryptoPkg-Library-OpensslLib-openssl.zip"
    sha256 "a69014f8264100bdb87b5bd21b3137dd97e91c56010455da7ffffee99bb8d018"
  end

  resource "MdeModulePkg" do
    url "https://github.com/tianocore/edk2/releases/download/edk2-stable202102/submodule-MdeModulePkg-Library-BrotliCustomDecompressLib-brotli.zip"
    sha256 "e1996d7438aa72e627b66598183b20c5781e7d6c61321bcac7eb52de46099f87"
  end

  patch :DATA

  def install
    resources.each do |r|
      r.stage buildpath/"submodules"/r.name
      cp_r buildpath/"submodules"/r.name, buildpath
    end
    ENV["PYTHON_COMMAND"] = Formula["python@3"].bin/"python3"
    system "make", "-C", "BaseTools"
    ENV["GCC5_AARCH64_PREFIX"] = "aarch64-linux-gnu-"
    system "sh", "-c", "source edksetup.sh; unset MAKEFLAGS; build -a AARCH64 -t GCC5 -p ArmVirtPkg/ArmVirtQemu.dsc"
    ENV["GCC5_BIN"] = "x86_64-linux-gnu-"
    system "sh", "-c", "source edksetup.sh; unset MAKEFLAGS; build -a X64 -t GCC5 -p OvmfPkg/OvmfPkgX64.dsc"
    mkdir_p share/"OVMF/ArmVirtQemu-AARCH64"
    mkdir_p share/"OVMF/OvmfX64"
    cp buildpath/"Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_EFI.fd",
       share/"OVMF/ArmVirtQemu-AARCH64"
    cp buildpath/"Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_VARS.fd",
       share/"OVMF/ArmVirtQemu-AARCH64"
    cp buildpath/"Build/OvmfX64/DEBUG_GCC5/FV/OVMF_CODE.fd",
       share/"OVMF/OvmfX64"
    cp buildpath/"Build/OvmfX64/DEBUG_GCC5/FV/OVMF_VARS.fd",
       share/"OVMF/OvmfX64"
  end

end
__END__
--- a/OvmfPkg/QemuRamfbDxe/QemuRamfb.c.orig	2021-03-02 14:11:55.000000000 +0900
+++ b/OvmfPkg/QemuRamfbDxe/QemuRamfb.c	2021-05-02 02:10:09.000000000 +0900
@@ -54,6 +54,14 @@
     0,    // Version
     1024, // HorizontalResolution
     768,  // VerticalResolution
+  },{
+    0,    // Version
+    1280, // HorizontalResolution
+    960,  // VerticalResolution
+  },{
+    0,    // Version
+    1440, // HorizontalResolution
+    900,  // VerticalResolution
   }
 };
 
