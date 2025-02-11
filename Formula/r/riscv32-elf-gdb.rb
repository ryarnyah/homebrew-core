class Riscv32ElfGdb < Formula
  desc "GNU debugger for riscv32-elf cross development"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-16.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-16.1.tar.xz"
  sha256 "c2cc5ccca029b7a7c3879ce8a96528fdfd056b4d884f2b0511e8f7bc723355c6"
  license "GPL-3.0-or-later"
  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  livecheck do
    formula "gdb"
  end

  depends_on "riscv32-elf-gcc" => :test
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "python@3.13"
  depends_on "xz" # required for lzma support

  uses_from_macos "expat"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  # Fix build on Linux
  # Ref: https://sourceware.org/bugzilla/show_bug.cgi?id=32578
  patch :DATA

  def install
    target = "riscv32-elf"
    args = %W[
      --target=#{target}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}
      --mandir=#{man}
      --with-lzma
      --with-python=#{which("python3.13")}
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args, *std_configure_args
      ENV.deparallelize # Error: common/version.c-stamp.tmp: No such file or directory
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system Formula["riscv32-elf-gcc"].bin/"riscv32-elf-gcc", "-g", "-nostdlib", "test.c"
    assert_match "Symbol \"_start\" is a function at address 0x",
          shell_output("#{bin}/riscv32-elf-gdb -batch -ex 'info address _start' a.out")
  end
end

__END__
diff --git a/bfd/Makefile.in b/bfd/Makefile.in
index aec3717485a..ee674a36c5b 100644
--- a/bfd/Makefile.in
+++ b/bfd/Makefile.in
@@ -1318,7 +1318,7 @@ REGEN_TEXI = \
 	$(MKDOC) -f $(srcdir)/doc/doc.str < $< > $@.tmp; \
 	texi=$@; \
 	texi=$${texi%.stamp}.texi; \
-	test -e $$texi || test ! -f $(srcdir)/$$texi || $(LN_S) $(srcdir)/$$texi $$texi; \
+	test -e $$texi || test ! -f $(srcdir)/$$texi || $(LN_S) $(abs_srcdir)/$$texi $$texi; \
 	$(SHELL) $(srcdir)/../move-if-change $@.tmp $$texi; \
 	touch $@; \
 	)
diff --git a/bfd/doc/local.mk b/bfd/doc/local.mk
index 97d658b5a48..9b75402387c 100644
--- a/bfd/doc/local.mk
+++ b/bfd/doc/local.mk
@@ -101,7 +101,7 @@ REGEN_TEXI = \
 	$(MKDOC) -f $(srcdir)/%D%/doc.str < $< > $@.tmp; \
 	texi=$@; \
 	texi=$${texi%.stamp}.texi; \
-	test -e $$texi || test ! -f $(srcdir)/$$texi || $(LN_S) $(srcdir)/$$texi $$texi; \
+	test -e $$texi || test ! -f $(srcdir)/$$texi || $(LN_S) $(abs_srcdir)/$$texi $$texi; \
 	$(SHELL) $(srcdir)/../move-if-change $@.tmp $$texi; \
 	touch $@; \
 	)
