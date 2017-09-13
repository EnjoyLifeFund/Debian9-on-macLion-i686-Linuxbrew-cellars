# Xcode 4.3 provides the Apple libtool.
# This is not the same so as a result we must install this as glibtool.

class Libtool < Formula
  desc "Generic library support script"
  homepage "https://www.gnu.org/software/libtool/"
  url "https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz"
  sha256 "7c87a8c2c8c0fc9cd5019e402bed4292462d00a718a7cd5f11218153bf28b26f"

  revision OS.linux? ? 2 : 1

  keg_only :provided_until_xcode43

  depends_on "m4" => :build unless OS.mac?

  option "with-default-names", "Do not prepend 'g' to the binary"

  def install
    ENV["SED"] = "sed" # prevent libtool from hardcoding sed path from superenv

    if OS.linux? && build.bottle?
      # prevent libtool from hardcoding GCC 4.8
      ENV["CC"] = "cc"
      ENV["CXX"] = "c++"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          ("--program-prefix=g" if build.without? "default-names"),
                          "--enable-ltdl-install"
    system "make", "install"

    if build.with? "default-names"
      bin.install_symlink "libtool" => "glibtool"
      bin.install_symlink "libtoolize" => "glibtoolize"
    end
  end

  def caveats; <<-EOS.undent
    In order to prevent conflicts with Apple's own libtool we have prepended a "g"
    so, you have instead: glibtool and glibtoolize.
    EOS
  end

  test do
    system "#{bin}/glibtool", "execute", File.executable?("/usr/bin/true") ? "/usr/bin/true" : "/bin/true"
    (testpath/"hello.c").write <<-EOS
      #include <stdio.h>
      int main() { puts("Hello, world!"); return 0; }
    EOS
    system bin/"glibtool", "--mode=compile", "--tag=CC",
      ENV.cc, "-c", "hello.c", "-o", "hello.o"
    system bin/"glibtool", "--mode=link", "--tag=CC",
      ENV.cc, "hello.o", "-o", "hello"
    assert_match "Hello, world!", shell_output("./hello")
  end
end
