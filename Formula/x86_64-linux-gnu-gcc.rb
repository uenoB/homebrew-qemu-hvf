class X8664LinuxGnuGcc < Formula
  desc "GNU compiler collection for x86_64-linux-gnu"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz"
  sha256 "64f404c1a650f27fc33da242e1f2df54952e3963a49e06e73f6940f3223ac344"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  depends_on "gmp"
  depends_on "x86_64-linux-gnu-binutils"
  depends_on "libmpc"
  depends_on "mpfr"
  uses_from_macos "texinfo"

  patch :DATA

  def install
    binutils_bin = Formula["x86_64-linux-gnu-binutils"].bin
    mkdir "build" do
      system "../configure",
             "--target=x86_64-linux-gnu",
             "--prefix=#{prefix}",
             "--infodir=#{info}/x86_64-linux-gnu-gcc",
             "--without-isl",
             "--without-headers",
             "--with-as=#{binutils_bin}/x86_64-linux-gnu-as",
             "--with-ld=#{binutils_bin}/x86_64-linux-gnu-ld",
             "--enable-languages=c,c++",
             "--disable-nls"
      system "make", "all-gcc"
      system "make", "install-gcc"
      (share/"man/man7").rmtree
    end
  end

  test do
    binutils_bin = Formula["x86_64-linux-gnu-binutils"].bin
    (testpath/"test.c").write 'int main() { return 0; }'
    system "#{bin}/x86_64-linux-gnu-gcc", "-c", "test.c"
    assert_match "file format elf64-x86-64",
      shell_output("{#{binutils_bin}/x86_64-linux-gnu-objdump -a test.o")
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
--- gcc-10.3.0/gcc/config/i386/i386.h.orig	2021-04-08 20:56:28.000000000 +0900
+++ gcc-10.3.0/gcc/config/i386/i386.h	2021-05-02 01:20:18.000000000 +0900
@@ -719,7 +719,7 @@
 /* -march=native handling only makes sense with compiler running on
    an x86 or x86_64 chip.  If changing this condition, also change
    the condition in driver-i386.c.  */
-#if defined(__i386__) || defined(__x86_64__)
+#if 0 && (defined(__i386__) || defined(__x86_64__))
 /* In driver-i386.c.  */
 extern const char *host_detect_local_cpu (int argc, const char **argv);
 #define EXTRA_SPEC_FUNCTIONS \
