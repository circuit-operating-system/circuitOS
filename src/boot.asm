# Define multiboot constants
.set ALIGN,    1<<0             /* align loaded modules on page boundaries */
.set MEMINFO,  1<<1             /* provide memory map */
.set FLAGS,    ALIGN | MEMINFO  /* this is the Multiboot 'flag' field */
.set MAGIC,    0x1BADB002       /* 'magic number' lets bootloader find the header */
.set CHECKSUM, -(MAGIC + FLAGS) /* checksum of above, to prove we are multiboot */

# Set multiboot header
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Read-write data (uninitialized)
.section .bss

# Reserve stack space
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# Main code
.section .text

# Initialize _start
.global _start
.type _start, @function

# Prepare for control handoff
_start:
	mov $stack_top, %esp

	/*
	This is a good place to initialize crucial processor state before the
	high-level kernel is entered. It's best to minimize the early
	environment where crucial features are offline. Note that the
	processor is not fully initialized yet: Features such as floating
	point instructions and instruction set extensions are not initialized
	yet. The GDT should be loaded here. Paging should be enabled here.
	C++ features such as global constructors and exceptions will require
	runtime support to work as well.
	*/

    # Transfer control to Wireframe kernel
	call kernel_main

    # Idle the machine
	cli
1:	hlt
	jmp 1b

# Set size of _start
.size _start, . - _start

