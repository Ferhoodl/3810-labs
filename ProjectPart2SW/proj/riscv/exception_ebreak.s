# Test EBREAK detection and younger-instruction blocking.
# The older register write must finish before the processor stops.

.text
.globl main

main:
    addi x5, x0, 42       # Set x5 to 42 so we can check an older write completes
    nop
    nop
    nop

    ebreak               # Trigger a breakpoint exception with cause 3

    addi x6, x0, 99       # Must not write x6 because it follows the exception
    wfi                  # Normal halt must not execute after the exception
