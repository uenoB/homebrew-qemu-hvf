class QemuHvf < Formula
  desc "Emulator for x86_64 and aarch64 with Hypervisor.framework"
  homepage "https://github.com/uenoB/qemu"
  head "https://github.com/uenoB/qemu.git", branch: "hvf"

  depends_on "samba"
  depends_on "glib"
  depends_on "pixman"

  depends_on "gnutls"
  depends_on "zstd"
  depends_on "lzfse"
  depends_on "lzo"
  depends_on "snappy"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "ncurses"
  depends_on "libssh"
  depends_on "libusb"
  depends_on "libiscsi"

  depends_on "ninja" => :build
  depends_on "pkgconfig" => :build
  depends_on "python@3" => :build

  keg_only "it conflicts with the QEMU formula"

  patch :DATA

  patch do
    url "https://lore.kernel.org/qemu-devel/CA+pCdY3iG+pKKQqEVknnWF-W0wK36S4U1jxPvxmGAPp6FFvz1Q@mail.gmail.com/raw"
    sha256 "7007f7f71d0131d9475091abec36b9b9bc5307ccdb81b9040f3e5ae967709dd7"
  end

  def install
    chdir "slirp" do
      system "git", "checkout", "v4.5.0"
    end
    mkdir "build" do
      system "../configure",
             "--prefix=#{prefix}",
             "--target-list=aarch64-softmmu,x86_64-softmmu",
             "--enable-cocoa",
             "--enable-lto",
             "--smbd=#{Formula["samba"].opt_sbin/"smbd"}"
      system "make"
      system "make", "install"
    end
  end

  def test
    assert_match /^hvf$/, shell_output("#{bin}/qemu-system-aarch64 -accel help")
  end

end
__END__
diff --git a/meson.build b/meson.build
index 2bf8e6465f..4cbefb0226 100644
--- a/meson.build
+++ b/meson.build
@@ -1525,6 +1525,8 @@ if have_system
     slirp_deps = []
     if targetos == 'windows'
       slirp_deps = cc.find_library('iphlpapi')
+    elif targetos == 'darwin'
+      slirp_deps = cc.find_library('resolv')
     endif
     slirp_conf = configuration_data()
     slirp_conf.set('SLIRP_MAJOR_VERSION', meson.project_version().split('.')[0])
