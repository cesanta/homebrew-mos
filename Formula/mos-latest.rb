class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/a52a5d9746e151299a4704d492091235a8cca4fa.tar.gz"
  sha256 "49e95f9ffb3d79f827454157bfaa5fc23cd362b03f6a98459220b1d21b56ef80"
  version "201901241729"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "2dba59487eb4f585ee6687d8dd6b2556914f372ff4f02fadc11be1b1666a02ae" => :mojave
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

  conflicts_with "mos", :because => "Use mos or mos-latest, not both"

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
