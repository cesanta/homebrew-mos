class MosLatest < Formula
  include Language::Python::Virtualenv

  # update_hb begin
  desc "Mongoose OS command-line tool (latest)"
  homepage "https://mongoose-os.com/"
  url "https://github.com/cesanta/mos-tool/archive/ab991daf63c158d8f3b40c4d18d675c32ebf6402.tar.gz"
  sha256 "f92b5a93030ee7da887094068a8c7ba3e33b107eb6a8f62258c58aa4681c5e9c"
  version "201901301647"
  head ""

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    cellar :any
    sha256 "2cdd49be1b024c5605c248cf2b3acbb475824eb18e280845067cc49677b9692b" => :mojave
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
      cachedir = "/tmp/.mos-gocache/"
      if(File.directory?(cachedir))
        system "rsync", "-a", "--delete", cachedir, buildpath+".cache/"
      else
        ohai "Note: Go package cache does not exist, next step may take a long time"
      end
      system "govendor", "sync"
      system "rsync", "-a", "--delete", buildpath+".cache/", cachedir
      system "make", "generate"
      system "go", "build", "-o", bin/"mos"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"mos", "version"
  end
end
