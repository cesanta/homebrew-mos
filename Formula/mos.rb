class Mos < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/980a486cf06f4370515a631b4af6c3bb9c6e2a85.tar.gz"
  sha256 "28d02319dfdfffe4e4c4b9afefda1e51b294fcc9a7040c31315276f9103fe71c"
  version "2.12.1"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    cellar :any
    sha256 "1b0d455a24655ad2b0d0c129ae2558d3dc28f0f1644541ac8321fa4868753b09" => :mojave
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

  conflicts_with "mos-latest", :because => "Use mos or mos-latest, not both"

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
      system "make", "generate"
      system "go", "build", "-o", bin/"mos"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"mos", "version"
  end
end
