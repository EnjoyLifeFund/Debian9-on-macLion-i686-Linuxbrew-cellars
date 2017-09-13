class Help2man < Formula
  desc "Automatically generate simple man pages"
  homepage "https://www.gnu.org/software/help2man/"
  url "https://ftp.gnu.org/gnu/help2man/help2man-1.47.4.tar.xz"
  mirror "https://ftpmirror.gnu.org/help2man/help2man-1.47.4.tar.xz"
  sha256 "d4ecf697d13f14dd1a78c5995f06459bff706fd1ce593d1c02d81667c0207753"

  def install
    # install is not parallel safe
    # see https://github.com/Homebrew/homebrew/issues/12609
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match "help2man #{version}", shell_output("#{bin}/help2man #{bin}/help2man")
  end
end
