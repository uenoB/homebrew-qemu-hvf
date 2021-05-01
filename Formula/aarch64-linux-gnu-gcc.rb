class Aarch64LinuxGnuGcc < Formula
  desc "GNU compiler collection for aarch64-linux-gnu"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz"
  sha256 "64f404c1a650f27fc33da242e1f2df54952e3963a49e06e73f6940f3223ac344"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  depends_on "gmp"
  depends_on "aarch64-linux-gnu-binutils"
  depends_on "libmpc"
  depends_on "mpfr"
  uses_from_macos "texinfo"

  patch :DATA

  def install
    binutils_bin = Formula["aarch64-linux-gnu-binutils"].bin
    mkdir "build" do
      system "../configure",
             "--target=aarch64-linux-gnu",
             "--prefix=#{prefix}",
             "--infodir=#{info}/aarch64-linux-gnu-gcc",
             "--without-isl",
             "--without-headers",
             "--with-as=#{binutils_bin}/aarch64-linux-gnu-as",
             "--with-ld=#{binutils_bin}/aarch64-linux-gnu-ld",
             "--enable-languages=c,c++",
             "--disable-nls"
      system "make", "all-gcc"
      system "make", "install-gcc"
      (share/"man/man7").rmtree
    end
  end

  test do
    binutils_bin = Formula["aarch64-linux-gnu-binutils"].bin
    (testpath/"test.c").write 'int main() { return 0; }'
    system "#{bin}/aarch64-linux-gnu-gcc", "-c", "test.c"
    assert_match "file format elf64-littleaarch64",
      shell_output("{#{binutils_bin}/aarch-linux-gnu-objdump -a test.o")
  end
end
__END__
--- gcc-10.3.0/gcc/config/host-darwin.c.orig	2021-04-08 20:56:28.000000000 +0900
+++ gcc-10.3.0/gcc/config/host-darwin.c	2021-05-01 23:38:56.000000000 +0900
@@ -22,6 +22,8 @@
 #include "coretypes.h"
 #include "diagnostic-core.h"
 #include "config/host-darwin.h"
+#include "hosthooks.h"
+#include "hosthooks-def.h"
 
 /* Yes, this is really supposed to work.  */
 /* This allows for a pagesize of 16384, which we have on Darwin20, but should
@@ -78,3 +80,5 @@
 
   return ret;
 }
+
+const struct host_hooks host_hooks = HOST_HOOKS_INITIALIZER;
--- gcc-10.3.0/gcc/config/aarch64/aarch64.h.orig	2021-04-08 20:56:28.000000000 +0900
+++ gcc-10.3.0/gcc/config/aarch64/aarch64.h	2021-05-01 23:34:15.000000000 +0900
@@ -1200,7 +1200,7 @@
 #define MCPU_TO_MARCH_SPEC_FUNCTIONS \
   { "rewrite_mcpu", aarch64_rewrite_mcpu },
 
-#if defined(__aarch64__)
+#if 0 && defined(__aarch64__)
 extern const char *host_detect_local_cpu (int argc, const char **argv);
 #define HAVE_LOCAL_CPU_DETECT
 # define EXTRA_SPEC_FUNCTIONS						\
