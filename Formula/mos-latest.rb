class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/d2abac8cbc0fab748d18ff0ebd01e23cd895e547.tar.gz"
  version "202012121701"
  sha256 "5a1847c3b76adcdcbc6dc17f4aaff700d5810f193589f7684857027ae3b8c756"
  license "Apache-2.0"
  head "https://github.com/mongoose-os/mos.git"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "3fcffc98740b07c205c7c7ef7a8d2c00ced0441ff8b5d329e403cffb5cded33f" => :catalina # 202012121701
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
