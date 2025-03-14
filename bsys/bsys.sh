# Exit on command failure
set -e

# Display the help message
help() {
    echo "Usage: $0 (-chtx) (--uncross)"
    echo
    echo "Options:"
    echo "    -h, --help       Shows this help message."
    echo "    -t, --test       Run the OS in QEMU."
    echo "    -c, --clean      Remove generated objects and images."
    echo "    -x, --cross      Build and install a cross-compilation toolchain."
    echo "    --uncross        Uninstall the cross-compilation toolchain."

    exit
}

cross() {
    # Check if Binutils and GCC archives are here
    if [[ ! -d "$REPO/binutils.cross" ]]; then
        echo "(X) binutils.cross not found in repo clone root. (Is \$REPO set properly?)" >&2
        exit 1
    fi

    if [[ ! -d "$REPO/gcc.cross" ]]; then
        echo "(X) gcc.cross not found in repo clone root. (Is \$REPO set properly?)" >&2
        exit 1
    fi

    # Set the proper target
    TARGET="i686-elf"

    # If the PREFIX variable isn't set, then set the default
    if [[ "$PREFIX" == "" ]]; then
        PREFIX="/opt/cross"
    fi

    # If the tmp temporal directory exists, remove it
    if [[ -d "$REPO/tmp" ]]; then
        rm -rf "$REPO/tmp"
    fi

    # Create the temporal subdirectories
    mkdir -p "$REPO/tmp/binutils" "$REPO/tmp/gcc"

    # Build and install Binutils
    cd "$REPO/tmp/binutils"
    "$REPO/binutils.cross/configure" --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
    make -j$(nproc)
    make install

    # Build and install GCC
    cd "$REPO/tmp/gcc"
    "$REPO/gcc.cross/configure" --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
    make all-gcc -j$(nproc)
    make all-target-libgcc -j$(nproc)
    make all-target-libstdc++-v3 -j$(nproc)
    make install-gcc
    make install-target-libgcc
    make install-target-libstdc++-v3

    # Tell the user to re-set their PATH
    echo "=> Set your PATH to $PREFIX/bin:\$PATH to use the cross-compilation toolchain."
}

# If no arguments are passed, just build the OS (default behavior)
if [[ $# -eq 0 ]]; then
    # Verify cross-compiler toolchain is built & installed
    if ! command -v i686-elf-as > /dev/null 2>&1; then
        echo "(X) Cross-compiler not found." >&2
        exit 1
    fi

    # Compile boot stub
    echo ":: Compiling boot stub..."
    mkdir -p obj
    i686-elf-as src/boot.asm -o obj/boot.o

    # Compile Wireframe kernel
    echo ":: Compiling Wireframe kernel..."
    i686-elf-gcc -c src/kernel.c -o obj/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

    # Link the OS
    echo ":: Linking OS..."
    mkdir -p bin
    i686-elf-gcc -T bsys/linker.ld -o bin/circuitos.bin -ffreestanding -O2 -nostdlib obj/boot.o obj/kernel.o -lgcc
fi

# Parse arguments and handle them
case "$1" in
    "-c" | "--clean")
        rm -r bin obj && exit
        ;;
    "-h" | "--help")
        help
        ;;
    "-t" | "--test")
        qemu-system-i386 -kernel bin/circuitos.bin && exit
        ;;
    "-x" | "--cross")
        cross
        ;;
    *)
        help "fail"
esac