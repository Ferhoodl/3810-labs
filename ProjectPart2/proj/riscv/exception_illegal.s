# Test detection of a legal instruction that this processor does not support.
# This is the source for TEST_ID 3 and for the injected illegal-code test.

.text
.globl main

main:
    addi x5, x0, 42       # Write x5 before the unsupported instruction
    nop
    nop
    nop

    fence 1, 1            # Legal RISC-V FENCE; our processor reports cause 2

    addi x6, x0, 99       # Must not write x6 after the exception
    wfi                  # Normal halt must not execute after the exception

# For the truly illegal-encoding test, replace instruction 5 in a COPY
# of imem.hex with FFFFFFFF, then run TEST_ID 3 with that memory image.
