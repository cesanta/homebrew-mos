class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/29025863ee15d64ab1c81ca177d936f96f6b0401.tar.gz"
  sha256 "63b641f36f3080bd83bfcf2728bc70f6d08c8cf548956ebc3cbfbf65d7581227"
  version "202008211837"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "2f17433273efe4ced50e0200b5b41060ec7fe89232a6032aa07400b2e07a3f3c" => :catalina # 202008211837
  end
  # update_hb end

  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python3" => :build

  conflicts_with "mos", :because => "Use mos or mos-latest, not both"

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
    system bin/"mos", "version"
  end
end
