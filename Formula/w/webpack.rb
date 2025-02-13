require "json"

class Webpack < Formula
  desc "Bundler for JavaScript and friends"
  homepage "https://webpack.js.org/"
  url "https://registry.npmjs.org/webpack/-/webpack-5.98.0.tgz"
  sha256 "abd3a2b6e5b0a9bd92ff8d89faf11ae0cc29697768e239936cf2f6b613ae9cff"
  license "MIT"
  head "https://github.com/webpack/webpack.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fef7f88f6a85f7eca96812323bdde668f47cc034dde43dfb19c4ae7685c3e71f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fef7f88f6a85f7eca96812323bdde668f47cc034dde43dfb19c4ae7685c3e71f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "fef7f88f6a85f7eca96812323bdde668f47cc034dde43dfb19c4ae7685c3e71f"
    sha256 cellar: :any_skip_relocation, sonoma:        "c415d82cebba541e02205b0716efcb044d3dbad39d9df1370805ced0c92056ca"
    sha256 cellar: :any_skip_relocation, ventura:       "c415d82cebba541e02205b0716efcb044d3dbad39d9df1370805ced0c92056ca"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fef7f88f6a85f7eca96812323bdde668f47cc034dde43dfb19c4ae7685c3e71f"
  end

  depends_on "node"

  resource "webpack-cli" do
    url "https://registry.npmjs.org/webpack-cli/-/webpack-cli-6.0.1.tgz"
    sha256 "f407788079854b0d48fb750da496c59cf00762dce3731520a4b375a377dec183"
  end

  def install
    (buildpath/"node_modules/webpack").install Dir["*"]
    buildpath.install resource("webpack-cli")

    cd buildpath/"node_modules/webpack" do
      system "npm", "install", *std_npm_args(prefix: false), "--force"
    end

    # declare webpack as a bundledDependency of webpack-cli
    pkg_json = JSON.parse(File.read("package.json"))
    pkg_json["dependencies"]["webpack"] = version
    pkg_json["bundleDependencies"] = ["webpack"]
    File.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *std_npm_args

    bin.install_symlink libexec.glob("bin/*")
    bin.install_symlink libexec/"bin/webpack-cli" => "webpack"
  end

  test do
    (testpath/"index.js").write <<~JS
      function component() {
        const element = document.createElement('div');
        element.innerHTML = 'Hello webpack';
        return element;
      }

      document.body.appendChild(component());
    JS

    system bin/"webpack", "bundle", "--mode=production", testpath/"index.js"
    assert_match 'const e=document.createElement("div");', (testpath/"dist/main.js").read
  end
end
