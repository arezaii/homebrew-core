class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.4.16.tar.gz"
  sha256 "28c40f5456afa30fac98bb0f3fe38740d8c3bda9425c75b21044efe30c9c3278"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ad350f0365ae18c736b5270ca29dec84b63bc13d772f74bfe4a1b1d44f4e92bb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4523723d44a9082a975aace9b2d9c749eee2cd20d8fd87e99c4a8a403f68a48a"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "4925082c1e28032c6845baecbc32b55b9d43911e646d0378f66c5a454cb5e860"
    sha256 cellar: :any_skip_relocation, sonoma:        "e0a2d83d00224115d3f178ede0965524d9440cb8075dfb70bc67d0940b80a6d9"
    sha256 cellar: :any_skip_relocation, ventura:       "1f19d6aa180cf964f704a96b650153f57c7e4518b9d8f54999d6c3242d71b038"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2ef51771958b805593ce7ee9e75cb00e37882454e91185035fa643a3feef1d70"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "xz"

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
    generate_completions_from_executable(bin/"uvx", "--generate-shell-completion", base_name: "uvx")
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
