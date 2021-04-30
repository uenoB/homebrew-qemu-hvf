class Samba < Formula
  desc "SMB/CIFS file, print, and login server for UNIX"
  homepage "https://samba.org"
  url "https://download.samba.org/pub/samba/stable/samba-4.14.3.tar.gz"
  sha256 "efc24ccf277055891f830719bd155b6a6dd9341d71961ee79e0ef75dc1aeb598"
  head "https://git.samba.org/samba.git"

  depends_on "glib"
  depends_on "gnutls"
  depends_on "jansson"
  depends_on "libtasn1"
  depends_on "popt"
  depends_on "readline"
  depends_on "python@3" => :build

  keg_only :provided_by_macos, "macOS provides its own SMB server"

  patch :DATA

  resource "Parse::Yapp" do
    url "https://cpan.metacpan.org/authors/id/W/WB/WBRASWELL/Parse-Yapp-1.21.tar.gz"
    sha256 "3810e998308fba2e0f4f26043035032b027ce51ce5c8a52a8b8e340ca65f13e5"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", buildpath/"perl5/lib/perl5"
    resource("Parse::Yapp").stage do
      system "perl", "Makefile.PL", "INSTALL_BASE=#{buildpath/"perl5"}"
      system "make"
      system "make", "install"
    end
    system "./configure",
           "--prefix=#{prefix}",
           "--disable-python",
           "--without-ad-dc",
           "--without-libarchive",
           "--without-gpgme",
           "--without-acl-support"
    system "make"
    system "make", "install"
    system "make", "clean"  # for test

    dylib_path = ->(i) do
      case i
      when /\/lib([_a-z]+)_module_([^\/]+)\.dylib\z/ then
        lib / $1 / "#{$2}.dylib"
      else
        path = lib / "private" / File.basename(i)
        if path.executable? then
          path
        else
          lib / File.basename(i)
        end
      end
    end

    prefix.glob("**/*").each do |i|
      i = prefix/i
      next unless i.file? and i.executable?
      begin
        m = MachO.open(i.to_s)
      rescue MachO::MagicError
        next
      end
      m.linked_dylibs.each do |j|
        next unless j.start_with? buildpath.to_s
        m.change_install_name j, dylib_path.(j).to_s
      end
      if m.dylib_id then
        m.change_dylib_id dylib_path.(m.dylib_id).to_s
      end
      m.write!
      MachO.codesign!(i.to_s) if Hardware::CPU.arm?
    end
  end

  test do
    system opt_sbin/"smbd", "--help"
  end

end
__END__
--- samba-4.14.3/lib/util/charset/charset_macosxfs.c.orig	2021-01-21 22:20:40.000000000 +0900
+++ samba-4.14.3/lib/util/charset/charset_macosxfs.c	2021-04-21 14:00:43.000000000 +0900
@@ -29,6 +29,7 @@
  * source.
  */
 
+#include "util/debug.h"
 #include "replace.h"
 #include "charset.h"
 #include "charset_proto.h"
--- samba-4.14.3/libcli/smbreadline/smbreadline.c.orig	2021-01-21 22:20:40.000000000 +0900
+++ samba-4.14.3/libcli/smbreadline/smbreadline.c	2021-04-29 11:58:49.000000000 +0900
@@ -145,7 +145,7 @@
 		rl_basic_word_break_characters = " \t\n";
 	}
 
-#ifdef HAVE_DECL_RL_EVENT_HOOK
+#if HAVE_DECL_RL_EVENT_HOOK
 	if (callback)
 		rl_event_hook = (rl_hook_func_t *)callback;
 #endif
