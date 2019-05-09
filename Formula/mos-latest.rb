class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/bf6999dd875ea267f3f0912a22b2df838854649d.tar.gz"
  sha256 "c9bc693a81d4f7ec18ba93fbaeb6433766f24b534476f11854ec1c822ea8ceb0"
  version "201905091132"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "6d6aaf9e5c44f85fb5267efce5faf96a68f1abdc75cf52589d30b91c18b5a380" => :mojave
  end
  # update_hb end

  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "go" => :build
  depends_on "govendor" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build
  depends_on "rsync" => :build

  conflicts_with "mos", :because => "Use mos or mos-latest, not both"

  def install
    ENV["GOPATH"] = buildpath
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

      # GoVendor pulls a lot of packages, it makes sense to cache them between builds.
      cachefile = "/tmp/mos-govendor-cache.tar"
      if(File.readable?(cachefile))
        system "tar", "-C", buildpath, "-xf", cachefile
      else
        ohai "Note: Go package cache does not exist, next step may take a long time"
      end
      system "govendor", "sync"
      FileUtils.rm_f(cachefile)
      system "tar", "-C", buildpath, "-cf", cachefile, ".cache"
      system "make"
      bin.install "mos"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"mos", "version"
  end
end
