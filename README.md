# homebrew-qemu-hvf

This is a homebrew tap for setting up QEMU with Alexander Graf's Apple
Silicon support.

This tap obtains the source of QEMU from https://github.com/uenoB/qemu,
which is a fork of QEMU master with the Alex's patch merged.
QEMU's original repository is https://gitlab.com/qemu-project/qemu.git.

## Installation

Just `brew tap uenob/qemu-hvf` and then `brew install --head qemu-hvf`.

Note that the `qemu-hvf` formula is head only and therefore
Homebrew's version management does not work.
To update qemu-hvf to the latest one, do `brew reinstall` by hand.
