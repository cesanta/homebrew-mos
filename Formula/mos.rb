class Mos < Formula
  include Language::Python::Virtualenv

  desc "Mongoose OS command-line tool"
  license "Apache-2.0"
  homepage "https://mongoose-os.com/"
  head "https://github.com/mongoose-os/mos.git"

  # update_hb begin
  version "2.20.0"
  url "https://github.com/mongoose-os/mos/archive/0278853cf62da0c96ef239143243e854b2f611a8.tar.gz"
  sha256 "e9ef8d5933d9434596e784f680444c695f5907368cb93d3c002c0cb1863262de"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos"
    sha256 cellar: :any, big_sur: "803c30821d291ff07b9917804e5e28706b0b1e5a35514547455996e7d135c840" # 2.20.0
  end
  # update_hb end

  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  conflicts_with "mos-latest", because: "use mos or mos-latest, not both"

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
    test_desc = desc.tr("-", " ")
    expected = "#{test_desc}\n"   \
    "Version: #{version}\n"       \
    "Build ID: #{version}~brew\n" \
    "Update channel: release\n"
    assert_match expected, shell_output("#{bin}/mos version")
  end
end
