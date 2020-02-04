class Mos < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/18c19395db3292985b1d067c4188efd91eea62d3.tar.gz"
  sha256 "038a1b09aa5669b61d1ede4bc1da3ffca5ce0a115228030170ef5f02f3d91d0b"
  version "2.17.0"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    cellar :any
    sha256 "8ecfd9897e41f8c26e7110f6ace292dfc1344b6bdbc2f8849c2409a93157fccf" => :catalina # 2.17.0
    sha256 "2d33f146c3b6cf9bc2162b0607ac17ba38011453d64e8d5f72fe1da6bf17acab" => :mojave # 2.17.0
  end
  # update_hb end

  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "go" => :build
  depends_on "govendor" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python3" => :build
  depends_on "rsync" => :build

  conflicts_with "mos-latest", :because => "Use mos or mos-latest, not both"

  def install
    cd buildpath do
      # The build will be performed not from a git repo, so we have to specify
      # version and build id manually. Use "brew" as a distro name so that mos
      # won't update itself.
      build_id = format("%s~brew", version)
      File.open("pkg.version", "w") { |file| file.write(version) }
      File.open("pkg.build_id", "w") { |file| file.write(build_id) }

      # GoVendor pulls a lot of packages, it makes sense to cache them between builds.
      gopath = buildpath/"go"
      cachefile = "/tmp/mos-govendor-cache.tar"
      if(File.readable?(cachefile))
        system "tar", "-C", gopath, "-xf", cachefile
      else
        ohai "Note: Go package cache does not exist, next step may take a long time"
      end
      system "make", "mos"
      bin.install "mos"
      prefix.install_metafiles
      FileUtils.rm_f(cachefile)
      system "tar", "-C", gopath, "-cf", cachefile, ".cache"
    end
  end

  test do
    system bin/"mos", "version"
  end
end
