class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/028868df686198e0810c9da8582e50b10a54480d.tar.gz"
  sha256 "51b185ab015fc588cd0bef23fd776864ad631b9c07912ac516204dc56710674a"
  version "201812221250"
  head ""
  # update_hb end

  depends_on "go" => :build
  depends_on "govendor" => :build
  depends_on "libftdi" => :build
  depends_on "libusb" => :build
  depends_on "libusb-compat" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build if MacOS.version <= :snow_leopard

  resource "six" do
    url "https://files.pythonhosted.org/packages/source/s/six/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

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
