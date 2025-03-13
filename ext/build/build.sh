# Exit on command failure
set -e

# Display the help message
help() {
    echo "Usage: $0 (-cht)"
    echo
    echo "Options:"
    echo "    -c, --clean      Remove generated objects and images."
    echo "    -h, --help       Shows this help message."
    echo "    -t, --test       Run the OS in QEMU."

    exit
}

# If no arguments are passed, just build the OS (default behavior)
if [[ $# -eq 0 ]]; then
    # Verify cross-compiler toolchain is built
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
    i686-elf-gcc -T ext/build/linker.ld -o bin/circuitos.bin -ffreestanding -O2 -nostdlib obj/boot.o obj/kernel.o -lgcc

    # Verify multiboot compliance
    if grub-file --is-x86-multiboot bin/circuitos.bin; then
        echo "    => Multiboot compliance verified."
    else
        echo "    (X) Multiboot compliance check failed!" >&2
    fi
    exit
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
    *)
        help "fail"
esac