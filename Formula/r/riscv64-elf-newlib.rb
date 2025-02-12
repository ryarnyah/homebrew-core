# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Riscv32ElfNewlib < Formula
  desc "A C standard library implementation intended for use on embedded systems (RISCV64 bare metal)"
  homepage "https://www.sourceware.org/newlib/"
  url "ftp://sourceware.org/pub/newlib/newlib-4.5.0.20241231.tar.gz"
  sha256 "33f12605e0054965996c25c1382b3e463b0af91799001f5bb8c0630f2ec8c852"
  license "BSD"

  depends_on "riscv64-elf-binutils" => :build
  depends_on "riscv64-elf-gcc" => :build

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    target = "riscv64-elf"
    args = %W[
      --target=#{target}
      --infodir=#{info}
      --mandir=#{man}
      --bindir=#{bin}
      --enable-newlib-io-long-long
      --enable-newlib-io-c99-formats
      --enable-newlib-register-fini
      --enable-newlib-retargetable-locking
      --disable-newlib-supplied-syscalls
      --disable-nls
    ]
    mkdir "build" do
      system "../configure", *args, *std_configure_args
      ENV.deparallelize
      system "make"
      system "make", "install"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test riscv32-elf-newlib`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
