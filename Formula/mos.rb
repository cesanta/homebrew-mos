class Mos < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/9bf406d90c65fca0b377220940735015dcfbb76c.tar.gz"
  sha256 "f5a5ca320de4ea4c3cea63225423828338a77cfdcaec7d0777d38074b3abdcbe"
  license "Apache-2.0"
  version "2.19.1"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    cellar :any
    sha256 "3f85bdb61fcace4a3e7fcfc210563fdf51725cee058203efc73f198708e69ead" => :catalina # 2.19.1
  end
  # update_hb end

  head "https://github.com/mongoose-os/mos.git"

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
