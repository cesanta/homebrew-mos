class MosLatest < Formula
  include Language::Python::Virtualenv

  desc "Mongoose OS command-line tool (latest)"
  license "Apache-2.0"
  homepage "https://mongoose-os.com/"
  head "https://github.com/mongoose-os/mos.git"

  # update_hb begin
  version "202208082046"
  url "https://github.com/mongoose-os/mos/archive/fc44e9f1cba381a9143d368c00f94f24162d19ca.tar.gz"
  sha256 "422f83018b54df5aae15f87837e17af78ef0a9ef7eb29620eb40c7106cd208dd"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    sha256 cellar: :any, big_sur: "d9c784998c2c356b6c84b908a0d5ee894762dc84e3f309a2757ca1b572a9e98a" # 202208082046
  end
  # update_hb end

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
