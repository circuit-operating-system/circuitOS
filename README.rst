circuitOS
=========

*An operating system, I guess*

circuitOS is a starting project that aims to be similar to macOS, but much more extensible and is FOSS/libre.

Synopsis
--------
circuitOS is a starting project that aims to be similar to macOS, but much more extensible and is FOSS/libre.

Directory Directory
-------------------
Temporal
^^^^^^^^
* ``~/.cross`` - Cross-compilation toolchain.
* ``bin`` - Binary files.
* ``obj`` - Object files.

Permanent
^^^^^^^^^
* ``bsys`` - Build system.
* ``src`` - Source files.

bsys Build System
-----------------

Viewing the help dialog
^^^^^^^^^^^^^^^^^^^^^^^
1. Run ``bsys -h``. (``-h`` is the short-hand switch for the flag ``--help``.)

Building the OS
^^^^^^^^^^^^^^^
1. Ensure the cross-compilation toolchain is installed.
2. Run ``bsys``.

The image will be placed in ``bin``.

Testing the OS
^^^^^^^^^^^^^^
1. Ensure QEMU with i686 emulation is installed.
2. Run ``bsys -t``. (``-t`` is the short-hand switch for the flag ``--test``.)

Removing build artifacts
^^^^^^^^^^^^^^^^^^^^^^^^
1. Run ``bsys -c``. (``-c`` is the short-hand switch for the flag ``--clean``.)

Cross-compiler generation
^^^^^^^^^^^^^^^^^^^^^^^^^
1. Unpack and/or place your sources for Binutils and GCC into the repo's root with the directory names ``binutils.cross`` and ``gcc.cross``.
2. If desired, change where the toolchain will be installed with the PREFIX variable.
3. Run ``bsys -x``. (``-x`` is the short-hand switch for the flag ``--cross``.)

The cross-compilation toolchain will be installed at ``~/.cross/bin``.

Uninstalling the cross-compiler toolchain
"""""""""""""""""""""""""""""""""""""""""
1. Run ``bsys --uncross``.

Development
-----------
To set up a shell for development, source the ``devenv`` file.

It currently:

- Aliases ``bsys/bsys.sh`` to ``bsys``.
- Sets ``$REPO`` to the directory it was sourced at, hopefully the repo clone.

You may also add the below snippet to your ``.bashrc`` file to automatically source ``devenv`` if the starting directory is the path to your clone of this repo.

..  code-block:: bash

    if [[ $(pwd) == "<PATH TO REPO>" ]]; then
        source ./devenv
    fi