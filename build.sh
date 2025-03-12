# Exit on command failure
set -e

# Display usage if -h/--help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 (-hc)"
    echo
    echo "Options:"
    echo "    -h, --help       Shows this help message."
    echo "    -c, --clean      Remove generated objects and images."
    exit
fi

# Clean if -c/--clean option
if [[ "$1" == "-c" ]]; then
    rm -r bin obj
    exit
fi

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
i686-elf-gcc -T linker.ld -o bin/circuitos.bin -ffreestanding -O2 -nostdlib obj/boot.o obj/kernel.o -lgcc

# Verify multiboot compliance
if grub-file --is-x86-multiboot bin/circuitos.bin; then
  echo "    => Multiboot compliance verified."
else
  echo "    (X) Multiboot compliance check failed!" >&2
fi