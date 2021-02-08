class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/9bf406d90c65fca0b377220940735015dcfbb76c.tar.gz"
  version "202102072216"
  sha256 "f5a5ca320de4ea4c3cea63225423828338a77cfdcaec7d0777d38074b3abdcbe"
  license "Apache-2.0"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "d93c6971ebd149d3b8c2fc76be7a1c87fab6377531794b45689cc0ee7fa8e368" => :catalina # 202102072216
  end
  # update_hb end

  head "https://github.com/mongoose-os/mos.git"

  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python3" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  conflicts_with "mos", because: "use mos or mos-latest, not both"

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
    # Remove (latest) and hyphen
    test_desc = desc[0...desc.rindex(" ")].tr("-", " ")
    expected = "#{test_desc}\n"   \
    "Version: #{version}\n"       \
    "Build ID: #{version}~brew\n" \
    "Update channel: latest\n"
    assert_match expected, shell_output("#{bin}/mos version")
  end
end
