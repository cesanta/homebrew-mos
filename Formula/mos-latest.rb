class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/mongoose-os/mos/archive/c1dbbef823751e91fe192e7448209a31cc108f43.tar.gz"
  sha256 "7537ff7c3f1708e82ef5dae5b2bb32ac59bec33286a1fbeda58a29dad4c391e9"
  version "201912220223"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
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

  conflicts_with "mos", :because => "Use mos or mos-latest, not both"

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
