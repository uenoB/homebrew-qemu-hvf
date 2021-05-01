class Aarch64LinuxGnuBinutils < Formula
  desc "GNU Binutils for aarch64-linux-gnu"
  homepage "https://www.gnu.org/software/binutils/"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.36.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.36.1.tar.xz"
  sha256 "e81d9edf373f193af428a0f256674aea62a9d74dfe93f65192d4eae030b0f3b0"
  license "GPL-3.0-or-later"

  keg_only "it conflicts with the x86_64-linux-gnu-binutils formula"

  uses_from_macos "texinfo"

  def install
    system "./configure",
           "--target=aarch64-linux-gnu",
           "--prefix=#{prefix}",
           "--infodir=#{info}/aarch64-linux-gnu-binutils",
           "--disable-debug",
           "--disable-dependency-tracking",
           "--enable-deterministic-archives",
           "--disable-werror",
           "--enable-interwork",
           "--with-system-zlib",
           "--disable-nls"
    system "make"
    system "make", "install"
    (prefix/"aarch64-linux-gnu").rmtree
    ln_sf "aarch64-linux-gnu-ld", bin/"aarch64-linux-gnu-ld.bfd"
  end

  test do
    assert_match "f()", shell_output("#{bin}/aarch64-linux-gnu-c++filt _Z1fv")
  end
end
