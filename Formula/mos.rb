class Mos < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/e5d271263e971b1d6414d5885f780ddb48b2458b.tar.gz"
  sha256 "dd8e8a45ea3079b3a99bedae47f6e41597d9c43a2ea20ab63ad43936029931fd"
  version "2.11.0"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    cellar :any
    sha256 "009a0f2bbc1a6924d6ea8988dcd7084183bea4d2c82a1fedf7f9207d04ffccc9" => :mojave
  end
  # update_hb end

  depends_on "go" => :build
  depends_on "govendor" => :build
  depends_on "libftdi" => :build
  depends_on "libusb" => :build
  depends_on "libusb-compat" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build

  conflicts_with "mos-latest", :because => "Use mos or mos-latest, not both"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = "amd64"
    ENV["CGO_ENABLED"] = "1"
    ENV["PATH"] += ":#{ENV["GOPATH"]}/bin"

    path = buildpath/"src/cesanta.com"
    path.install Dir["{*,.git}"]

    cd path/"mos" do
      # The build will be performed not from a git repo, so we have to specify
      # version and build id manually. Use "brew" as a distro name so that mos
      # won't update itself.
      build_id = format("%s~brew", version)
      File.open(path/"mos/pkg.version", "w") { |file| file.write(version) }
      File.open(path/"mos/pkg.build_id", "w") { |file| file.write(build_id) }

      system "govendor", "sync"
      system "make", "generate"
      system "go", "build", "-o", bin/"mos"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"mos", "version"
  end
end
