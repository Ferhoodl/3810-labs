# Test that a taken branch skips EBREAK without raising an exception.
# Branch-delay NOPs follow the software-scheduled pipeline rules.

.text
.globl main

main:
    addi x5, x0, 7        # Set the first value used by the branch
    addi x6, x0, 7        # Set the second value equal to the first
    nop
    nop
    nop

    beq x5, x6, branch_target # Take the branch and skip the EBREAK instruction
    nop
    nop

    ebreak               # Must be skipped because the branch is taken
    addi x7, x0, 99       # Must also be skipped by the branch

branch_target:
    addi x8, x0, 8        # Confirm execution reaches the branch target
    wfi                  # End normally without triggering an exception
