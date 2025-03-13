# Exit on command failure
set -e

# Display usage if -h/--help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 (-hc)"
    echo
    echo "Options:"
    echo "    -h, --help             Shows this help message."
    echo "    -c, --clean            Remove generated objects and images."
    echo "    -v, --verify-tools     Verify that all required tools are installed."
    echo "    -b, --build            Build CircuitOS."
    exit
fi

if [[ "$1" == "-v" || "$1" == "--verify-tools" ]]; then
    echo ":: Verifying required tools..."
    if ! command -v i686-elf-gcc > /dev/null 2>&1; then
        echo "(X) i686-elf-gcc not found." >&2
        exit 1
    fi
    if ! command -v grub-file > /dev/null 2>&1; then
        echo "(X) grub-file not found." >&2
        exit 1
    fi
    echo "    => All required tools are installed."
    exit 0
fi

# Clean if -c/--clean option
if [[ "$1" == "-c" || "$1" == "--clean" ]]; then
    rm -r bin obj isodir
    exit
fi

# Verify cross-compiler toolchain is built
if ! command -v i686-elf-as > /dev/null 2>&1; then
    echo "(X) Cross-compiler not found." >&2
    exit 1
fi

if [[ "$1" == "-b" || "$1" == "--build" ]]; then

  # If bin/circuitos.bin exists or obj directory is not empty, clear them.
  if [ -e bin/circuitos.bin ] || [ -n "$(ls -A obj 2>/dev/null)" ]; then
    echo ":: Cleaning previous build..."
    rm -rf bin/* obj/*
  fi

  # Create obj directory if it doesn't exist
  mkdir -p obj

  # Compile all .asm files in the src directory
  echo ":: Compiling assembly files..."
  for asm_file in src/*.asm; do
    i686-elf-as "$asm_file" -o "obj/$(basename "$asm_file" .asm).o"
  done

  # Compile all .c files in the src directory
  echo ":: Compiling C files..."
  for c_file in src/*.c; do
    i686-elf-gcc -c "$c_file" -o "obj/$(basename "$c_file" .c).o" -std=gnu99 -ffreestanding -O2 -Wall -Wextra
  done

  # Link the OS
  echo ":: Linking OS..."
  mkdir -p bin
  i686-elf-gcc -T linker.ld -o bin/circuitos.bin -ffreestanding -O2 -nostdlib obj/*.o -lgcc

  # Verify multiboot compliance
  if grub-file --is-x86-multiboot bin/circuitos.bin; then
    echo "    => Multiboot compliance verified."
  else
    echo "    (X) Multiboot compliance check failed!" >&2
  fi
fi

# Check if any option was provided
if [[ "$1" == "" ]]; then
  echo "No Valid Option Selected"
  echo "Run -h for help"
  exit 0
fi
