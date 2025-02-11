class Riscv32ElfGcc < Formula
  desc "GNU compiler collection for riscv32-elf"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
  sha256 "a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  livecheck do
    formula "gcc"
  end

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "riscv32-elf-binutils"
  depends_on "zstd"

  def install
    target = "riscv32-elf"
    mkdir "riscv32-elf-gcc-build" do
      system "../configure", "--target=#{target}",
                             "--prefix=#{prefix}",
                             "--infodir=#{info}/#{target}",
                             "--disable-nls",
                             "--without-isl",
                             "--without-headers",
                             "--with-as=#{Formula["riscv32-elf-binutils"].bin}/riscv32-elf-as",
                             "--with-ld=#{Formula["riscv32-elf-binutils"].bin}/riscv32-elf-ld",
                             "--enable-languages=c,c++"
      system "make", "all-gcc"
      system "make", "install-gcc"
      system "make", "all-target-libgcc"
      system "make", "install-target-libgcc"

      # FSF-related man pages may conflict with native gcc
      rm_r(share/"man/man7")
    end
  end

  test do
    (testpath/"test-c.c").write <<~C
      int main(void)
      {
        int i=0;
        while(i<10) i++;
        return i;
      }
    C
    system bin/"riscv32-elf-gcc", "-c", "-o", "test-c.o", "test-c.c"
    assert_match "file format elf32-littleriscv",
                 shell_output("#{Formula["riscv32-elf-binutils"].bin}/riscv32-elf-objdump -a test-c.o")
  end
end
