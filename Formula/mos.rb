class Mos < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/2.18.0.tar.gz"
  sha256 "46fa3902878dee9e21a94b2686b084f90f517a9175aa20b81d984811b227ef56"
  license "Apache-2.0"
  head "https://github.com/mongoose-os/mos.git"

  livecheck do
    url :stable
  end

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    cellar :any
    sha256 "38d13ab2e6cef41dc0ea1fa70b40ba4964b079696f55362459a42fbbb2598cf0" => :catalina # 2.18.0
  end
  # update_hb end

  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  conflicts_with "mos-latest", because: "use mos or mos-latest, not both"

  def install
    cd buildpath do
      # The build will be performed not from a git repo, so we have to specify
      # version and build id manually. Use "brew" as a distro name so that mos
      # won't update itself.
      build_id = format("%s~brew", version)
      File.open("pkg.version", "w") { |file| file.write(version) }
      File.open("pkg.build_id", "w") { |file| file.write(build_id) }

      system "make", "mos"
      bin.install "mos"
      prefix.install_metafiles
    end
  end

  test do
    test_desc = desc.tr("-", " ")
    expected = "#{test_desc}\n"   \
    "Version: #{version}\n"       \
    "Build ID: #{version}~brew\n" \
    "Update channel: release\n"
    assert_match expected, shell_output("#{bin}/mos version")
  end
end
