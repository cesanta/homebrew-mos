class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/42c04f6a236298581c9207791b91f2634ab64802.tar.gz"
  sha256 "4ea038ae91c48f010d74f3fd4080119307642416740c94967be7fbf407a00fdd"
  version "201812311650"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
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
