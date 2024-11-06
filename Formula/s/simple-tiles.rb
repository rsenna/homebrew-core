class SimpleTiles < Formula
  desc "Image generation library for spatial data"
  homepage "https://github.com/propublica/simple-tiles"
  url "https://github.com/propublica/simple-tiles/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "343ae52a0b20ee091b14bc145b7c78fed13b7272acd827626283b70f178dfa34"
  license "MIT"
  revision 5
  head "https://github.com/propublica/simple-tiles.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia:  "00747024c39d6107fda45fcccdee7c3ed84759cf4305a78a8d765b4569ee59bc"
    sha256 cellar: :any,                 arm64_sonoma:   "0d53eeb5eb82384782741b1a171ae2ed2001c357ef57e4573a190a68a996b194"
    sha256 cellar: :any,                 arm64_ventura:  "778d36ddc79b72a993ec3d1b78a52b9b0f1e7297cb273036fc194dce7d3073a5"
    sha256 cellar: :any,                 arm64_monterey: "37d332d4b687b377a122c2fd965d51516cd70ee5b12f38258f14464d235b23a4"
    sha256 cellar: :any,                 sonoma:         "af5c779f077ea891fdc5dceb00fc182778727140c54f194be4713c81d19b44bb"
    sha256 cellar: :any,                 ventura:        "3d4a13f85120b05867e3d92e0c92798dac15d3177321aae163b3deadb729abb6"
    sha256 cellar: :any,                 monterey:       "d218722daedb29891ef3f4edfbc8a922c3bf247a9a7a74300e0616d21b42ce7b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "05a018f496523df7e44f4199d0c85ff42516f6f29401d23a161e5359e1764e62"
  end

  depends_on "pkg-config" => [:build, :test]

  depends_on "cairo"
  depends_on "gdal"
  depends_on "glib"
  depends_on "pango"

  uses_from_macos "python" => :build

  on_macos do
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  # Update waf for py3.13
  resource "waf" do
    url "https://raw.githubusercontent.com/propublica/simple-tiles/d4bae6b932ef84cd115cc327651b4fad49557409/waf"
    sha256 "dd9dd1895f939d288823a7e23d7914c4f9fb018828da64842953e2a857a08713"
  end

  # update tools/clang_compilation_database.py for py3.13
  patch do
    url "https://github.com/propublica/simple-tiles/commit/a6e8b5738bb7b935d0579a5b514c49720e9eeeff.patch?full_index=1"
    sha256 "b0d9226069b8c5cedd95d3150b46d123a14259a60f79d2827a5a99b9ce6e8944"
  end

  def install
    python3 = "python3"
    buildpath.install resource("waf")
    system python3, "./waf", "configure", "--prefix=#{prefix}"
    system python3, "./waf", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <simple-tiles/simple_tiles.h>

      int main(){
        simplet_map_t *map = simplet_map_new();
        simplet_map_free(map);
        return 0;
      }
    C
    cflags = shell_output("pkg-config --cflags simple-tiles").chomp.split
    system ENV.cc, "test.c", *cflags, "-L#{lib}", "-lsimple-tiles", "-o", "test"
    system "./test"
  end
end
