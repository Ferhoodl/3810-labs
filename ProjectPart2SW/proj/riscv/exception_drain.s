# Test that older instructions finish after EBREAK is detected.
# Instructions after the breakpoint must not write registers.

.text
.globl main

main:
    addi x5, x0, 42       # Set x5 to 42 to test an earlier register write
    nop
    nop
    nop

    addi x7, x0, 7        # Write x7 immediately before the breakpoint
    addi x8, x0, 8        # Write x8 just before EBREAK to test pipeline draining
    ebreak               # Trigger a breakpoint exception with cause 3

    addi x6, x0, 99       # Must not write x6 after the exception
    addi x9, x0, 100      # Must not write x9 after the exception
    wfi                  # Normal halt must not execute after the exception
