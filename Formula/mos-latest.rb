class MosLatest < Formula
  include Language::Python::Virtualenv

  desc "Mongoose OS command-line tool (latest)"
  license "Apache-2.0"
  homepage "https://mongoose-os.com/"
  head "https://github.com/mongoose-os/mos.git"

  # update_hb begin
  version "202206121900"
  url "https://github.com/mongoose-os/mos/archive/26e6a2cb03441a0cd2a03bd1bc0bfc47762b59bf.tar.gz"
  sha256 "286dc13af57bedf05529af3e8921a24e4cd0d771de4b879ba185592936703284"

  bottle do
    root_url "https://mongoose-os.com/downloads/homebrew/bottles-mos-latest"
    sha256 cellar: :any, big_sur: "8b35066a0bd851b5c225884a31910f7cb82e2e96dbc3cf238b8b1aea577c82e3" # 202206121900
  end
  # update_hb end

  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "python3" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  conflicts_with "mos", because: "use mos or mos-latest, not both"

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
    # Remove (latest) and hyphen
    test_desc = desc[0...desc.rindex(" ")].tr("-", " ")
    expected = "#{test_desc}\n"   \
    "Version: #{version}\n"       \
    "Build ID: #{version}~brew\n" \
    "Update channel: latest\n"
    assert_match expected, shell_output("#{bin}/mos version")
  end
end
